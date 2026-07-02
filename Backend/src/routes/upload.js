import express from 'express';
import authMiddleware from '../middlewares/auth.js';
import upload from '../middlewares/upload.js';
import { uploadToCloudinary } from '../config/cloudinary.js';

const router = express.Router();

router.post('/', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const result = await uploadToCloudinary(req.file.path);
    if (!result) {
      return res.status(500).json({ message: 'Failed to upload to Cloudinary' });
    }

    res.json({ url: result.url });
  } catch (error) {
    console.error('Upload endpoint error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
});

export default router;
