import express from 'express';
import cors from 'cors';
import { config, validateEnv } from './config/env.js';
import { checkDatabaseConnection } from './db/supabase.js';

import profilesRoutes from './routes/profiles.routes.js';
import servicesRoutes from './routes/services.routes.js';
import serviceReportsRoutes from './routes/serviceReports.routes.js';
import dindisRoutes from './routes/dindis.routes.js';
import dindiMembershipsRoutes from './routes/dindiMemberships.routes.js';
import palkhiRoutes from './routes/palkhi.routes.js';
import wariRouteRoutes from './routes/wariRoute.routes.js';
import cityPlacesRoutes from './routes/cityPlaces.routes.js';
import routesRoutes from './routes/routes.routes.js';
import trafficAlertsRoutes from './routes/trafficAlerts.routes.js';
import emergencyRoutes from './routes/emergency.routes.js';
import policeRoutes from './routes/police.routes.js';
import lostPersonsRoutes from './routes/lostPersons.routes.js';
import ngosRoutes from './routes/ngos.routes.js';
import bhaktiRoutes from './routes/bhakti.routes.js';
import donationsRoutes from './routes/donations.routes.js';
import adminRoutes from './routes/admin.routes.js';
import dindiLeaderRoutes from './routes/dindiLeader.routes.js';
import tilakRoutes from './routes/tilak.routes.js';

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
      ngoBucket: config.storageBuckets.ngos || 'ngo-images',
    },
  });
});

// Primary API Modular Routes
app.use('/api/profiles', profilesRoutes);
app.use('/api/services', servicesRoutes);
app.use('/api/service-reports', serviceReportsRoutes);
app.use('/api/dindis', dindisRoutes);
app.use('/api/dindi-memberships', dindiMembershipsRoutes);
app.use('/api/palkhi', palkhiRoutes);
app.use('/api/wari-route', wariRouteRoutes);
app.use('/api/city-places', cityPlacesRoutes);
app.use('/api/routes', routesRoutes);
app.use('/api/traffic-alerts', trafficAlertsRoutes);
app.use('/api/emergencies', emergencyRoutes);
app.use('/api/police', policeRoutes);
app.use('/api/lost-persons', lostPersonsRoutes);
app.use('/api/ngos', ngosRoutes);
app.use('/api/bhakti', bhaktiRoutes);
app.use('/api/donations-info', donationsRoutes);
app.use('/api/donations', donationsRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/dindi-leader', dindiLeaderRoutes);
app.use('/api/ai/tilak', tilakRoutes);

// Centralized Error Handler
app.use(errorHandler);

const PORT = config.port;

if (process.env.NODE_ENV !== 'test' && !process.env.NO_LISTEN) {
  app.listen(PORT, () => {
    console.log(`\n========================================================`);
    console.log(` 🚩 Maza Pandurang Shared REST API Server running on port ${PORT}`);
    console.log(` ➔ Health Check:   http://localhost:${PORT}/api/health`);
    console.log(` ➔ Services API:   http://localhost:${PORT}/api/services`);
    console.log(` ➔ Dindis API:     http://localhost:${PORT}/api/dindis`);
    console.log(` ➔ Palkhi API:     http://localhost:${PORT}/api/palkhi`);
    console.log(` ➔ Route API:      http://localhost:${PORT}/api/wari-route`);
    console.log(` ➔ Traffic API:    http://localhost:${PORT}/api/traffic-alerts`);
    console.log(` ➔ Emergency API:  http://localhost:${PORT}/api/emergencies`);
    console.log(` ➔ Lost Person API:http://localhost:${PORT}/api/lost-persons`);
    console.log(` ➔ NGO API:        http://localhost:${PORT}/api/ngos`);
    console.log(`========================================================\n`);
  });
}

export default app;
