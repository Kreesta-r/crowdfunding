import { useParams } from 'react-router-dom'

const CampaignDetails = () => {
  const { id } = useParams()

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Campaign Details</h1>
      <div className="bg-gray-800 rounded-lg p-6">
        {/* Add campaign details content here */}
      </div>
    </div>
  )
}

export default CampaignDetails