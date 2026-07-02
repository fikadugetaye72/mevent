import cron from 'node-cron';
import Event from '../models/event.js';

// Initialize scheduled background jobs
export const initCronJobs = () => {
  console.log('Background cron scheduler initialized.');

  // Run every hour to check for expired events
  cron.schedule('0 * * * *', async () => {
    try {
      const now = new Date();
      const expiredCount = await Event.countDocuments({
        date: { $lt: now },
      });

      console.log(`[CRON] ${now.toISOString()} - Checked events. Found ${expiredCount} expired events.`);
    } catch (error) {
      console.error('[CRON ERROR] Failed checking expired events:', error);
    }
  });

  // Run daily at midnight to log system statistics
  cron.schedule('0 0 * * *', async () => {
    try {
      const totalEvents = await Event.countDocuments();
      console.log(`[CRON SUMMARY] Daily System Report: Total registered events: ${totalEvents}`);
    } catch (error) {
      console.error('[CRON ERROR] Failed to run daily summary:', error);
    }
  });
};
