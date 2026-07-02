import React, { useState, useEffect } from 'react';
import { Calendar, Users, ShieldAlert, Award, Clock } from 'lucide-react';
import api from '../services/api';
import './Dashboard.css';

interface Event {
  id: string;
  title: string;
  description: string;
  date: string;
  location: string;
  imageUrl: string | null;
  User?: {
    username: string;
  };
}

const Dashboard: React.FC = () => {
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    total: 0,
    upcoming: 0,
    past: 0,
    adminsCount: 3,
  });

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      const response = await api.get('/events');
      const allEvents = response.data;
      setEvents(allEvents);

      const now = new Date();
      const upcoming = allEvents.filter((e: Event) => new Date(e.date) >= now).length;
      const past = allEvents.length - upcoming;

      setStats({
        total: allEvents.length,
        upcoming,
        past,
        adminsCount: 3, // Mocked default count of admins
      });
    } catch (err) {
      console.error('Failed to fetch dashboard events:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const cardItems = [
    { title: 'Total Events', value: stats.total, icon: Calendar, color: 'indigo' },
    { title: 'Upcoming Events', value: stats.upcoming, icon: Clock, color: 'emerald' },
    { title: 'Completed/Past', value: stats.past, icon: Award, color: 'amber' },
    { title: 'System Admins', value: stats.adminsCount, icon: Users, color: 'blue' },
  ];

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner" />
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="stats-grid">
        {cardItems.map((card) => {
          const Icon = card.icon;
          return (
            <div key={card.title} className="stats-card glass-panel glass-panel-interactive">
              <div className="stats-info">
                <p className="stats-label">{card.title}</p>
                <h3 className="stats-value">{card.value}</h3>
              </div>
              <div className={`stats-icon-wrapper ${card.color}`}>
                <Icon size={24} />
              </div>
            </div>
          );
        })}
      </div>

      <div className="dashboard-body">
        <div className="recent-events-panel glass-panel">
          <div className="panel-header">
            <h4>Recent Administrative Events Log</h4>
          </div>
          <div className="panel-content">
            {events.length === 0 ? (
              <div className="empty-state">
                <ShieldAlert size={48} className="empty-icon" />
                <p>No events registered. Create one in the Events tab!</p>
              </div>
            ) : (
              <div className="events-table-wrapper">
                <table className="events-table">
                  <thead>
                    <tr>
                      <th>Event Title</th>
                      <th>Location</th>
                      <th>Scheduled Date</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {events.slice(0, 5).map((e) => {
                      const isUpcoming = new Date(e.date) >= new Date();
                      return (
                        <tr key={e.id}>
                          <td className="event-title-cell">{e.title}</td>
                          <td>{e.location}</td>
                          <td>{new Date(e.date).toLocaleDateString()}</td>
                          <td>
                            <span className={`badge-status ${isUpcoming ? 'upcoming' : 'expired'}`}>
                              {isUpcoming ? 'Active' : 'Expired'}
                            </span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
