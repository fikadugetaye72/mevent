import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { 
  Calendar, 
  LayoutDashboard, 
  Users, 
  Settings, 
  LogOut, 
  ChevronLeft, 
  ChevronRight,
  Ticket
} from 'lucide-react';
import logoImg from '../assets/logo.png';
import './Sidebar.css';

interface SidebarProps {
  collapsed: boolean;
  setCollapsed: (val: boolean) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ collapsed, setCollapsed }) => {
  const { logout, user } = useAuth();

  const menuItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Events', path: '/events', icon: Calendar },
    { name: 'Bookings', path: '/bookings', icon: Ticket },
    { name: 'Admins', path: '/users', icon: Users },
    { name: 'Settings', path: '/settings', icon: Settings },
  ];

  return (
    <aside className={`sidebar ${collapsed ? 'collapsed' : ''}`}>
      <div className="sidebar-brand">
        <div className="brand-icon">
          <img src={logoImg} alt="MEvent Logo" className="brand-logo-img" />
        </div>
        {!collapsed && <span className="brand-text">MEvent Admin</span>}
      </div>

      <button className="toggle-btn" onClick={() => setCollapsed(!collapsed)}>
        {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
      </button>

      <nav className="sidebar-nav">
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink 
              key={item.name} 
              to={item.path} 
              className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
            >
              <span className="nav-icon"><Icon size={20} /></span>
              {!collapsed && <span className="nav-label">{item.name}</span>}
            </NavLink>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        {!collapsed && (
          <div className="user-profile">
            <div className="profile-avatar">
              {user?.username.charAt(0).toUpperCase()}
            </div>
            <div className="profile-info">
              <p className="profile-name">{user?.username}</p>
              <p className="profile-role">System Admin</p>
            </div>
          </div>
        )}
        <button className="logout-btn" onClick={logout}>
          <span className="nav-icon"><LogOut size={20} /></span>
          {!collapsed && <span className="nav-label">Logout</span>}
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
