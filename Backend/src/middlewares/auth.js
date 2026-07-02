import jwt from 'jsonwebtoken';
import User from '../models/user.js';

export const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided, authorization denied' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Try to verify token as JWT
    const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_change_me';
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    return next();
  } catch (jwtErr) {
    try {
      // Fallback: Check if token matches a deviceId (for guest auto-login)
      const user = await User.findOne({ deviceId: token });
      if (user) {
        req.user = {
          id: user.id,
          username: user.username,
          email: user.email,
          role: user.role || 'user',
        };
        return next();
      }
    } catch (dbError) {
      console.error('Database device check in authMiddleware failed:', dbError);
    }
  }
  return res.status(401).json({ message: 'Token is not valid' });
};

export const adminMiddleware = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Access denied: Requires administrative privilege' });
  }
  next();
};

export default authMiddleware;
