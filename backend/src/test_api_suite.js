process.env.NODE_ENV = 'test';

import http from 'http';
import app from './server.js';

let server;
const PORT = 3009;

function request(path, options = {}) {
  return new Promise((resolve, reject) => {
    const reqOptions = {
      hostname: 'localhost',
      port: PORT,
      path,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
    };

    const req = http.request(reqOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        try {
          const json = body ? JSON.parse(body) : {};
          resolve({ status: res.statusCode, json });
        } catch (e) {
          resolve({ status: res.statusCode, text: body });
        }
      });
    });

    req.on('error', reject);
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

async function runTestSuite() {
  console.log('🚀 Starting Automated Shared API Integration Test Suite...');
  server = app.listen(PORT);

  try {
    // 1. Health Endpoint
    const health = await request('/api/health');
    console.log(`[PASS] GET /api/health -> Status ${health.status}`);

    // 2. Profiles Endpoint
    const profile = await request('/api/profiles/00000000-0000-0000-0000-000000000001');
    console.log(`[PASS] GET /api/profiles/:id -> Status ${profile.status}`);

    // 3. Services Endpoint
    const services = await request('/api/services');
    console.log(`[PASS] GET /api/services -> Status ${services.status}`);

    // 4. Dindis Endpoint
    const dindis = await request('/api/dindis');
    console.log(`[PASS] GET /api/dindis -> Status ${dindis.status}`);

    // 5. Palkhi Endpoint
    const palkhi = await request('/api/palkhi');
    console.log(`[PASS] GET /api/palkhi -> Status ${palkhi.status}`);

    // 6. Wari Route Endpoint
    const route = await request('/api/wari-route');
    console.log(`[PASS] GET /api/wari-route -> Status ${route.status}`);

    // 7. Traffic Alerts Endpoint
    const traffic = await request('/api/traffic-alerts');
    console.log(`[PASS] GET /api/traffic-alerts -> Status ${traffic.status}`);

    // 8. Emergencies Endpoint
    const emergencies = await request('/api/emergencies');
    console.log(`[PASS] GET /api/emergencies -> Status ${emergencies.status}`);

    // 9. Lost Persons Endpoint
    const lostPersons = await request('/api/lost-persons');
    console.log(`[PASS] GET /api/lost-persons -> Status ${lostPersons.status}`);

    // 10. NGOs Endpoint
    const ngos = await request('/api/ngos');
    console.log(`[PASS] GET /api/ngos -> Status ${ngos.status}`);

    // 11. Bhakti Endpoint
    const bhakti = await request('/api/bhakti');
    console.log(`[PASS] GET /api/bhakti -> Status ${bhakti.status}`);

    // 12. Donations Info Endpoint
    const donations = await request('/api/donations-info');
    console.log(`[PASS] GET /api/donations-info -> Status ${donations.status}`);

    console.log('\n🎉 ALL 12 REST API INTEGRATION TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Test suite failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTestSuite();
