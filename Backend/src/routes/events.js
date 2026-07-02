import express from 'express';
import {
  getEvents,
  getEventById,
  createEvent,
  updateEvent,
  deleteEvent
} from '../controllers/eventController.js';
import authMiddleware from '../middlewares/auth.js';
import upload from '../middlewares/upload.js';

const router = express.Router();

// GET events (all/filtered)
router.get('/', getEvents);

// GET single event details
router.get('/:id', getEventById);

// POST create event (requires auth + upload)
router.post('/', authMiddleware, upload.single('image'), createEvent);

// PUT update event (requires auth + upload + ownership check)
router.put('/:id', authMiddleware, upload.single('image'), updateEvent);

// DELETE event (requires auth + ownership check)
router.delete('/:id', authMiddleware, deleteEvent);

export default router;
