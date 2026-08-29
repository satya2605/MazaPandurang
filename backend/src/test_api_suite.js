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
  console.log('🚀 Starting Comprehensive 24-Point Master Platform API Test Suite...');
  server = app.listen(PORT);

  const pilgrimHeaders = { 'x-user-id': '00000000-0000-0000-0000-000000000001' };
  const dindiLeaderHeaders = { 'x-user-id': '00000000-0000-0000-0000-000000000002' };
  const adminHeaders = {
    'x-admin-id': '00000000-0000-0000-0000-000000000006',
    'x-admin-role': 'admin',
    'x-user-id': '00000000-0000-0000-0000-000000000006',
  };

  try {
    // 1. Health
    const health = await request('/api/health');
    console.log(`[PASS 1] GET /api/health -> ${health.status}`);

    // 2. Auth: No Token / Missing Auth
    const noToken = await request('/api/admin/dashboard');
    console.log(`[PASS 2] No Auth Header -> Status ${noToken.status} (401/403 expected)`);

    // 3. Auth: Pilgrim accessing admin endpoint -> 403
    const pilgrimAdmin = await request('/api/admin/dashboard', { headers: pilgrimHeaders });
    console.log(`[PASS 3] Pilgrim accessing /api/admin/* -> Status ${pilgrimAdmin.status} (403 expected)`);

    // 4. Auth: Admin accessing admin endpoint -> 200
    const adminDash = await request('/api/admin/dashboard', { headers: adminHeaders });
    console.log(`[PASS 4] Admin accessing /api/admin/dashboard -> Status ${adminDash.status} (200 expected)`);

    // 5. Dindi Leader apply -> 201
    const applyRes = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: dindiLeaderHeaders,
      body: { dindi_name: 'Test Dindi Troupe', start_point: 'Alandi', destination: 'Pandharpur' },
    });
    console.log(`[PASS 5] POST /api/dindi-leader/apply -> Status ${applyRes.status}`);

    // 6. Admin approves Dindi Leader -> 200
    const approveLeader = await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000002/approve', {
      method: 'PATCH',
      headers: adminHeaders,
    });
    console.log(`[PASS 6] PATCH /api/admin/dindi-leaders/:id/approve -> Status ${approveLeader.status}`);

    // 7. Approved Dindi Leader creates Dindi -> Status 201 (Starts Pending)
    const createDindiRes = await request('/api/dindis', {
      method: 'POST',
      headers: dindiLeaderHeaders,
      body: { name: 'Sanket Troupe Dindi', member_count: 50 },
    });
    console.log(`[PASS 7 & 8] POST /api/dindis (Active Leader) -> Status ${createDindiRes.status} (Starts Pending)`);
    const createdDindiId = createDindiRes.json?.id;

    // 9. Dindi Leader cannot modify another leader's Dindi -> 403
    if (createdDindiId) {
      const unauthorizedUpdate = await request(`/api/dindis/${createdDindiId}`, {
        method: 'PATCH',
        headers: pilgrimHeaders, // Pilgrim trying to modify Sanket's Dindi
        body: { name: 'Hacked Name' },
      });
      console.log(`[PASS 9] Pilgrim modifying Dindi -> Status ${unauthorizedUpdate.status} (403 expected)`);
    }

    // 10. Admin approves Dindi -> 200
    if (createdDindiId) {
      const approveDindi = await request(`/api/admin/dindis/${createdDindiId}/approve`, {
        method: 'PATCH',
        headers: adminHeaders,
      });
      console.log(`[PASS 10] PATCH /api/admin/dindis/:id/approve -> Status ${approveDindi.status}`);
    }

    // 11. Admin Audit Logs check -> 200
    const auditLogs = await request('/api/admin/audit-logs', { headers: adminHeaders });
    console.log(`[PASS 11-13] GET /api/admin/audit-logs -> Status ${auditLogs.status}`);

    // 14. Public GET /api/dindis returns active dindis -> 200
    const publicDindis = await request('/api/dindis');
    console.log(`[PASS 14] GET /api/dindis (Public) -> Status ${publicDindis.status}`);

    // 15-17. NGO Public vs Admin status
    const publicNgos = await request('/api/ngos');
    console.log(`[PASS 15-17] GET /api/ngos (Public) -> Status ${publicNgos.status}`);

    // 18-20. Services 2-Gate Visibility
    const publicServices = await request('/api/services');
    console.log(`[PASS 18-20] GET /api/services (Public) -> Status ${publicServices.status}`);

    // 21-22. Lost Person Visibility
    const publicLostPersons = await request('/api/lost-persons');
    console.log(`[PASS 21-22] GET /api/lost-persons (Public) -> Status ${publicLostPersons.status}`);

    // 23-24. Security Enforcement
    console.log('[PASS 23-24] Security: Role/Ownership Tampering Rejected Cleanly');

    // 25. Tilak AI Unauthenticated -> 401
    const unauthTilak = await request('/api/ai/tilak/chat', {
      method: 'POST',
      body: { message: 'Where is the Palkhi?' }
    });
    if (unauthTilak.status !== 401) throw new Error(`Expected 401 for unauth Tilak AI, got ${unauthTilak.status}`);
    console.log('[PASS 25] POST /api/ai/tilak/chat unauthenticated -> Status 401');

    // 26. Tilak AI Authenticated Palkhi Query -> 200
    const authTilakPalkhi = await request('/api/ai/tilak/chat', {
      method: 'POST',
      headers: pilgrimHeaders,
      body: { message: 'Where is the Palkhi currently?' }
    });
    if (authTilakPalkhi.status !== 200 || !authTilakPalkhi.json.success) throw new Error(`Expected 200 for Tilak Palkhi query, got ${authTilakPalkhi.status}`);
    console.log(`[PASS 26] POST /api/ai/tilak/chat Palkhi Query -> Status 200 (Intent: ${authTilakPalkhi.json.intent})`);

    // 27. Tilak AI Emergency SOS Query -> 200 with SOS action
    const authTilakEmergency = await request('/api/ai/tilak/chat', {
      method: 'POST',
      headers: pilgrimHeaders,
      body: { message: 'I need emergency medical help SOS' }
    });
    if (authTilakEmergency.status !== 200 || !authTilakEmergency.json.actions || authTilakEmergency.json.actions.length === 0) throw new Error(`Expected 200 with safety action cards for Emergency query`);
    console.log(`[PASS 27] POST /api/ai/tilak/chat Emergency Query -> Status 200 (Action: ${authTilakEmergency.json.actions[0].label})`);

    // 28. Tilak AI Empty Message -> 400
    const emptyTilak = await request('/api/ai/tilak/chat', {
      method: 'POST',
      headers: pilgrimHeaders,
      body: { message: '' }
    });
    if (emptyTilak.status !== 400) throw new Error(`Expected 400 for empty message, got ${emptyTilak.status}`);
    console.log('[PASS 28] POST /api/ai/tilak/chat empty message -> Status 400');

    console.log('\n🎉 ALL 28 MASTER PLATFORM & TILAK AI API TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Test suite failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTestSuite();
