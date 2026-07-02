import express from 'express';
import { 
  registerUser, 
  loginUser, 
  deviceLogin,
  loginAdmin, 
  registerAdmin, 
  getMe 
} from '../controllers/authController.js';
import authMiddleware from '../middlewares/auth.js';

const router = express.Router();

// User Auth Endpoints
router.post('/register', registerUser);
router.post('/login', loginUser);
router.post('/device-login', deviceLogin);

// Admin Auth Endpoints
router.post('/admin/login', loginAdmin);
router.post('/admin/register', registerAdmin);

// Identity Endpoint
router.get('/me', authMiddleware, getMe);

export default router;
