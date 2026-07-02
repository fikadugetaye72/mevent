import mongoose from 'mongoose';
import crypto from 'crypto';

const categorySchema = new mongoose.Schema({
  _id: {
    type: String,
    default: () => crypto.randomUUID(),
  },
  name: {
    type: String,
    required: true,
    unique: true,
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

const Category = mongoose.model('Category', categorySchema);

export default Category;
