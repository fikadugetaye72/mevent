import mongoose from 'mongoose';
import dotenv from 'dotenv';

// Load env variables (useful if db.js is imported directly in scripts)
dotenv.config();

const connectDB = async () => {
  try {
    const connStr = process.env.MONGODB_URI;
    if (!connStr) {
      throw new Error('MONGODB_URI environment variable is not defined in .env');
    }
    console.log('Connecting to MongoDB...');
    await mongoose.connect(connStr);
    console.log('MongoDB connected successfully.');
  } catch (error) {
    console.error('MongoDB connection error:', error.message);
    process.exit(1);
  }
};

export default connectDB;
