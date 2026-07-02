import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import apiRoutes from './routes/index.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// Middleware integrations
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve file uploads statically
app.use('/uploads', express.static(path.resolve(__dirname, '../uploads')));

// Primary routing endpoints
app.use('/api', apiRoutes);

// API Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date(),
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]', err.stack || err.message);
  res.status(err.status || 500).json({
    message: err.message || 'Internal Server Error',
  });
});

export default app;
