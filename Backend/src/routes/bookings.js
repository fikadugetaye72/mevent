import express from 'express';
import authMiddleware from '../middlewares/auth.js';
import Booking from '../models/booking.js';
import Event from '../models/event.js';

const router = express.Router();

// Create a booking
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { eventId, ticketType, seats, screenshotUrl, email } = req.body;
    if (!eventId || !ticketType || !seats || !screenshotUrl || !email) {
      return res.status(400).json({ message: 'All booking fields (including email) and screenshot are required.' });
    }

    // Fetch event details to calculate total paid amount
    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: 'Event not found.' });
    }

    const ticketPrice = ticketType === 'vip' ? (event.vipPrice || 0) : (event.price || 0);
    const totalPaid = ticketPrice * seats;

    const booking = new Booking({
      user: req.user.id,
      email,
      event: eventId,
      eventCode: event.code,
      ticketType,
      seats,
      totalPaid,
      screenshotUrl,
      status: 'pending',
    });

    await booking.save();
    res.status(201).json(booking);
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ message: 'Server error while creating booking.', error: error.message });
  }
});

// Get bookings (filtered by user, or all for admin)
router.get('/', authMiddleware, async (req, res) => {
  try {
    let query = {};
    if (req.user.role !== 'admin') {
      query.user = req.user.id;
    } else if (req.query.eventId) {
      query.event = req.query.eventId;
    }

    const bookings = await Booking.find(query)
      .populate('event')
      .populate('user', 'username email')
      .sort({ createdAt: -1 });

    res.json(bookings);
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ message: 'Server error fetching bookings.', error: error.message });
  }
});

// Update booking status (Admin only)
router.put('/:id/status', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied: Administrative privilege required.' });
    }

    const { status, cancellationReason } = req.body;
    if (!['confirmed', 'cancelled', 'pending'].includes(status)) {
      return res.status(400).json({ message: 'Invalid booking status.' });
    }

    const updateData = { status };
    if (status === 'cancelled') {
      updateData.cancellationReason = cancellationReason || 'No reason provided';
    } else {
      updateData.cancellationReason = '';
    }

    // Note: req.params.id handles normal Express routing
    const booking = await Booking.findByIdAndUpdate(
      req.params.id,
      updateData,
      { returnDocument: 'after' }
    ).populate('event').populate('user', 'username email');

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found.' });
    }

    res.json(booking);
  } catch (error) {
    console.error('Update booking status error:', error);
    res.status(500).json({ message: 'Server error updating status.', error: error.message });
  }
});

// Scan & Check-in booking (Admin/Controller only)
router.post('/:id/check-in', authMiddleware, async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access denied: Administrative privilege required.' });
    }

    const { eventId } = req.body;
    
    // Check if the ID is a valid MongoDB ObjectId to prevent CastErrors
    const mongoose = (await import('mongoose')).default;
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ message: 'Invalid ticket QR code format.' });
    }

    const booking = await Booking.findById(req.params.id)
      .populate('event')
      .populate('user', 'username email');

    if (!booking) {
      return res.status(404).json({ message: 'Ticket not found in database.' });
    }

    // Verify event matching
    const bookingEventId = booking.event._id ? booking.event._id.toString() : booking.event.toString();
    if (eventId && bookingEventId !== eventId) {
      return res.status(400).json({ 
        message: 'This ticket is registered for a different event!',
        booking: {
          code: booking.code,
          status: booking.status,
          checkedIn: booking.checkedIn,
          user: booking.user,
          eventTitle: booking.event.title
        }
      });
    }

    if (booking.status !== 'confirmed') {
      return res.status(400).json({ 
        message: `This ticket cannot be checked in (Status: ${booking.status})`,
        booking: {
          code: booking.code,
          status: booking.status,
          checkedIn: booking.checkedIn,
          user: booking.user,
          eventTitle: booking.event.title
        }
      });
    }

    if (booking.checkedIn) {
      return res.status(400).json({ 
        message: 'Ticket already scanned / Checked-in.',
        checkedInAt: booking.checkedInAt,
        booking: {
          code: booking.code,
          status: booking.status,
          checkedIn: booking.checkedIn,
          user: booking.user,
          eventTitle: booking.event.title
        }
      });
    }

    booking.checkedIn = true;
    booking.checkedInAt = new Date();
    await booking.save();

    res.json({
      message: 'Check-in successful',
      success: true,
      booking: {
        code: booking.code,
        status: booking.status,
        checkedIn: booking.checkedIn,
        checkedInAt: booking.checkedInAt,
        user: booking.user,
        eventTitle: booking.event.title
      }
    });
  } catch (error) {
    console.error('Scan check-in error:', error);
    res.status(500).json({ message: 'Server error during check-in.', error: error.message });
  }
});

export default router;
