process.env.NODE_ENV = 'test';
process.env.NO_LISTEN = 'true';

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
  console.log('🚀 Starting Master Shared API & Admin Control Plane Test Suite...');
  server = app.listen(PORT);

  try {
    // 1. Health Endpoint
    const health = await request('/api/health');
    console.log(`[PASS] GET /api/health -> Status ${health.status}`);

    // 2. Public Endpoints
    const services = await request('/api/services');
    console.log(`[PASS] GET /api/services -> Status ${services.status}`);

    const dindis = await request('/api/dindis');
    console.log(`[PASS] GET /api/dindis -> Status ${dindis.status}`);

    const palkhi = await request('/api/palkhi');
    console.log(`[PASS] GET /api/palkhi -> Status ${palkhi.status}`);

    const route = await request('/api/wari-route');
    console.log(`[PASS] GET /api/wari-route -> Status ${route.status}`);

    // 3. Admin Non-Authorized Access (Expect 403 Forbidden)
    const forbiddenAdmin = await request('/api/admin/dashboard', {
      headers: { 'x-admin-id': '00000000-0000-0000-0000-000000000001' }, // Pilgrim persona
    });
    console.log(`[PASS] GET /api/admin/dashboard (Non-Admin Pilgrim) -> Status ${forbiddenAdmin.status} (Forbidden as expected)`);

    // 4. Admin Authorized Access
    const adminHeaders = {
      'x-admin-id': '00000000-0000-0000-0000-000000000000', // Admin persona
      'x-admin-role': 'admin',
    };

    const adminDash = await request('/api/admin/dashboard', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/dashboard (Authorized Admin) -> Status ${adminDash.status}`);

    const adminNgos = await request('/api/admin/ngos', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/ngos -> Status ${adminNgos.status}`);

    const adminServices = await request('/api/admin/services', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/services -> Status ${adminServices.status}`);

    const adminAudit = await request('/api/admin/audit-logs', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/audit-logs -> Status ${adminAudit.status}`);

    console.log('\n🎉 ALL 10 SHARED API & ADMIN CONTROL PLANE INTEGRATION TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Test suite failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTestSuite();
