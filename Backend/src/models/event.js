import mongoose from 'mongoose';
import crypto from 'crypto';

const eventSchema = new mongoose.Schema({
  _id: {
    type: String,
    default: () => crypto.randomUUID(),
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  date: {
    type: Date,
    required: true,
  },
  location: {
    type: String,
    required: true,
  },
  imageUrl: {
    type: String,
  },
  tags: {
    type: [String],
    default: [],
  },
  speakers: [{
    name: { type: String, required: true },
    imageUrl: { type: String },
  }],
  totalSeats: {
    type: Number,
    default: null,
  },
  vipSeats: {
    type: Number,
    default: null,
  },
  organizers: [{
    name: { type: String, required: true },
    imageUrl: { type: String },
  }],
  price: {
    type: Number,
    default: null,
  },
  vipPrice: {
    type: Number,
    default: null,
  },
  status: {
    type: String,
    enum: ['draft', 'active', 'completed', 'cancelled'],
    default: 'active',
  },
  phone: {
    type: String,
  },
  category: {
    type: String,
    ref: 'Category',
  },
  featured: {
    type: Boolean,
    default: false,
  },
  code: {
    type: String,
    unique: true,
    sparse: true,
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

eventSchema.pre('save', async function() {
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

const Event = mongoose.model('Event', eventSchema);

export default Event;
