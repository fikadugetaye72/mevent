import dotenv from 'dotenv';
import app from './src/app.js';
import connectDB from './src/config/db.js';
import { initCronJobs } from './src/jobs/cron.js';
import './src/config/firebase.js';

// Load environment configurations
dotenv.config();

const PORT = process.env.PORT || 4000;

const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    // Initialize scheduled cron jobs 
    initCronJobs();

    // Launch Express listening port
    app.listen(PORT, () => {
      console.log(`Server is running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
      console.log(`Health check available at http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
