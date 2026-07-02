import express from 'express';
import authRoutes from './auth.js';
import eventRoutes from './events.js';
import categoryRoutes from './categories.js';
import uploadRoutes from './upload.js';

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/events', eventRoutes);
router.use('/categories', categoryRoutes);
router.use('/upload', uploadRoutes);

export default router;
