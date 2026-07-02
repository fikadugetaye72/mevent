import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/user.js';
import Admin from '../models/admin.js';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_change_me';

// Register User
export const registerUser = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'User with this email already exists' });
    }

    const existingUsername = await User.findOne({ username });
    if (existingUsername) {
      return res.status(400).json({ message: 'Username is already taken' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      username,
      email,
      password: hashedPassword,
      role: 'user',
    });

    const token = jwt.sign(
      { id: user.id, username: user.username, email: user.email, role: 'user' },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      token,
      user: { id: user.id, username: user.username, email: user.email, role: 'user' },
    });
  } catch (error) {
    console.error('User register error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// Login User
export const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { id: user.id, username: user.username, email: user.email, role: user.role || 'user' },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: { id: user.id, username: user.username, email: user.email, role: user.role || 'user' },
    });
  } catch (error) {
    console.error('User login error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// Device Login (Auto Login)
export const deviceLogin = async (req, res) => {
  try {
    const { deviceId, fcmToken } = req.body;

    if (!deviceId) {
      return res.status(400).json({ message: 'Device ID is required' });
    }

    let user = await User.findOne({ deviceId });

    if (user) {
      // User exists, update FCM token if provided and changed
      if (fcmToken && user.fcmToken !== fcmToken) {
        user.fcmToken = fcmToken;
        await user.save();
      }
    } else {
      // Create guest user
      const shortId = deviceId.replace(/[^a-zA-Z0-9]/g, '').substring(0, 8);
      const username = `guest_${shortId || Math.floor(100000 + Math.random() * 900000)}`;
      
      user = await User.create({
        username,
        deviceId,
        fcmToken,
        role: 'user',
      });
    }

    const token = jwt.sign(
      { id: user.id, username: user.username, email: user.email, role: user.role || 'user' },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: { id: user.id, username: user.username, email: user.email, role: user.role || 'user' },
    });
  } catch (error) {
    console.error('Device login error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// Admin Login
export const loginAdmin = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ message: 'Invalid administrative credentials' });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid administrative credentials' });
    }

    const token = jwt.sign(
      { id: admin.id, username: admin.username, email: admin.email, role: 'admin' },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      token,
      user: { id: admin.id, username: admin.username, email: admin.email, role: 'admin' },
    });
  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// Register Admin (Helper to bootstrap admin accounts)
export const registerAdmin = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ message: 'Admin account with this email already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const admin = await Admin.create({
      username,
      email,
      password: hashedPassword,
    });

    const token = jwt.sign(
      { id: admin.id, username: admin.username, email: admin.email, role: 'admin' },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      token,
      user: { id: admin.id, username: admin.username, email: admin.email, role: 'admin' },
    });
  } catch (error) {
    console.error('Admin register error:', error);
    res.status(500).json({ message: 'Internal Server Error', error: error.message });
  }
};

// Get current logged-in profile
export const getMe = async (req, res) => {
  try {
    // Admin check
    if (req.user.role === 'admin') {
      const admin = await Admin.findById(req.user.id).select('-password');
      if (!admin) {
        return res.status(404).json({ message: 'Admin profile not found' });
      }
      return res.json({
        id: admin.id,
        username: admin.username,
        email: admin.email,
        role: 'admin',
      });
    }

    // Standard User check
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User profile not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Get profile info error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
};
