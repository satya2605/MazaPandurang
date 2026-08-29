import express from 'express';
import cors from 'cors';
import { config, validateEnv } from './config/env.js';
import { checkDatabaseConnection } from './db/supabase.js';

import servicesRoutes from './routes/services.routes.js';
import palkhiRoutes from './routes/palkhi.routes.js';
import dindisRoutes from './routes/dindis.routes.js';
import wariRouteRoutes from './routes/wariRoute.routes.js';
import bhaktiRoutes from './routes/bhakti.routes.js';
import donationsRoutes from './routes/donations.routes.js';
import emergencyRoutes from './routes/emergency.routes.js';
import lostPersonsRoutes from './routes/lostPersons.routes.js';

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
app.use('/api/palkhi', palkhiRoutes);
app.use('/api/dindis', dindisRoutes);
app.use('/api/wari-route', wariRouteRoutes);
app.use('/api/bhakti', bhaktiRoutes);
app.use('/api/donations', donationsRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/lost-persons', lostPersonsRoutes);

// Centralized Error Handler
app.use(errorHandler);

const PORT = config.port;

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`\n========================================================`);
    console.log(` 🚩 Maza Pandurang REST API Server running on port ${PORT}`);
    console.log(` ➔ Health Check: http://localhost:${PORT}/api/health`);
    console.log(` ➔ Services API: http://localhost:${PORT}/api/services`);
    console.log(` ➔ Palkhi API:   http://localhost:${PORT}/api/palkhi`);
    console.log(` ➔ Dindis API:   http://localhost:${PORT}/api/dindis`);
    console.log(` ➔ Route API:    http://localhost:${PORT}/api/wari-route`);
    console.log(` ➔ Bhakti API:   http://localhost:${PORT}/api/bhakti`);
    console.log(` ➔ Emergency API:http://localhost:${PORT}/api/emergency`);
    console.log(`========================================================\n`);
  });
}

export default app;
