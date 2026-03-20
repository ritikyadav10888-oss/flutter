const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 10000;

// Security Middleware - Relaxed CSP for development
app.use(helmet({
  contentSecurityPolicy: false,
}));

// CORS configuration - Allow local dev and the Render URL
const allowedOrigins = [
  'http://localhost:3000',
  'https://flutter-die1.onrender.com'
];

app.use(cors({
  origin: function (origin, callback) {
    // allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    if (allowedOrigins.indexOf(origin) === -1) {
      const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
      return callback(null, true); // Allow all for now to avoid blocking mobile/web during dev
    }
    return callback(null, true);
  }
}));

app.use(express.json());

// Rate Limiting
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, 
  message: 'Too many requests from this IP, please try again after 15 minutes'
});

// Apply rate limiter to auth routes
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/api/auth/create-organizer', authLimiter);

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/tournaments', require('./routes/tournaments'));
app.use('/api/registrations', require('./routes/registrations'));

// Basic health check route
app.get('/', (req, res) => {
  res.send('Force Sports API is running...');
});

// Supabase Connection Health Check
app.get('/api/health', async (req, res) => {
  try {
    const { supabase } = require('./db');
    const { data, error } = await supabase.from('users').select('id').limit(1);
    
    if (error) {
      return res.status(500).json({ 
        status: 'error', 
        message: 'Supabase connection failed', 
        details: error.message 
      });
    }
    
    res.json({ 
      status: 'ok', 
      message: 'Supabase connection verified',
      database: 'connected'
    });
  } catch (err) {
    res.status(500).json({ 
      status: 'error', 
      message: 'Server error during health check', 
      details: err.message 
    });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
