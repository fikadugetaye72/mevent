import Event from '../models/event.js';
import fs from 'fs';
import path from 'path';
import { uploadToCloudinary, deleteFromCloudinary, extractPublicId } from '../config/cloudinary.js';
import { sendEventNotification } from '../services/notificationService.js';
import Booking from '../models/booking.js';
import { sendEventUpdateEmail } from '../services/emailService.js';

const parseJsonField = (field) => {
  if (!field) return undefined;
  if (typeof field === 'string') {
    try {
      return JSON.parse(field);
    } catch (e) {
      return field;
    }
  }
  return field;
};

// GET all events
export const getEvents = async (req, res) => {
  try {
    const { date, search } = req.query;
    const query = {};

    if (date) {
      const startDate = new Date(date);
      startDate.setHours(0, 0, 0, 0);
      const endDate = new Date(date);
      endDate.setHours(23, 59, 59, 999);

      query.date = {
        $gte: startDate,
        $lte: endDate,
      };
    }

    if (search) {
      query.title = {
        $regex: search,
        $options: 'i',
      };
    }

    const events = await Event.find(query).populate('category').sort({ date: 1 });

    res.json(events);
  } catch (error) {
    console.error('Fetch events error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// GET single event
export const getEventById = async (req, res) => {
  try {
    const event = await Event.findById(req.params.id).populate('category');

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    res.json(event);
  } catch (error) {
    console.error('Fetch event error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// POST create event
export const createEvent = async (req, res) => {
  try {
    const { 
      title, 
      description, 
      date, 
      location,
      tags,
      speakers,
      totalSeats,
      vipSeats,
      organizers,
      price,
      vipPrice,
      status,
      phone,
      category,
      featured,
      imageUrl: bodyImageUrl
    } = req.body;

    if (!title || !date || !location) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({ message: 'Title, date, and location are required' });
    }

    let imageUrl = bodyImageUrl || null;
    if (req.file) {
      const cloudinaryResult = await uploadToCloudinary(req.file.path);
      imageUrl = cloudinaryResult ? cloudinaryResult.url : imageUrl;
    }

    const event = await Event.create({
      title,
      description,
      date: new Date(date),
      location,
      imageUrl,
      tags: parseJsonField(tags),
      speakers: parseJsonField(speakers),
      totalSeats: totalSeats !== undefined && totalSeats !== '' ? Number(totalSeats) : null,
      vipSeats: vipSeats !== undefined && vipSeats !== '' ? Number(vipSeats) : null,
      organizers: parseJsonField(organizers),
      price: price !== undefined && price !== '' ? Number(price) : null,
      vipPrice: vipPrice !== undefined && vipPrice !== '' ? Number(vipPrice) : null,
      status: status || 'active',
      phone,
      category: category || null,
      featured: featured === 'true' || featured === true
    });

    const populatedEvent = await Event.findById(event._id).populate('category');
    sendEventNotification(populatedEvent, 'create');
    res.status(201).json(populatedEvent);
  } catch (error) {
    console.error('Create event error:', error);
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// PUT update event
export const updateEvent = async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      if (req.file) fs.unlinkSync(req.file.path);
      return res.status(404).json({ message: 'Event not found' });
    }

    const { 
      title, 
      description, 
      date, 
      location,
      tags,
      speakers,
      totalSeats,
      vipSeats,
      organizers,
      price,
      vipPrice,
      status,
      phone,
      category,
      featured,
      imageUrl: bodyImageUrl
    } = req.body;

    let imageUrl = bodyImageUrl !== undefined ? bodyImageUrl : event.imageUrl;
    if (req.file) {
      // Clean up old image
      if (event.imageUrl) {
        if (event.imageUrl.includes('cloudinary.com')) {
          const oldPublicId = extractPublicId(event.imageUrl);
          if (oldPublicId) {
            await deleteFromCloudinary(oldPublicId);
          }
        } else {
          // Legacy local file cleanup
          const oldPath = path.join(path.resolve(), event.imageUrl);
          if (fs.existsSync(oldPath)) {
            fs.unlinkSync(oldPath);
          }
        }
      }

      // Upload new image
      const cloudinaryResult = await uploadToCloudinary(req.file.path);
      imageUrl = cloudinaryResult ? cloudinaryResult.url : imageUrl;
    }

    event.title = title || event.title;
    event.description = description !== undefined ? description : event.description;
    event.date = date ? new Date(date) : event.date;
    event.location = location || event.location;
    event.imageUrl = imageUrl;

    if (tags !== undefined) event.tags = parseJsonField(tags);
    if (speakers !== undefined) event.speakers = parseJsonField(speakers);
    if (totalSeats !== undefined) event.totalSeats = totalSeats !== '' && totalSeats !== null ? Number(totalSeats) : null;
    if (vipSeats !== undefined) event.vipSeats = vipSeats !== '' && vipSeats !== null ? Number(vipSeats) : null;
    if (organizers !== undefined) event.organizers = parseJsonField(organizers);
    if (price !== undefined) event.price = price !== '' && price !== null ? Number(price) : null;
    if (vipPrice !== undefined) event.vipPrice = vipPrice !== '' && vipPrice !== null ? Number(vipPrice) : null;
    if (status !== undefined) event.status = status;
    if (phone !== undefined) event.phone = phone;
    if (category !== undefined) event.category = category || null;
    if (featured !== undefined) event.featured = featured === 'true' || featured === true;

    await event.save();

    const populatedEvent = await Event.findById(event._id).populate('category');
    
    // Dispatch email notifications to all users who booked this event
    try {
      const bookings = await Booking.find({ event: event._id });
      const uniqueEmails = [...new Set(bookings.map(b => b.email).filter(Boolean))];
      if (uniqueEmails.length > 0) {
        sendEventUpdateEmail(uniqueEmails, populatedEvent);
      }
    } catch (bookingErr) {
      console.error('[EMAIL NOTIFICATION TRIGGER ERROR]', bookingErr);
    }

    sendEventNotification(populatedEvent, 'update');
    res.json(populatedEvent);
  } catch (error) {
    console.error('Update event error:', error);
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// DELETE event
export const deleteEvent = async (req, res) => {
  try {
    const event = await Event.findById(req.params.id);

    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    if (event.imageUrl) {
      if (event.imageUrl.includes('cloudinary.com')) {
        const oldPublicId = extractPublicId(event.imageUrl);
        if (oldPublicId) {
          await deleteFromCloudinary(oldPublicId);
        }
      } else {
        // Legacy local file cleanup
        const filePath = path.join(path.resolve(), event.imageUrl);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
    }

    await event.deleteOne();
    res.json({ message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Delete event error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};
