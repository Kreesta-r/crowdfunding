import { Link, useLocation } from 'react-router-dom'
import { Home, User, PlusCircle, LayoutDashboard } from 'lucide-react'

const Sidebar = () => {
  const location = useLocation()

  const links = [
    { icon: Home, text: 'Home', path: '/' },
    { icon: User, text: 'Profile', path: '/profile' },
    { icon: PlusCircle, text: 'Create Campaign', path: '/create-campaign' },
    { icon: LayoutDashboard, text: 'Campaigns', path: '/campaign-details/1' }
  ]

  return (
    <div className="hidden md:flex flex-col w-64 bg-gray-800 p-4 space-y-4 min-h-[100vh]">
      {links.map((link) => {
        const Icon = link.icon
        const isActive = location.pathname === link.path

        return (
          <Link
            key={link.path}
            to={link.path}
            className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
              isActive
                ? 'bg-blue-600 text-white'
                : 'text-gray-400 hover:bg-gray-700 hover:text-white'
            }`}
          >
            <Icon className="h-5 w-5" />
            <span className="font-medium">{link.text}</span>
          </Link>
        )
      })}
    </div>
  )
}

export default Sidebar