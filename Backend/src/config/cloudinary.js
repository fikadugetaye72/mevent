import { v2 as cloudinary } from 'cloudinary';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'hodzrxdq',
  api_key: process.env.CLOUDINARY_API_KEY || '286394259922175',
  api_secret: process.env.CLOUDINARY_API_SECRET || 'zqwMZ1Sfvo2JMXFsd7_OBzpsudg',
});

/**
 * Reusable helper to upload a local file to Cloudinary.
 * Cleans up/deletes the local file afterwards.
 * @param {string} localFilePath 
 * @returns {Promise<{url: string, publicId: string}|null>}
 */
export const uploadToCloudinary = async (localFilePath) => {
  try {
    if (!localFilePath) return null;

    console.log('Uploading file to Cloudinary:', localFilePath);
    const result = await cloudinary.uploader.upload(localFilePath, {
      folder: 'posters',
      upload_preset: 'event',
      use_filename: true,
      unique_filename: true,
    });

    // Delete local file after successful upload
    if (fs.existsSync(localFilePath)) {
      fs.unlinkSync(localFilePath);
    }

    return {
      url: result.secure_url,
      publicId: result.public_id,
    };
  } catch (error) {
    console.error('Cloudinary upload error:', error);
    // Cleanup local file even on failure to avoid leaking disk space
    if (fs.existsSync(localFilePath)) {
      fs.unlinkSync(localFilePath);
    }
    throw error;
  }
};

/**
 * Reusable helper to delete an asset from Cloudinary.
 * @param {string} publicId 
 * @returns {Promise<object>}
 */
export const deleteFromCloudinary = async (publicId) => {
  try {
    if (!publicId) return null;
    console.log('Deleting file from Cloudinary:', publicId);
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    console.error('Cloudinary delete error:', error);
    throw error;
  }
};

/**
 * Reusable helper to extract public_id from a Cloudinary URL.
 * @param {string} url 
 * @returns {string|null}
 */
export const extractPublicId = (url) => {
  if (!url || !url.includes('cloudinary.com')) return null;
  try {
    const parts = url.split('/image/upload/');
    if (parts.length < 2) return null;
    const pathAndFilename = parts[1].replace(/^v\d+\//, ''); // Remove version part like v1234567/
    const publicId = pathAndFilename.split('.').slice(0, -1).join('.'); // Remove file extension
    return publicId;
  } catch (err) {
    console.error('Error extracting Cloudinary public ID:', err);
    return null;
  }
};
