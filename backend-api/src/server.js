require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const rateLimit = require('express-rate-limit');

// Routes
const rewardRoutes = require('../routes/rewardRoutes');

// Initialize Express app
const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'https://waste-wise.app'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Rate limiting
const globalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // limit each IP to 1000 requests per windowMs
  message: {
    success: false,
    error: 'Too many requests from this IP, please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(globalRateLimit);

// Logging
app.use(morgan('combined'));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Waste Wise Token API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development'
  });
});

// API routes
app.use('/api/rewards', rewardRoutes);

// API documentation endpoint
app.get('/api/docs', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Waste Wise Token Distribution API',
    version: '1.0.0',
    endpoints: {
      'POST /api/rewards/scan': 'Process recycling scan reward',
      'POST /api/rewards/streak': 'Process streak reward',
      'POST /api/rewards/achievement': 'Process achievement reward',
      'POST /api/rewards/community': 'Process community contribution reward',
      'POST /api/rewards/batch': 'Process batch rewards',
      'GET /api/rewards/balance/:walletAddress': 'Get user token balance',
      'GET /api/rewards/token-info': 'Get token information',
      'GET /api/rewards/transaction/:txHash': 'Get transaction status',
      'GET /api/rewards/stats': 'Get service statistics',
      'GET /api/rewards/gas-prices': 'Get current gas prices',
      'POST /api/rewards/estimate-gas': 'Estimate gas for transfer',
      'GET /api/rewards/history/:userId': 'Get user reward history',
      'GET /api/rewards/achievements': 'Get available achievements',
      'GET /api/rewards/health': 'Health check for reward service'
    },
    rewardConditions: {
      scan: {
        baseReward: '10 tokens for correct classification',
        bonuses: {
          highConfidence: '5 additional tokens for >90% confidence',
          accuracy: 'Up to 2x multiplier for high accuracy users',
          streak: 'Up to 3x multiplier for long streaks',
          frequency: 'Up to 2x multiplier for active users',
          consistency: 'Up to 2.5x multiplier for consistent users',
          seasonal: 'Up to 3x multiplier during special events'
        }
      },
      streak: {
        daily: '20 tokens per day',
        weekly: '100 tokens per week (every 7 days)',
        monthly: '500 tokens per month (every 30 days)',
        newRecord: '5 tokens per day of new record'
      },
      achievements: {
        recycling: '10 tokens per milestone item count',
        accuracy: '20 tokens per accuracy percentage milestone',
        streak: '15 tokens per streak day milestone',
        community: '25 tokens per community contribution milestone',
        rare: '2x multiplier for rare achievements'
      },
      community: {
        basereward: '25 tokens',
        activities: {
          tip_sharing: '1x multiplier',
          location_reporting: '1.2x multiplier',
          community_challenge: '1.5x multiplier',
          mentoring: '2x multiplier',
          content_creation: '2.5x multiplier'
        },
        impact: {
          low: '0.5x multiplier',
          medium: '1x multiplier',
          high: '1.5x multiplier',
          viral: '3x multiplier'
        }
      }
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Global error handler:', err);
  
  // Validation errors
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({
      success: false,
      error: 'Invalid JSON payload'
    });
  }

  // Default error response
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Graceful shutdown handler
process.on('SIGINT', () => {
  console.log('\\nReceived SIGINT, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\\nReceived SIGTERM, shutting down gracefully...');
  process.exit(0);
});

// Start server
const PORT = process.env.PORT || 3001;
const HOST = process.env.HOST || '0.0.0.0';

app.listen(PORT, HOST, () => {
  console.log(`🚀 Waste Wise Token API running on ${HOST}:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📚 API Documentation: http://${HOST}:${PORT}/api/docs`);
  console.log(`❤️  Health Check: http://${HOST}:${PORT}/health`);
  console.log('\\n📋 Available endpoints:');
  console.log('  POST /api/rewards/scan - Process recycling scan reward');
  console.log('  POST /api/rewards/streak - Process streak reward');
  console.log('  POST /api/rewards/achievement - Process achievement reward');
  console.log('  POST /api/rewards/community - Process community reward');
  console.log('  POST /api/rewards/batch - Process batch rewards');
  console.log('  GET  /api/rewards/balance/:address - Get token balance');
  console.log('  GET  /api/rewards/token-info - Get token information');
  console.log('  GET  /api/rewards/stats - Get service statistics');
  console.log('\\n💡 Configure your environment variables in .env file');
});

module.exports = app;
