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

const Event = mongoose.model('Event', eventSchema);

export default Event;
