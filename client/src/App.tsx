import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Navbar from './components/Navbar'
import Sidebar from './components/Sidebar'
import Home from './pages/Home'
import Profile from './pages/Profile'
import CreateCampaign from './pages/CreateCampaign'
import CampaignDetails from './pages/CampaignDetails'

const App = () => {
  return (
    <Router>
      <div className="min-h-screen bg-gray-900 text-gray-100">
        <Navbar />
        <div className="flex">
          <Sidebar />
          <div className="flex-1 p-8">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/profile" element={<Profile />} />
              <Route path="/create-campaign" element={<CreateCampaign />} />
              <Route path="/campaign-details/:id" element={<CampaignDetails />} />
            </Routes>
          </div>
        </div>
      </div>
    </Router>
  )
}

export default App