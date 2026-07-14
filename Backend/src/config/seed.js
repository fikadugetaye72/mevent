import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import Booking from '../models/booking.js';
import Event from '../models/event.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const migrateExistingCodes = async () => {
  try {
    console.log('Running database migration for unique 7-digit codes...');

    // 1. Migrate Events
    const eventsWithoutCode = await Event.find({
      $or: [
        { code: { $exists: false } },
        { code: null },
        { code: '' }
      ]
    });

    if (eventsWithoutCode.length > 0) {
      console.log(`Found ${eventsWithoutCode.length} events without unique code. Migrating...`);
      for (const event of eventsWithoutCode) {
        // Trigger pre-save hook to generate code
        await event.save();
      }
      console.log('Events unique code migration completed successfully.');
    } else {
      console.log('All events already have unique codes.');
    }

    // 2. Migrate Bookings
    const bookingsWithoutCode = await Booking.find({
      $or: [
        { code: { $exists: false } },
        { code: null },
        { code: '' }
      ]
    });

    if (bookingsWithoutCode.length > 0) {
      console.log(`Found ${bookingsWithoutCode.length} bookings without unique code. Migrating...`);
      for (const booking of bookingsWithoutCode) {
        // Trigger pre-save hook to generate code
        await booking.save();
      }
      console.log('Bookings unique code migration completed successfully.');
    } else {
      console.log('All bookings already have unique codes.');
    }
  } catch (error) {
    console.error('Error migrating database unique 7-digit codes:', error);
  }
};

export const seedSampleBooking = async () => {
  try {
    // Run migration for existing documents first
    await migrateExistingCodes();

    const sampleFilePath = path.join(__dirname, '../../booking-sample.json');
    if (!fs.existsSync(sampleFilePath)) {
      console.log('Sample booking file not found at:', sampleFilePath);
      return;
    }

    const fileContent = fs.readFileSync(sampleFilePath, 'utf8');
    const data = JSON.parse(fileContent);
    
    // Collect all database document objects
    const docs = [];
    if (data.database_document) docs.push(data.database_document);
    if (data.database_document_2) docs.push(data.database_document_2);

    for (let i = 0; i < docs.length; i++) {
      const doc = docs[i];
      if (!doc || !doc.user || !doc.event) {
        console.log(`Database document ${i + 1} is invalid or incomplete.`);
        continue;
      }

      // Check if it already exists in the database
      const existing = await Booking.findOne({
        user: doc.user,
        event: doc.event,
        email: doc.email
      });

      if (existing) {
        console.log(`Sample booking ${i + 1} already exists in database.`);
        continue;
      }

      // Prepare booking fields
      const bookingData = { ...doc };
      
      // Remove empty _id so MongoDB/Mongoose generates a valid unique ID
      if (!bookingData._id || bookingData._id.trim() === '') {
        delete bookingData._id;
      }

      // Fetch and populate eventCode if missing
      if (!bookingData.eventCode) {
        const event = await Event.findById(bookingData.event);
        if (event) {
          bookingData.eventCode = event.code;
        }
      }

      const newBooking = new Booking(bookingData);
      await newBooking.save();
      console.log(`Sample booking ${i + 1} seeded successfully with ID: ${newBooking._id} and unique code: ${newBooking.code}`);
    }
  } catch (error) {
    console.error('Error seeding sample bookings:', error);
  }
};
