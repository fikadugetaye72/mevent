import React, { useState, useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';
import './AdminLayout.css';

const AdminLayout: React.FC = () => {
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();

  // Map URLs to header titles
  const getPageTitle = (pathname: string) => {
    switch (pathname) {
      case '/':
        return 'System Overview';
      case '/events':
        return 'Events Management';
      case '/users':
        return 'Admins Management';
      case '/settings':
        return 'System Settings';
      default:
        return 'Admin Dashboard';
    }
  };

  // Dynamically update browser tab title
  useEffect(() => {
    const pageTitle = getPageTitle(location.pathname);
    document.title = `${pageTitle} | MEvent Admin`;
  }, [location.pathname]);

  return (
    <div className="admin-layout">
      <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />
      <div className={`admin-main ${collapsed ? 'expanded' : ''}`}>
        <Navbar title={getPageTitle(location.pathname)} />
        <main className="admin-content animate-fade-in">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
