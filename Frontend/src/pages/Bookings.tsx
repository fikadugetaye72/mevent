import React, { useState, useEffect } from 'react';
import { 
  Search, 
  Calendar, 
  MapPin, 
  User, 
  Mail, 
  Clock, 
  Check, 
  X, 
  AlertCircle, 
  DollarSign, 
  ChevronRight, 
  Image as ImageIcon,
  Ticket,
  Maximize2,
  Lock,
  RefreshCw,
  Info,
  ExternalLink
} from 'lucide-react';
import api from '../services/api';
import './Bookings.css';

interface Category {
  id: string;
  name: string;
}

interface Event {
  id: string;
  title: string;
  description: string;
  date: string;
  location: string;
  imageUrl: string | null;
  price: number | null;
  vipPrice: number | null;
  status: string;
  totalSeats: number | null;
  vipSeats: number | null;
  code?: string;
}

interface UserProfile {
  id: string;
  username: string;
  email: string;
}

interface Booking {
  id: string;
  user: UserProfile | null | string;
  email: string;
  event: Event | string;
  ticketType: 'regular' | 'vip';
  seats: number;
  totalPaid: number;
  screenshotUrl: string;
  status: 'pending' | 'confirmed' | 'cancelled';
  createdAt: string;
  code?: string;
  cancellationReason?: string;
}

const Bookings: React.FC = () => {
  const [events, setEvents] = useState<Event[]>([]);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Selection states
  const [selectedEventId, setSelectedEventId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'pending' | 'confirmed' | 'cancelled'>('pending');
  const [eventSearch, setEventSearch] = useState('');
  const [bookingSearch, setBookingSearch] = useState('');

  // Actions states
  const [updatingId, setUpdatingId] = useState<string | null>(null);
  const [lightboxImage, setLightboxImage] = useState<string | null>(null);
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [cancellingId, setCancellingId] = useState<string | null>(null);
  const [cancelReasonText, setCancelReasonText] = useState('');

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const [eventsRes, bookingsRes] = await Promise.all([
        api.get('/events'),
        api.get('/bookings')
      ]);

      setEvents(eventsRes.data);
      setBookings(bookingsRes.data);
    } catch (err: any) {
      console.error('Error fetching bookings/events data:', err);
      setError(err.response?.data?.message || 'Failed to fetch bookings. Ensure you are logged in as an administrator.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleUpdateStatus = async (bookingId: string, status: string, cancellationReason?: string) => {
    try {
      setUpdatingId(bookingId);
      const res = await api.put(`/bookings/${bookingId}/status`, { status, cancellationReason });
      
      // Update local state directly
      setBookings(prevBookings => 
        prevBookings.map(b => b.id === bookingId ? { 
          ...b, 
          status: res.data.status, 
          cancellationReason: res.data.cancellationReason 
        } : b)
      );
    } catch (err: any) {
      console.error('Failed to update booking status:', err);
      alert(err.response?.data?.message || 'Error updating booking status.');
    } finally {
      setUpdatingId(null);
    }
  };

  // Filter events based on search query
  const filteredEvents = events.filter(e => 
    e.title.toLowerCase().includes(eventSearch.toLowerCase()) ||
    e.location.toLowerCase().includes(eventSearch.toLowerCase())
  );

  const selectedEvent = events.find(e => e.id === selectedEventId) || null;

  // Filter bookings for the selected event and the active tab
  const getEventBookings = () => {
    if (!selectedEventId) return [];
    return bookings.filter(b => {
      const eventId = typeof b.event === 'object' ? b.event?.id : b.event;
      return eventId === selectedEventId;
    });
  };

  const eventBookings = getEventBookings();

  // Filter based on sub-tab status and search query
  const displayedBookings = eventBookings.filter(b => {
    const statusMatch = b.status === activeTab;
    if (!statusMatch) return false;

    if (!bookingSearch) return true;
    const searchLower = bookingSearch.toLowerCase();
    
    // User object resolution
    const username = typeof b.user === 'object' && b.user ? b.user.username : '';
    const userEmail = typeof b.user === 'object' && b.user ? b.user.email : '';
    const bookingEmail = b.email || '';
    const bookingId = b.id || '';
    const bookingCode = b.code || '';

    return (
      username.toLowerCase().includes(searchLower) ||
      userEmail.toLowerCase().includes(searchLower) ||
      bookingEmail.toLowerCase().includes(searchLower) ||
      bookingId.toLowerCase().includes(searchLower) ||
      bookingCode.toLowerCase().includes(searchLower)
    );
  });

  // Calculate statistics across all data
  const getOverallStats = () => {
    const totalCount = bookings.length;
    const pendingCount = bookings.filter(b => b.status === 'pending').length;
    const confirmedCount = bookings.filter(b => b.status === 'confirmed').length;
    const cancelledCount = bookings.filter(b => b.status === 'cancelled').length;
    
    const revenue = bookings
      .filter(b => b.status === 'confirmed')
      .reduce((sum, b) => sum + (b.totalPaid || 0), 0);

    return { totalCount, pendingCount, confirmedCount, cancelledCount, revenue };
  };

  const stats = getOverallStats();

  // Get specific counts for the selected event
  const getSelectedEventStats = () => {
    const eventB = eventBookings;
    const pending = eventB.filter(b => b.status === 'pending').length;
    const confirmed = eventB.filter(b => b.status === 'confirmed').length;
    const cancelled = eventB.filter(b => b.status === 'cancelled').length;
    return { pending, confirmed, cancelled };
  };

  const selectedEventStats = getSelectedEventStats();

  // Helper to format image paths
  const getImageUrl = (path: string | null) => {
    if (!path) return null;
    if (path.startsWith('http')) return path;
    const serverUrl = import.meta.env.VITE_API_URL || 'http://localhost:4000';
    return `${serverUrl}${path}`;
  };

  // Helper to retrieve counter of pending bookings for any event
  const getEventPendingCount = (eventId: string) => {
    return bookings.filter(b => {
      const bEvId = typeof b.event === 'object' ? b.event?.id : b.event;
      return bEvId === eventId && b.status === 'pending';
    }).length;
  };

  if (loading) {
    return (
      <div className="bookings-loading-container">
        <div className="spinner" />
        <p>Retrieving reservations and payments...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bookings-error-panel glass-panel">
        <AlertCircle size={48} className="error-icon" />
        <h3>System Access Restricted</h3>
        <p>{error}</p>
        <button className="btn btn-primary" onClick={fetchData}>
          <RefreshCw size={16} /> Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="bookings-container animate-fade-in">
      {/* Event Selection Panel */}
      <div className="bookings-sidebar glass-panel">
        <div className="sidebar-search-header">
          <Search size={18} className="search-icon" />
          <input 
            type="text" 
            placeholder="Search events..." 
            className="form-control sidebar-search"
            value={eventSearch}
            onChange={(e) => setEventSearch(e.target.value)}
          />
        </div>

        <div className="sidebar-events-list">
          <div className="list-title">Events List ({filteredEvents.length})</div>
          {filteredEvents.length === 0 ? (
            <div className="sidebar-empty">No events match search</div>
          ) : (
            filteredEvents.map((e) => {
              const pendingCount = getEventPendingCount(e.id);
              const isSelected = selectedEventId === e.id;
              
              return (
                <div 
                  key={e.id} 
                  className={`sidebar-event-item ${isSelected ? 'active' : ''}`}
                  onClick={() => {
                    setSelectedEventId(e.id);
                    setActiveTab('pending');
                    setBookingSearch('');
                  }}
                >
                  <div className="event-item-thumb">
                    {e.imageUrl ? (
                      <img src={getImageUrl(e.imageUrl) || ''} alt="" />
                    ) : (
                      <div className="thumb-placeholder"><ImageIcon size={16} /></div>
                    )}
                  </div>
                  <div className="event-item-info">
                    <h5 className="event-item-title">{e.title}</h5>
                    <span className="event-item-date">
                      {new Date(e.date).toLocaleDateString([], { month: 'short', day: 'numeric' })}
                      {e.code && ` • #${e.code}`}
                    </span>
                  </div>
                  {pendingCount > 0 && (
                    <span className="event-item-pending-badge">
                      {pendingCount}
                    </span>
                  )}
                  <ChevronRight size={16} className="arrow-icon" />
                </div>
              );
            })
          )}
        </div>
      </div>

      {/* Bookings Details Panel */}
      <div className="bookings-main-content">
        {!selectedEventId ? (
          /* Dashboard overview stats when no event is selected */
          <div className="bookings-overview glass-panel animate-fade-in">
            <div className="overview-hero">
              <Ticket size={48} className="hero-icon" />
              <h2>Tickets Booking Center</h2>
              <p>Select an administrative event from the left sidebar to manage its attendees list and verify invoice transactions.</p>
            </div>

            <div className="stats-grid">
              <div className="stats-card glass-panel">
                <div className="stats-info">
                  <p className="stats-label">Total Reservations</p>
                  <h3 className="stats-value">{stats.totalCount}</h3>
                </div>
                <div className="stats-icon-wrapper blue"><Ticket size={24} /></div>
              </div>

              <div className="stats-card glass-panel">
                <div className="stats-info">
                  <p className="stats-label">Pending Reviews</p>
                  <h3 className="stats-value highlight-warning">{stats.pendingCount}</h3>
                </div>
                <div className="stats-icon-wrapper amber"><Clock size={24} /></div>
              </div>

              <div className="stats-card glass-panel">
                <div className="stats-info">
                  <p className="stats-label">Verified Sales</p>
                  <h3 className="stats-value highlight-success">{stats.confirmedCount}</h3>
                </div>
                <div className="stats-icon-wrapper emerald"><Check size={24} /></div>
              </div>

              <div className="stats-card glass-panel">
                <div className="stats-info">
                  <p className="stats-label">Total Revenue</p>
                  <h3 className="stats-value">${stats.revenue.toLocaleString()}</h3>
                </div>
                <div className="stats-icon-wrapper indigo"><DollarSign size={24} /></div>
              </div>
            </div>

            <div className="overview-instruction">
              <Info size={16} />
              <span>Click on any event on the left to start checking screenshot receipts and confirming seating assignments.</span>
            </div>
          </div>
        ) : (
          /* Detailed booking management panel for selected event */
          <div className="event-bookings-panel glass-panel animate-fade-in">
            {/* Event Summary Header */}
            <div className="event-header-summary">
              <div className="header-info">
                <span className="badge-category">Active Event</span>
                <h2>
                  {selectedEvent?.title}
                  {selectedEvent?.code && (
                    <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)', marginLeft: '8px', fontWeight: 'normal' }}>
                      (#{selectedEvent.code})
                    </span>
                  )}
                </h2>
                <div className="meta-row">
                  <div className="meta-item">
                    <Calendar size={14} />
                    <span>{selectedEvent && new Date(selectedEvent.date).toLocaleString([], { dateStyle: 'medium', timeStyle: 'short' })}</span>
                  </div>
                  <div className="meta-item">
                    <MapPin size={14} />
                    <span>{selectedEvent?.location}</span>
                  </div>
                  <div className="meta-item">
                    <Ticket size={14} />
                    <span>Reg: {selectedEvent?.price === 0 ? 'Free' : `$${selectedEvent?.price || 0}`} | VIP: ${selectedEvent?.vipPrice || 0}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Subtabs and Search Bar */}
            <div className="tab-control-bar">
              <div className="status-tabs">
                <button 
                  className={`tab-btn pending ${activeTab === 'pending' ? 'active' : ''}`}
                  onClick={() => setActiveTab('pending')}
                >
                  Pending Approvals
                  <span className="tab-badge">{selectedEventStats.pending}</span>
                </button>
                
                <button 
                  className={`tab-btn success ${activeTab === 'confirmed' ? 'active' : ''}`}
                  onClick={() => setActiveTab('confirmed')}
                >
                  Success (Confirmed)
                  <span className="tab-badge">{selectedEventStats.confirmed}</span>
                </button>
                
                <button 
                  className={`tab-btn failed ${activeTab === 'cancelled' ? 'active' : ''}`}
                  onClick={() => setActiveTab('cancelled')}
                >
                  Failed (Cancelled)
                  <span className="tab-badge">{selectedEventStats.cancelled}</span>
                </button>
              </div>

              <div className="booking-search-wrapper">
                <Search size={16} className="search-icon" />
                <input 
                  type="text" 
                  placeholder="Filter bookings..." 
                  className="form-control booking-search"
                  value={bookingSearch}
                  onChange={(e) => setBookingSearch(e.target.value)}
                />
              </div>
            </div>

            {/* Bookings List / Table */}
            <div className="bookings-list-container">
              {displayedBookings.length === 0 ? (
                <div className="bookings-empty-state">
                  <Ticket size={48} className="empty-icon" />
                  <h4>No bookings found</h4>
                  <p>There are no bookings matching the status "{activeTab}" for this event.</p>
                </div>
              ) : (
                <div className="table-responsive">
                  <table className="bookings-table">
                    <thead>
                      <tr>
                        <th>Attendee Info</th>
                        <th>Ticket Type</th>
                        <th>Seats</th>
                        <th>Paid Amount</th>
                        <th>Booking Date</th>
                        <th>Receipt Screenshot</th>
                        <th className="text-right">Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {displayedBookings.map((b) => {
                        const userName = typeof b.user === 'object' && b.user ? b.user.username : 'Guest User';
                        const userMail = typeof b.user === 'object' && b.user ? b.user.email : b.email;
                        const isPending = b.status === 'pending';
                        
                        return (
                          <tr key={b.id} className="booking-row">
                            <td>
                              <div className="attendee-cell">
                                <div className="avatar">
                                  {userName.charAt(0).toUpperCase()}
                                </div>
                                <div className="details">
                                  <div className="name">{userName}</div>
                                  <div className="email">{userMail}</div>
                                  {b.code && (
                                    <div style={{ fontSize: '0.75rem', color: 'var(--accent-primary)', fontWeight: 'bold', marginTop: '2px' }}>
                                      Ticket Code: #{b.code}
                                    </div>
                                  )}
                                  {b.status === 'cancelled' && b.cancellationReason && (
                                    <div className="cancellation-reason-banner">
                                      Reason: {b.cancellationReason}
                                    </div>
                                  )}
                                </div>
                              </div>
                            </td>
                            <td>
                              <span className={`badge-ticket-type ${b.ticketType}`}>
                                {b.ticketType.toUpperCase()}
                              </span>
                            </td>
                            <td className="seat-cell">{b.seats}</td>
                            <td className="price-cell">${b.totalPaid}</td>
                            <td className="date-cell">
                              {new Date(b.createdAt).toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' })}
                              <div className="time">
                                {new Date(b.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                              </div>
                            </td>
                            <td>
                              {b.screenshotUrl ? (
                                <div 
                                  className="screenshot-thumb"
                                  onClick={() => setLightboxImage(getImageUrl(b.screenshotUrl))}
                                  title="Expand Payment Receipt"
                                >
                                  <img src={getImageUrl(b.screenshotUrl) || ''} alt="Receipt Thumbnail" />
                                  <div className="hover-overlay">
                                    <Maximize2 size={14} />
                                  </div>
                                </div>
                              ) : (
                                <span className="no-receipt">No Image</span>
                              )}
                            </td>
                            <td className="actions-cell text-right">
                              {updatingId === b.id ? (
                                <div className="button-loading-spinner" />
                              ) : (
                                <div className="actions-btn-group">
                                  {b.status !== 'confirmed' && (
                                    <button 
                                      className="btn-action confirm"
                                      onClick={() => handleUpdateStatus(b.id, 'confirmed')}
                                      title="Confirm Booking"
                                    >
                                      <Check size={16} />
                                    </button>
                                  )}
                                  {b.status !== 'cancelled' && (
                                    <button 
                                      className="btn-action cancel"
                                      onClick={() => {
                                        setCancellingId(b.id);
                                        setCancelReasonText('');
                                        setShowCancelModal(true);
                                      }}
                                      title="Cancel Booking"
                                    >
                                      <X size={16} />
                                    </button>
                                  )}
                                  {b.status !== 'pending' && (
                                    <button 
                                      className="btn-action reset"
                                      onClick={() => handleUpdateStatus(b.id, 'pending')}
                                      title="Mark as Pending"
                                    >
                                      <Clock size={16} />
                                    </button>
                                  )}
                                </div>
                              )}
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
        )}
      </div>

      {/* Screenshot Lightbox Modal */}
      {lightboxImage && (
        <div className="lightbox-overlay" onClick={() => setLightboxImage(null)}>
          <div className="lightbox-content animate-fade-in" onClick={(e) => e.stopPropagation()}>
            <button className="lightbox-close" onClick={() => setLightboxImage(null)}>&times;</button>
            <div className="lightbox-image-wrapper">
              <img src={lightboxImage} alt="Payment Receipt Transaction Details" className="lightbox-image" />
            </div>
            <div className="lightbox-caption">
              <span>Transaction Payment Verification Screenshot</span>
              <a href={lightboxImage} target="_blank" rel="noreferrer" className="btn btn-secondary btn-sm lightbox-download">
                <ExternalLink size={12} /> Open original URL
              </a>
            </div>
          </div>
        </div>
      )}

      {/* Cancellation Reason Modal */}
      {showCancelModal && (
        <div className="lightbox-overlay" onClick={() => setShowCancelModal(false)}>
          <div className="lightbox-content cancel-reason-modal glass-panel animate-fade-in" onClick={(e) => e.stopPropagation()}>
            <button className="lightbox-close" onClick={() => setShowCancelModal(false)}>&times;</button>
            <div className="modal-header-cancel" style={{ padding: '1.5rem 1.5rem 0.5rem 1.5rem' }}>
              <h3 style={{ fontSize: '1.25rem', fontWeight: 700, color: 'var(--text-primary)' }}>Cancel Ticket Booking</h3>
            </div>
            
            <div className="modal-body-cancel" style={{ padding: '1rem 1.5rem' }}>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.875rem', marginBottom: '1.25rem', lineHeight: 1.4 }}>
                Please specify why you are cancelling this booking. This reason will be visible on the attendee's mobile app.
              </p>
              
              {/* Preset Chips */}
              <div className="preset-chips-container" style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem', marginBottom: '1.25rem' }}>
                {[
                  'Invalid payment screenshot',
                  'Incorrect paid amount',
                  'Corrupted receipt attachment',
                  'User requested cancellation',
                  'Duplicate registration'
                ].map((reason) => (
                  <button
                    key={reason}
                    type="button"
                    className="reason-chip"
                    onClick={() => setCancelReasonText(reason)}
                    style={{
                      padding: '6px 12px',
                      fontSize: '0.75rem',
                      borderRadius: '16px',
                      border: '1px solid var(--border-color)',
                      background: 'rgba(255, 255, 255, 0.03)',
                      color: 'var(--text-secondary)',
                      cursor: 'pointer',
                      transition: 'all 0.15s ease'
                    }}
                  >
                    {reason}
                  </button>
                ))}
              </div>
              
              <div className="form-group" style={{ marginBottom: '1.5rem' }}>
                <label className="form-label" htmlFor="cancel-reason-input" style={{ display: 'block', fontSize: '0.8125rem', fontWeight: 600, color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>
                  Custom Reason / Notes
                </label>
                <textarea
                  id="cancel-reason-input"
                  className="form-control"
                  rows={3}
                  placeholder="Type a custom cancellation reason..."
                  value={cancelReasonText}
                  onChange={(e) => setCancelReasonText(e.target.value)}
                  style={{ width: '100%', padding: '10px', fontSize: '0.875rem', borderRadius: 'var(--radius-sm)' }}
                />
              </div>
            </div>
            
            <div className="modal-actions-cancel" style={{ padding: '1rem 1.5rem 1.5rem 1.5rem', borderTop: '1px solid var(--border-color)', display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
              <button 
                type="button" 
                className="btn btn-secondary" 
                onClick={() => setShowCancelModal(false)}
                style={{
                  padding: '8px 16px',
                  borderRadius: 'var(--radius-sm)',
                  border: '1px solid var(--border-color)',
                  background: 'transparent',
                  color: 'var(--text-secondary)',
                  fontWeight: 600,
                  fontSize: '0.875rem',
                  cursor: 'pointer'
                }}
              >
                Keep Booking
              </button>
              <button 
                type="button" 
                className="btn btn-danger" 
                onClick={async () => {
                  if (cancellingId) {
                    await handleUpdateStatus(cancellingId, 'cancelled', cancelReasonText);
                    setShowCancelModal(false);
                  }
                }}
                disabled={!cancelReasonText.trim()}
                style={{
                  padding: '8px 16px',
                  borderRadius: 'var(--radius-sm)',
                  border: 'none',
                  background: 'var(--color-danger)',
                  color: '#ffffff',
                  fontWeight: 600,
                  fontSize: '0.875rem',
                  cursor: 'pointer',
                  opacity: cancelReasonText.trim() ? 1 : 0.6
                }}
              >
                Confirm Cancellation
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Bookings;
