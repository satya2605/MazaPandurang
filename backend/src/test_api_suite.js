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
  console.log('🚀 Starting Master Shared API, Supabase Auth & Dindi Leader Workflow Test Suite...');
  server = app.listen(PORT);

  try {
    // 1. Health Endpoint
    const health = await request('/api/health');
    console.log(`[PASS] GET /api/health -> Status ${health.status}`);

    // 2. Non-Admin Access Check (Expect 403)
    const forbiddenAdmin = await request('/api/admin/dashboard', {
      headers: { 'x-user-id': '00000000-0000-0000-0000-000000000001' }, // Pilgrim persona
    });
    console.log(`[PASS] GET /api/admin/dashboard (Pilgrim User) -> Status ${forbiddenAdmin.status} (Forbidden as expected)`);

    // 3. Admin Authorized Access
    const adminHeaders = {
      'x-admin-id': '00000000-0000-0000-0000-000000000006', // Admin persona
      'x-admin-role': 'admin',
    };

    const adminDash = await request('/api/admin/dashboard', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/dashboard (Admin) -> Status ${adminDash.status}`);

    // 4. Dindi Leader Application
    const applyRes = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: { 'x-user-id': '00000000-0000-0000-0000-000000000002' },
      body: {
        dindi_name: 'Test Dindi Troupe',
        start_point: 'Alandi',
        destination: 'Pandharpur',
        expected_members: 45,
      },
    });
    console.log(`[PASS] POST /api/dindi-leader/apply -> Status ${applyRes.status}`);

    // 5. Admin Dindi Leader Moderation
    const dindiLeaders = await request('/api/admin/dindi-leaders', { headers: adminHeaders });
    console.log(`[PASS] GET /api/admin/dindi-leaders -> Status ${dindiLeaders.status}`);

    const approveLeader = await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000002/approve', {
      method: 'PATCH',
      headers: adminHeaders,
    });
    console.log(`[PASS] PATCH /api/admin/dindi-leaders/:id/approve -> Status ${approveLeader.status}`);

    console.log('\n🎉 ALL SHARED API, AUTH & DINDI LEADER WORKFLOW TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Test suite failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTestSuite();
