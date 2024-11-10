// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdFunding is ReentrancyGuard, Pausable, Ownable {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
        bool claimed;
        bool isActive;
        uint256 minimumContribution;
        string category;
    }

    struct CampaignStats {
        uint256 totalDonators;
        uint256 percentageReached;
        uint256 daysLeft;
        bool isSuccessful;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(address => uint256[]) public userCampaigns;
    mapping(address => uint256[]) public userDonations;
    
    uint256 public numberOfCampaigns = 0;
    uint256 public platformFee = 25; // 0.25% fee
    address public feeCollector;
    
    // Events
    event CampaignCreated(uint256 indexed campaignId, address indexed owner, string title, uint256 target);
    event DonationMade(uint256 indexed campaignId, address indexed donor, uint256 amount);
    event CampaignClaimed(uint256 indexed campaignId, address indexed owner, uint256 amount);
    event CampaignCancelled(uint256 indexed campaignId);
    event FeeUpdated(uint256 newFee);
    event FeeCollectorUpdated(address newCollector);

    constructor() {
        feeCollector = msg.sender;
    }

    modifier validCampaign(uint256 _id) {
        require(_id < numberOfCampaigns, "Campaign does not exist");
        _;
    }

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image,
        uint256 _minimumContribution,
        string memory _category
    ) public whenNotPaused returns (uint256) {
        require(_deadline > block.timestamp, "Deadline must be in the future");
        require(_target > 0, "Target amount must be greater than 0");
        require(_minimumContribution > 0, "Minimum contribution must be greater than 0");
        require(bytes(_title).length > 0, "Title cannot be empty");

        Campaign storage campaign = campaigns[numberOfCampaigns];
        
        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.isActive = true;
        campaign.minimumContribution = _minimumContribution;
        campaign.category = _category;

        userCampaigns[msg.sender].push(numberOfCampaigns);
        
        emit CampaignCreated(numberOfCampaigns, msg.sender, _title, _target);
        
        numberOfCampaigns++;
        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id) public payable nonReentrant whenNotPaused validCampaign(_id) {
        Campaign storage campaign = campaigns[_id];
        
        require(campaign.isActive, "Campaign is not active");
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value >= campaign.minimumContribution, "Donation below minimum contribution");

        uint256 feeAmount = (msg.value * platformFee) / 10000;
        uint256 campaignAmount = msg.value - feeAmount;

        campaign.donators.push(msg.sender);
        campaign.donations.push(campaignAmount);
        campaign.amountCollected += campaignAmount;
        
        userDonations[msg.sender].push(_id);

        // Transfer platform fee
        (bool feeSuccess,) = payable(feeCollector).call{value: feeAmount}("");
        require(feeSuccess, "Fee transfer failed");

        emit DonationMade(_id, msg.sender, campaignAmount);
    }

    function claimCampaignFunds(uint256 _id) public nonReentrant validCampaign(_id) {
        Campaign storage campaign = campaigns[_id];
        
        require(msg.sender == campaign.owner, "Only campaign owner can claim");
        require(!campaign.claimed, "Funds already claimed");
        require(block.timestamp >= campaign.deadline, "Campaign still ongoing");
        require(campaign.amountCollected >= campaign.target, "Target not reached");

        campaign.claimed = true;
        
        (bool success,) = payable(campaign.owner).call{value: campaign.amountCollected}("");
        require(success, "Transfer failed");

        emit CampaignClaimed(_id, campaign.owner, campaign.amountCollected);
    }

    function cancelCampaign(uint256 _id) public validCampaign(_id) {
        Campaign storage campaign = campaigns[_id];
        
        require(msg.sender == campaign.owner, "Only campaign owner can cancel");
        require(campaign.isActive, "Campaign is not active");
        require(campaign.amountCollected == 0, "Cannot cancel campaign with donations");

        campaign.isActive = false;
        
        emit CampaignCancelled(_id);
    }

    function getDonators(uint256 _id) public view validCampaign(_id) returns (address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);
        
        for(uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage campaign = campaigns[i];
            allCampaigns[i] = campaign;
        }
        
        return allCampaigns;
    }

    function getCampaignStats(uint256 _id) public view validCampaign(_id) returns (CampaignStats memory) {
        Campaign storage campaign = campaigns[_id];
        
        return CampaignStats({
            totalDonators: campaign.donators.length,
            percentageReached: (campaign.amountCollected * 100) / campaign.target,
            daysLeft: block.timestamp >= campaign.deadline ? 0 : (campaign.deadline - block.timestamp) / 1 days,
            isSuccessful: campaign.amountCollected >= campaign.target
        });
    }

    function getUserCampaigns(address _user) public view returns (uint256[] memory) {
        return userCampaigns[_user];
    }

    function getUserDonations(address _user) public view returns (uint256[] memory) {
        return userDonations[_user];
    }

    // Admin functions
    function updatePlatformFee(uint256 _newFee) public onlyOwner {
        require(_newFee <= 1000, "Fee cannot exceed 10%");
        platformFee = _newFee;
        emit FeeUpdated(_newFee);
    }

    function updateFeeCollector(address _newCollector) public onlyOwner {
        require(_newCollector != address(0), "Invalid address");
        feeCollector = _newCollector;
        emit FeeCollectorUpdated(_newCollector);
    }

    function pausePlatform() public onlyOwner {
        _pause();
    }

    function unpausePlatform() public onlyOwner {
        _unpause();
    }

    // Emergency function to handle stuck funds
    function emergencyWithdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}