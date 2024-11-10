import { useState } from 'react'
import { Link } from 'react-router-dom'
import { Menu, X, Search, Wallet } from 'lucide-react'

const Navbar = () => {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <nav className="bg-gray-800 border-b border-gray-700">
      <div className="max-w-7xl mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex items-center">
              <span className="text-xl font-bold bg-gradient-to-r from-blue-500 to-purple-600 bg-clip-text text-transparent">
                CryptoCrowd
              </span>
            </Link>
          </div>

          {/* Desktop Menu */}
          <div className="hidden md:flex items-center space-x-4">
            <div className="relative">
              <input
                type="text"
                placeholder="Search campaigns..."
                className="bg-gray-700 px-4 py-2 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <Search className="absolute right-3 top-2.5 h-4 w-4 text-gray-400" />
            </div>
            <button className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded-lg text-sm font-medium transition-colors">
              <Wallet className="h-4 w-4" />
              <span>Connect Wallet</span>
            </button>
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={() => setIsOpen(!isOpen)}
              className="text-gray-400 hover:text-white"
            >
              {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {isOpen && (
          <div className="md:hidden py-4">
            <div className="space-y-4">
              <div className="relative">
                <input
                  type="text"
                  placeholder="Search campaigns..."
                  className="w-full bg-gray-700 px-4 py-2 rounded-lg text-sm"
                />
                <Search className="absolute right-3 top-2.5 h-4 w-4 text-gray-400" />
              </div>
              <button className="w-full flex items-center justify-center space-x-2 bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded-lg text-sm font-medium">
                <Wallet className="h-4 w-4" />
                <span>Connect Wallet</span>
              </button>
            </div>
          </div>
        )}
      </div>
    </nav>
  )
}

export default Navbar