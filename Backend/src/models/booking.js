import mongoose from 'mongoose';
import crypto from 'crypto';

const bookingSchema = new mongoose.Schema({
  _id: {
    type: String,
    default: () => crypto.randomUUID(),
  },
  user: {
    type: String,
    ref: 'User',
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  event: {
    type: String,
    ref: 'Event',
    required: true,
  },
  eventCode: {
    type: String,
  },
  ticketType: {
    type: String,
    enum: ['regular', 'vip'],
    required: true,
  },
  seats: {
    type: Number,
    required: true,
    default: 1,
  },
  totalPaid: {
    type: Number,
    required: true,
  },
  screenshotUrl: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled'],
    default: 'pending',
  },
  checkedIn: {
    type: Boolean,
    default: false,
  },
  checkedInAt: {
    type: Date,
  },
  code: {
    type: String,
    unique: true,
    sparse: true,
  },
  cancellationReason: {
    type: String,
  },
}, {
  timestamps: true,
  toJSON: {
    virtuals: true,
    transform: (doc, ret) => {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  },
  toObject: {
    virtuals: true,
    transform: (doc, ret) => {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  },
});

bookingSchema.pre('save', async function() {
  if (!this.code) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let isUnique = false;
    while (!isUnique) {
      let code = '';
      for (let i = 0; i < 7; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      const existing = await this.constructor.findOne({ code });
      if (!existing) {
        this.code = code;
        isUnique = true;
      }
    }
  }
});

const Booking = mongoose.model('Booking', bookingSchema);

export default Booking;
