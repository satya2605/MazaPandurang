import express from 'express';
import cors from 'cors';
import { config, validateEnv } from './config/env.js';
import { checkDatabaseConnection } from './db/supabase.js';
import servicesRoutes from './routes/services.routes.js';
import { errorHandler } from './middleware/errorHandler.js';

validateEnv();

const app = express();

app.use(cors());
app.use(express.json());

// Health Check Endpoint
app.get('/api/health', async (req, res) => {
  const dbStatus = await checkDatabaseConnection();

  res.json({
    status: 'ok',
    service: 'Maza Pandurang Backend REST API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    database: dbStatus,
    storage: {
      lostPersonBucket: config.storageBuckets.lostPerson,
      serviceBucket: config.storageBuckets.services,
      profileBucket: config.storageBuckets.profiles,
    },
  });
});

// Primary API Modular Routes
app.use('/api/services', servicesRoutes);

// Placeholder Module Route Handlers
app.get('/api/palkhi', (req, res) => {
  res.json({
    name: 'Sant Dnyaneshwar Maharaj Palkhi',
    currentStage: 'Saswad Stay',
    nextStop: 'Jejuri',
    latitude: 18.3411,
    longitude: 74.0305,
    lastUpdated: new Date().toISOString(),
  });
});

app.get('/api/dindis', (req, res) => {
  res.json([
    {
      id: 'DND-001',
      name: 'Alka Talkies Dindi #1',
      leaderName: 'Harkal Maharaj',
      memberCount: 450,
      currentStatus: 'Moving towards Saswad',
    },
    {
      id: 'DND-002',
      name: 'Mauli Swaranand Dindi #45',
      leaderName: 'Namdeo Varkari',
      memberCount: 320,
      currentStatus: 'Halted at Hadapsar',
    },
  ]);
});

app.get('/api/bhakti', (req, res) => {
  res.json([
    {
      id: 'BHK-001',
      title: 'Maza Pandurang Abhang',
      marathiTitle: 'माझा पांडुरंग अभंग',
      artist: 'Pandit Bhimsen Joshi',
      category: 'Abhang',
      duration: '04:30',
      externalUrl: 'https://example.com/audio/abhang1.mp3',
    },
  ]);
});

// Centralized Error Handler
app.use(errorHandler);

const PORT = config.port;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`\n========================================================`);
    console.log(` 🚩 Maza Pandurang REST API Server running on port ${PORT}`);
    console.log(` ➔ Health Check: http://localhost:${PORT}/api/health`);
    console.log(` ➔ Services API: http://localhost:${PORT}/api/services`);
    console.log(`========================================================\n`);
  });
}

export default app;
