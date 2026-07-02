import express from 'express';
import { getCategories, createCategory } from '../controllers/categoryController.js';
import authMiddleware from '../middlewares/auth.js';

const router = express.Router();

router.get('/', getCategories);
router.post('/', authMiddleware, createCategory);

export default router;
