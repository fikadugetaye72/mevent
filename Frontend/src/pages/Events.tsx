import React, { useState, useEffect, useRef } from 'react';
import { Calendar, MapPin, Plus, Trash2, Edit3, Image, Search, CalendarDays } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';
import './Events.css';

interface Category {
  id: string;
  name: string;
}

interface Speaker {
  name: string;
  imageUrl: string;
}

interface Organizer {
  name: string;
  imageUrl: string;
}

interface Event {
  id: string;
  title: string;
  description: string;
  date: string;
  location: string;
  imageUrl: string | null;
  tags?: string[];
  speakers?: Speaker[];
  totalSeats?: number | null;
  vipSeats?: number | null;
  organizers?: Organizer[];
  price?: number | null;
  vipPrice?: number | null;
  status?: string;
  phone?: string;
  category?: Category | null;
  featured?: boolean;
  code?: string;
}

const Events: React.FC = () => {
  const [events, setEvents] = useState<Event[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filterDate, setFilterDate] = useState('');

  // Modal states
  const [showModal, setShowModal] = useState(false);
  const [modalMode, setModalMode] = useState<'create' | 'edit'>('create');
  const [activeEventId, setActiveEventId] = useState<string | null>(null);

  // Form states
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [date, setDate] = useState('');
  const [location, setLocation] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);

  // Extended form states
  const [categoryId, setCategoryId] = useState('');
  const [tagsInput, setTagsInput] = useState('');
  const [totalSeats, setTotalSeats] = useState<number | string>('');
  const [vipSeats, setVipSeats] = useState<number | string>('');
  const [price, setPrice] = useState<number | string>('');
  const [vipPrice, setVipPrice] = useState<number | string>('');
  const [status, setStatus] = useState('active');
  const [phone, setPhone] = useState('');
  const [speakers, setSpeakers] = useState<Speaker[]>([]);
  const [organizers, setOrganizers] = useState<Organizer[]>([]);
  const [featured, setFeatured] = useState<boolean>(true);

  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);
  const { user } = useAuth();

  const fetchEvents = async () => {
    try {
      setLoading(true);
      let query = '';
      const params: string[] = [];
      if (search) params.push(`search=${search}`);
      if (filterDate) params.push(`date=${filterDate}`);
      if (params.length > 0) query = `?${params.join('&')}`;

      const response = await api.get(`/events${query}`);
      setEvents(response.data);
    } catch (err) {
      console.error('Failed to load events list:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchCategories = async () => {
    try {
      const response = await api.get('/categories');
      setCategories(response.data);
    } catch (err) {
      console.error('Failed to fetch categories:', err);
    }
  };

  useEffect(() => {
    fetchEvents();
  }, [search, filterDate]);

  useEffect(() => {
    fetchCategories();
  }, []);

  const openCreateModal = () => {
    setModalMode('create');
    setActiveEventId(null);
    setTitle('');
    setDescription('');
    setDate('');
    setLocation('');
    setImageFile(null);

    // Reset extended states to empty strings for optional fields
    setCategoryId('');
    setTagsInput('');
    setTotalSeats('');
    setVipSeats('');
    setPrice('');
    setVipPrice('');
    setStatus('active');
    setPhone('');
    setSpeakers([]);
    setOrganizers([]);
    setFeatured(true); // Default to checked/true in admin panel

    setError('');
    setShowModal(true);
  };

  const openEditModal = (event: Event) => {
    setModalMode('edit');
    setActiveEventId(event.id);
    setTitle(event.title);
    setDescription(event.description || '');

    // Format date object to YYYY-MM-DDTHH:mm for local datetime picker
    const dateObj = new Date(event.date);
    const tzOffset = dateObj.getTimezoneOffset() * 60000;
    const localISOTime = new Date(dateObj.getTime() - tzOffset).toISOString().slice(0, 16);
    setDate(localISOTime);
    setLocation(event.location);
    setImageFile(null);

    // Load extended states
    setCategoryId(event.category?.id || '');
    setTagsInput(event.tags ? event.tags.join(', ') : '');
    setTotalSeats(event.totalSeats !== undefined && event.totalSeats !== null ? event.totalSeats : '');
    setVipSeats(event.vipSeats !== undefined && event.vipSeats !== null ? event.vipSeats : '');
    setPrice(event.price !== undefined && event.price !== null ? event.price : '');
    setVipPrice(event.vipPrice !== undefined && event.vipPrice !== null ? event.vipPrice : '');
    setStatus(event.status || 'active');
    setPhone(event.phone || '');
    setSpeakers(event.speakers || []);
    setOrganizers(event.organizers || []);
    setFeatured(event.featured !== undefined ? event.featured : false);

    setError('');
    setShowModal(true);
  };

  // Speakers dynamic handlers
  const addSpeaker = () => setSpeakers([...speakers, { name: '', imageUrl: '' }]);
  const removeSpeaker = (idx: number) => setSpeakers(speakers.filter((_, i) => i !== idx));
  const updateSpeakerName = (idx: number, name: string) => {
    const updated = [...speakers];
    updated[idx].name = name;
    setSpeakers(updated);
  };
  const handleSpeakerImageUpload = async (idx: number, file: File) => {
    const fd = new FormData();
    fd.append('image', file);
    try {
      const res = await api.post('/upload', fd, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      const updated = [...speakers];
      updated[idx].imageUrl = res.data.url;
      setSpeakers(updated);
    } catch (err) {
      console.error('Speaker photo upload failed:', err);
      alert('Failed to upload image. Please try again.');
    }
  };

  // Organizers dynamic handlers
  const addOrganizer = () => setOrganizers([...organizers, { name: '', imageUrl: '' }]);
  const removeOrganizer = (idx: number) => setOrganizers(organizers.filter((_, i) => i !== idx));
  const updateOrganizerName = (idx: number, name: string) => {
    const updated = [...organizers];
    updated[idx].name = name;
    setOrganizers(updated);
  };
  const handleOrganizerImageUpload = async (idx: number, file: File) => {
    const fd = new FormData();
    fd.append('image', file);
    try {
      const res = await api.post('/upload', fd, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      const updated = [...organizers];
      updated[idx].imageUrl = res.data.url;
      setOrganizers(updated);
    } catch (err) {
      console.error('Organizer photo upload failed:', err);
      alert('Failed to upload image. Please try again.');
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSaving(true);

    const formData = new FormData();
    formData.append('title', title);
    formData.append('description', description);
    formData.append('date', new Date(date).toISOString());
    formData.append('location', location);
    if (imageFile) {
      formData.append('image', imageFile);
    }

    // Extended fields appending
    const parsedTags = tagsInput.split(',').map(t => t.trim()).filter(Boolean);
    formData.append('tags', JSON.stringify(parsedTags));
    formData.append('speakers', JSON.stringify(speakers));
    formData.append('totalSeats', totalSeats !== '' ? String(totalSeats) : '');
    formData.append('vipSeats', vipSeats !== '' ? String(vipSeats) : '');
    formData.append('organizers', JSON.stringify(organizers));
    formData.append('price', price !== '' ? String(price) : '');
    formData.append('vipPrice', vipPrice !== '' ? String(vipPrice) : '');
    formData.append('status', status);
    formData.append('phone', phone);
    formData.append('category', categoryId);
    formData.append('featured', String(featured));

    try {
      if (modalMode === 'create') {
        await api.post('/events', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
      } else {
        await api.put(`/events/${activeEventId}`, formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
      }
      setShowModal(false);
      fetchEvents();
    } catch (err: any) {
      console.error('Save event error:', err);
      setError(err.response?.data?.message || 'Error occurred while saving event.');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this event? This action is permanent.')) return;
    try {
      await api.delete(`/events/${id}`);
      fetchEvents();
    } catch (err) {
      console.error('Delete event error:', err);
      alert('Failed to delete event.');
    }
  };

  return (
    <div className="events-page">
      <div className="events-actions">
        <div className="search-filters">
          <div className="search-input-wrapper glass-panel">
            <Search size={18} className="search-icon" />
            <input
              type="text"
              placeholder="Search by event title..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <div className="date-filter-wrapper glass-panel">
            <CalendarDays size={18} className="filter-icon" />
            <input
              type="date"
              value={filterDate}
              onChange={(e) => setFilterDate(e.target.value)}
            />
          </div>
          {(search || filterDate) && (
            <button className="btn btn-secondary" onClick={() => { setSearch(''); setFilterDate(''); }}>
              Clear Filters
            </button>
          )}
        </div>

        <button className="btn btn-primary" onClick={openCreateModal}>
          <Plus size={18} />
          <span>New Event</span>
        </button>
      </div>

      {loading ? (
        <div className="events-loading">
          <div className="spinner" />
        </div>
      ) : events.length === 0 ? (
        <div className="events-empty glass-panel">
          <Calendar size={64} className="empty-icon" />
          <h3>No events found</h3>
          <p>Create a new event or adjust your filters.</p>
        </div>
      ) : (
        <div className="events-grid">
          {events.map((e) => {
            const eventDate = new Date(e.date);
            const imageSrc = e.imageUrl
              ? (e.imageUrl.startsWith('http') ? e.imageUrl : `${import.meta.env.VITE_API_URL || 'http://localhost:4000'}${e.imageUrl}`)
              : null;

            return (
              <div key={e.id} className="event-card glass-panel animate-fade-in">
                <div className="event-image-wrapper">
                  {imageSrc ? (
                    <img src={imageSrc} alt={e.title} className="event-image" />
                  ) : (
                    <div className="event-image-placeholder">
                      <Image size={32} />
                    </div>
                  )}
                  <div className="event-date-tag">
                    <span className="day">{eventDate.getDate()}</span>
                    <span className="month">{eventDate.toLocaleString('default', { month: 'short' })}</span>
                  </div>
                </div>

                <div className="event-content">
                  <div className="event-badges-row">
                    {e.featured && (
                      <span className="badge featured-badge" style={{ backgroundColor: 'rgba(245, 158, 11, 0.1)', color: '#f59e0b', display: 'inline-flex', alignItems: 'center', gap: '2px' }}>
                        ⭐ Featured
                      </span>
                    )}
                    {e.code && (
                      <span className="badge code-badge" style={{ backgroundColor: 'rgba(99, 102, 241, 0.1)', color: 'var(--accent-primary)', fontWeight: 'bold' }}>
                        #{e.code}
                      </span>
                    )}
                    {e.category && (
                      <span className="badge category-badge">
                        {e.category.name}
                      </span>
                    )}
                    <span className={`badge status-badge status-${e.status || 'active'}`}>
                      {e.status || 'active'}
                    </span>
                    {e.price !== undefined && e.price !== null ? (
                      <span className="badge price-badge">
                        {e.price === 0 ? 'Free' : `$${e.price}`}
                      </span>
                    ) : (
                      <span className="badge price-badge" style={{ backgroundColor: 'rgba(255, 255, 255, 0.05)', color: 'var(--text-muted)' }}>
                        No Price
                      </span>
                    )}
                    {e.vipPrice !== undefined && e.vipPrice !== null && (
                      <span className="badge price-badge" style={{ backgroundColor: 'rgba(234, 179, 8, 0.1)', color: '#eab308' }}>
                        VIP: ${e.vipPrice}
                      </span>
                    )}
                  </div>

                  <h3 className="event-title">{e.title}</h3>
                  <p className="event-description">{e.description || 'No description provided.'}</p>

                  <div className="event-meta">
                    <div className="meta-item">
                      <MapPin size={14} />
                      <span>{e.location}</span>
                    </div>
                    <div className="meta-item">
                      <Calendar size={14} />
                      <span>{eventDate.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                    </div>
                    {e.phone && (
                      <div className="meta-item">
                        <span>📞 Phone: {e.phone}</span>
                      </div>
                    )}
                    {(e.totalSeats !== undefined && e.totalSeats !== null) || (e.vipSeats !== undefined && e.vipSeats !== null) ? (
                      <div className="meta-item">
                        <span>💺 Seats: {e.totalSeats !== null && e.totalSeats !== undefined ? `${e.totalSeats} Reg` : 'Unlimited Reg'} / {e.vipSeats !== null && e.vipSeats !== undefined ? `${e.vipSeats} VIP` : '0 VIP'}</span>
                      </div>
                    ) : null}
                  </div>

                  <div className="event-footer">
                    <span className="creator-tag">System Event</span>

                    <div className="action-buttons">
                      <button
                        className="icon-btn-action edit"
                        onClick={() => openEditModal(e)}
                        title="Edit Event"
                      >
                        <Edit3 size={16} />
                      </button>
                      <button
                        className="icon-btn-action delete"
                        onClick={() => handleDelete(e.id)}
                        title="Delete Event"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Modal Dialog */}
      {showModal && (
        <div className="modal-overlay">
          <div className="modal-content glass-panel animate-fade-in">
            <div className="modal-header">
              <h3>{modalMode === 'create' ? 'Schedule New Administrative Event' : 'Modify Event Settings'}</h3>
              <button className="close-btn" onClick={() => setShowModal(false)}>&times;</button>
            </div>

            {error && <div className="error-alert">{error}</div>}

            <form onSubmit={handleSave} className="modal-form">
              <div className="form-group">
                <label className="form-label" htmlFor="event-title">Event Title</label>
                <input
                  id="event-title"
                  type="text"
                  className="form-control"
                  placeholder="E.g. Annual General Board Meeting"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="event-desc">Description</label>
                <textarea
                  id="event-desc"
                  className="form-control"
                  rows={3}
                  placeholder="Provide meeting logs, schedules, agendas..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                />
              </div>

              {/* Category Dropdown & Tags */}
              <div className="form-row">
                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-category">Category</label>
                  <select
                    id="event-category"
                    className="form-control"
                    value={categoryId}
                    onChange={(e) => setCategoryId(e.target.value)}
                    required
                  >
                    <option value="">-- Select Category --</option>
                    {categories.map((c) => (
                      <option key={c.id} value={c.id}>{c.name}</option>
                    ))}
                  </select>
                </div>

                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-tags">Tags (Comma-separated)</label>
                  <input
                    id="event-tags"
                    type="text"
                    className="form-control"
                    placeholder="tech, live, seminar"
                    value={tagsInput}
                    onChange={(e) => setTagsInput(e.target.value)}
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-date">Date & Time</label>
                  <input
                    id="event-date"
                    type="datetime-local"
                    className="form-control"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                    required
                  />
                </div>

                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-loc">Location</label>
                  <input
                    id="event-loc"
                    type="text"
                    className="form-control"
                    placeholder="Conference Room A / Virtual"
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    required
                  />
                </div>
              </div>

              {/* Seats configuration */}
              <div className="form-row">
                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-total-seats">Total Seats (Optional)</label>
                  <input
                    id="event-total-seats"
                    type="number"
                    className="form-control"
                    placeholder="Leave empty for unlimited"
                    value={totalSeats}
                    onChange={(e) => setTotalSeats(e.target.value)}
                    min={0}
                  />
                </div>

                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-vip-seats">VIP Seats (Optional)</label>
                  <input
                    id="event-vip-seats"
                    type="number"
                    className="form-control"
                    placeholder="Leave empty for 0"
                    value={vipSeats}
                    onChange={(e) => setVipSeats(e.target.value)}
                    min={0}
                  />
                </div>
              </div>

              {/* Price, VIP Price, Status, Phone */}
              <div className="form-row">
                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-price">Ticket Price ($, Optional)</label>
                  <input
                    id="event-price"
                    type="number"
                    className="form-control"
                    placeholder="Leave empty if free/none"
                    value={price}
                    onChange={(e) => setPrice(e.target.value)}
                    min={0}
                  />
                </div>

                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-vip-price">VIP Ticket Price ($, Optional)</label>
                  <input
                    id="event-vip-price"
                    type="number"
                    className="form-control"
                    placeholder="Leave empty if none"
                    value={vipPrice}
                    onChange={(e) => setVipPrice(e.target.value)}
                    min={0}
                  />
                </div>

                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-status">Status</label>
                  <select
                    id="event-status"
                    className="form-control"
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                    required
                  >
                    <option value="active">Active</option>
                    <option value="draft">Draft</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>
              </div>

              <div className="form-row">
                <div className="form-group flex-1">
                  <label className="form-label" htmlFor="event-phone">Contact Phone</label>
                  <input
                    id="event-phone"
                    type="text"
                    className="form-control"
                    placeholder="+123456789"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                  />
                </div>

                <div className="form-group flex-1" style={{ display: 'flex', alignItems: 'center', marginTop: '24px' }}>
                  <label className="checkbox-label" htmlFor="event-featured" style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', userSelect: 'none', color: 'var(--text-secondary)' }}>
                    <input
                      id="event-featured"
                      type="checkbox"
                      checked={featured}
                      onChange={(e) => setFeatured(e.target.checked)}
                      style={{ cursor: 'pointer', width: '16px', height: '16px' }}
                    />
                    <span>Feature this event on home screen</span>
                  </label>
                </div>
              </div>

              {/* Speakers dynamic block */}
              <div className="form-group">
                <div className="subform-header">
                  <span className="form-label">Speakers / Guests</span>
                  <button type="button" className="btn btn-secondary btn-sm" onClick={addSpeaker}>
                    + Add Speaker
                  </button>
                </div>
                <div className="dynamic-list">
                  {speakers.map((s, idx) => (
                    <div key={idx} className="dynamic-row glass-panel">
                      <input
                        type="text"
                        placeholder="Speaker Name"
                        className="form-control flex-1"
                        value={s.name}
                        onChange={(e) => updateSpeakerName(idx, e.target.value)}
                        required
                      />
                      <div className="dynamic-upload">
                        {s.imageUrl ? (
                          <img src={s.imageUrl} alt={s.name} className="avatar-thumbnail" />
                        ) : (
                          <div className="avatar-thumbnail empty"><Image size={14} /></div>
                        )}
                        <input
                          type="file"
                          id={`speaker-pic-${idx}`}
                          style={{ display: 'none' }}
                          accept="image/*"
                          onChange={(e) => {
                            if (e.target.files?.[0]) {
                              handleSpeakerImageUpload(idx, e.target.files[0]);
                            }
                          }}
                        />
                        <button
                          type="button"
                          className="btn btn-secondary btn-sm"
                          onClick={() => document.getElementById(`speaker-pic-${idx}`)?.click()}
                        >
                          Photo
                        </button>
                      </div>
                      <button type="button" className="btn-icon-danger" onClick={() => removeSpeaker(idx)}>&times;</button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Organizers dynamic block */}
              <div className="form-group">
                <div className="subform-header">
                  <span className="form-label">Organizers</span>
                  <button type="button" className="btn btn-secondary btn-sm" onClick={addOrganizer}>
                    + Add Organizer
                  </button>
                </div>
                <div className="dynamic-list">
                  {organizers.map((o, idx) => (
                    <div key={idx} className="dynamic-row glass-panel">
                      <input
                        type="text"
                        placeholder="Organizer Name"
                        className="form-control flex-1"
                        value={o.name}
                        onChange={(e) => updateOrganizerName(idx, e.target.value)}
                        required
                      />
                      <div className="dynamic-upload">
                        {o.imageUrl ? (
                          <img src={o.imageUrl} alt={o.name} className="avatar-thumbnail" />
                        ) : (
                          <div className="avatar-thumbnail empty"><Image size={14} /></div>
                        )}
                        <input
                          type="file"
                          id={`organizer-pic-${idx}`}
                          style={{ display: 'none' }}
                          accept="image/*"
                          onChange={(e) => {
                            if (e.target.files?.[0]) {
                              handleOrganizerImageUpload(idx, e.target.files[0]);
                            }
                          }}
                        />
                        <button
                          type="button"
                          className="btn btn-secondary btn-sm"
                          onClick={() => document.getElementById(`organizer-pic-${idx}`)?.click()}
                        >
                          Photo
                        </button>
                      </div>
                      <button type="button" className="btn-icon-danger" onClick={() => removeOrganizer(idx)}>&times;</button>
                    </div>
                  ))}
                </div>
              </div>

              {/* Cover Image Upload */}
              <div className="form-group">
                <label className="form-label">Attachment Image</label>
                <div
                  className="upload-dropzone"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Image size={24} className="upload-icon" />
                  <span>{imageFile ? imageFile.name : 'Select cover image file...'}</span>
                  <input
                    type="file"
                    ref={fileInputRef}
                    style={{ display: 'none' }}
                    accept="image/*"
                    onChange={(e) => setImageFile(e.target.files?.[0] || null)}
                  />
                </div>
              </div>

              <div className="modal-actions">
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>
                  Cancel
                </button>
                <button type="submit" className="btn btn-primary" disabled={saving}>
                  {saving ? 'Saving...' : 'Save Event'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default Events;
