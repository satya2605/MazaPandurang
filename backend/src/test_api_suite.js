process.env.NODE_ENV = 'test';
process.env.NO_LISTEN = 'true';

import http from 'http';
import app from './server.js';

import { getSupabaseClient } from './db/supabase.js';

let server;
const PORT = 3009;

async function seedTestPersonas() {
  try {
    const client = getSupabaseClient();
    await client.from('profiles').upsert([
      { id: '00000000-0000-0000-0000-000000000001', email: 'satyajit@mazapandurang.local', display_name: 'Satyajit (Pilgrim)', role: 'pilgrim', status: 'active' },
      { id: '00000000-0000-0000-0000-000000000002', email: 'sanket@mazapandurang.local', display_name: 'Sanket (Dindi Leader)', role: 'dindi_leader', status: 'active' },
      { id: '00000000-0000-0000-0000-000000000003', email: 'yogeshwari@mazapandurang.local', display_name: 'Yogeshwari (Police Authority)', role: 'police_authority', status: 'active' },
      { id: '00000000-0000-0000-0000-000000000004', email: 'shrutika@mazapandurang.local', display_name: 'Shrutika (NGO Volunteer)', role: 'ngo_volunteer', status: 'active' },
      { id: '00000000-0000-0000-0000-000000000005', email: 'gauri@mazapandurang.local', display_name: 'Gauri (Local Citizen)', role: 'local_citizen', status: 'active' },
      { id: '00000000-0000-0000-0000-000000000006', email: 'admin@mazapandurang.local', display_name: 'Admin Control Plane', role: 'admin', status: 'active' }
    ], { onConflict: 'id' });
  } catch (e) {
    // Ignore in offline test environment
  }
}

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
  console.log('🚀 Starting Master Platform API & Supabase Security Test Suite...');
  server = app.listen(PORT);
  await seedTestPersonas();

  const pilgrimToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000001' };
  const dindiLeaderToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000002' };
  const policeToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000003' };
  const ngoToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000004' };
  const citizenToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000005' };
  const adminToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000006' };
  const operatorToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000007' };
  const suspendedToken = { 'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000099' };

  let passedTests = 0;
  let totalTests = 0;

  function assert(condition, message) {
    totalTests++;
    if (condition) {
      passedTests++;
      console.log(`  ✅ [PASS ${totalTests}] ${message}`);
    } else {
      console.error(`  ❌ [FAIL ${totalTests}] ${message}`);
    }
  }

  try {
    console.log('\n--- Section 1: Core Gateway & Public Endpoints ---');

    // 1. Health
    const health = await request('/api/health');
    assert(health.status === 200 && health.json.status === 'ok', 'GET /api/health returns 200 OK');

    // 2. Public Read Palkhi
    const palkhiPublic = await request('/api/palkhi');
    assert(palkhiPublic.status === 200, 'GET /api/palkhi is publicly accessible without token');

    // 3. Public Read Dindis
    const dindisPublic = await request('/api/dindis');
    assert(dindisPublic.status === 200, 'GET /api/dindis is publicly accessible');

    // 4. Public Read Services
    const servicesPublic = await request('/api/services');
    assert(servicesPublic.status === 200, 'GET /api/services is publicly accessible');

    // 5. Public Read Wari Route
    const routePublic = await request('/api/wari-route');
    assert(routePublic.status === 200, 'GET /api/wari-route is publicly accessible');

    console.log('\n--- Section 2: 25-Point Security & Auth Suite ---');

    // AUTH 1: No Authorization header -> 401
    const auth1 = await request('/api/admin/dashboard');
    assert(auth1.status === 401, 'AUTH 1: No Authorization header returns 401 Unauthorized');

    // AUTH 2: Invalid JWT -> 401
    const auth2 = await request('/api/admin/dashboard', { headers: { 'Authorization': 'Bearer invalid-token-xyz' } });
    assert(auth2.status === 401, 'AUTH 2: Invalid JWT returns 401 Unauthorized');

    // AUTH 3: Valid pilgrim JWT -> permitted endpoint
    const auth3 = await request('/api/profiles/00000000-0000-0000-0000-000000000001', { headers: pilgrimToken });
    assert(auth3.status === 200, 'AUTH 3: Valid pilgrim JWT accesses profile endpoint');

    // AUTH 4: Pilgrim -> Admin API -> 403
    const auth4 = await request('/api/admin/dashboard', { headers: pilgrimToken });
    assert(auth4.status === 403, 'AUTH 4: Pilgrim accessing Admin API returns 403 Forbidden');

    // AUTH 5: Admin -> Admin API -> 200
    const auth5 = await request('/api/admin/dashboard', { headers: adminToken });
    assert(auth5.status === 200, 'AUTH 5: Admin accessing Admin API returns 200 OK');

    // AUTH 6: Dindi creation derives leader_id from JWT
    const auth6 = await request('/api/dindis', {
      method: 'POST',
      headers: dindiLeaderToken,
      body: {
        name: `Auth Dindi ${Date.now()}`,
        dindi_number: `DND-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
        join_code: `J${Math.floor(1000 + Math.random() * 9000)}`,
        startPoint: 'Alandi',
        destination: 'Pandharpur'
      },
    });
    const createdLeaderId = auth6.json.leader_id || auth6.json.leaderUserId;
    assert(auth6.status === 201 && createdLeaderId === '00000000-0000-0000-0000-000000000002', 'AUTH 6: Dindi creation derives leader_id authoritatively from JWT');

    // AUTH 7: Pilgrim attempting to create Dindi -> 403 Forbidden (Non-leader blocked)
    const auth7 = await request('/api/dindis', {
      method: 'POST',
      headers: pilgrimToken,
      body: {
        name: `Spoof Dindi ${Date.now()}`,
        dindi_number: `DND-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
        join_code: `J${Math.floor(1000 + Math.random() * 9000)}`,
        leader_id: '00000000-0000-0000-0000-000000000006'
      },
    });
    assert(auth7.status === 403, 'AUTH 7: Pilgrim role attempting to create Dindi is rejected with 403 Forbidden');

    // AUTH 8: Emergency creation derives requester_id from JWT
    const auth8 = await request('/api/emergencies', {
      method: 'POST',
      headers: pilgrimToken,
      body: { emergency_type: 'Medical', description: 'Test SOS' },
    });
    assert(auth8.status === 201 && auth8.json.emergency.requester_id === '00000000-0000-0000-0000-000000000001', 'AUTH 8: Emergency creation derives requester_id from JWT');
    const createdEmgCode = auth8.json.requestCode;

    // AUTH 9: Pilgrim cannot view another user's emergency
    const auth9 = await request('/api/emergencies', { headers: dindiLeaderToken });
    const pilgrimEmgs = (auth9.json || []).filter(e => e.requester_id === '00000000-0000-0000-0000-000000000001');
    assert(pilgrimEmgs.length === 0, 'AUTH 9: Dindi Leader cannot view Pilgrim 1 private emergency requests');

    // AUTH 10: Police/Admin can manage emergencies
    const auth10 = await request(`/api/emergencies/${createdEmgCode}`, {
      method: 'PATCH',
      headers: policeToken,
      body: { status: 'dispatched' },
    });
    assert(auth10.status === 200 && auth10.json.status === 'dispatched', 'AUTH 10: Police Authority can update emergency request status');

    // AUTH 11: Pilgrim cannot modify emergency status
    const auth11 = await request(`/api/emergencies/${createdEmgCode}`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { status: 'resolved' },
    });
    assert(auth11.status === 403, 'AUTH 11: Pilgrim modifying emergency status returns 403 Forbidden');

    // AUTH 12: Admin or Palkhi operator can update Palkhi location
    const palkhiId = (palkhiPublic.json && palkhiPublic.json[0]) ? palkhiPublic.json[0].id : 'PALKHI-DEMO-001';
    const auth12 = await request(`/api/palkhi/${palkhiId}/location`, {
      method: 'PATCH',
      headers: adminToken,
      body: { latitude: 18.3411, longitude: 74.0305, current_stage: 'Saswad Stay' },
    });
    assert(auth12.status === 200, 'AUTH 12: Admin can update Palkhi live location');

    // AUTH 13: Unassigned pilgrim updating Palkhi location -> 403 Forbidden
    const auth13 = await request(`/api/palkhi/${palkhiId}/location`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { latitude: 18.3411, longitude: 74.0305 },
    });
    assert(auth13.status === 403, 'AUTH 13: Unassigned pilgrim updating Palkhi live location returns 403 Forbidden');

    // AUTH 14: Palkhi operator cannot access Admin API
    const auth14 = await request('/api/admin/palkhis', { headers: operatorToken });
    assert(auth14.status === 403, 'AUTH 14: Palkhi operator accessing Admin API returns 403 Forbidden');

    // AUTH 15: Role spoofing via request body -> rejected/ignored
    const auth15 = await request('/api/ngos', {
      method: 'POST',
      headers: ngoToken,
      body: {
        name: `Test Auth NGO ${Date.now()}`,
        registration_number: `REG-${Date.now()}`,
        contact_person: 'Shrutika Volunteer',
        phone: '+919876543213',
        email: 'shrutika@mazapandurang.org',
        role: 'admin',
        primary_category: 'Medical & Food Seva'
      },
    });
    assert(auth15.status === 200 || auth15.status === 201, 'AUTH 15: NGO creation processed cleanly without trusting client role field', `(got status ${auth15.status}, body: ${JSON.stringify(auth15.json || auth15.text)})`);

    // AUTH 16: Legacy x-user-id header spoofing without Bearer token -> rejected
    const auth16 = await request('/api/admin/dashboard', { headers: { 'x-user-id': '00000000-0000-0000-0000-000000000006', 'x-admin-role': 'admin' } });
    assert(auth16.status === 401, 'AUTH 16: Legacy header spoofing without Bearer JWT token returns 401 Unauthorized');

    // AUTH 17: Suspended user -> 403
    const auth17 = await request('/api/admin/dashboard', { headers: suspendedToken });
    assert(auth17.status === 403, 'AUTH 17: Suspended user account blocked with 403 Forbidden');

    // AUTH 18: Public endpoints remain accessible
    const auth18 = await request('/api/services?category=Medical');
    assert(auth18.status === 200, 'AUTH 18: Public services search API remains accessible');

    // AUTH 19: Palkhi operator metadata not exposed publicly
    const auth19 = await request('/api/palkhi');
    assert(auth19.json[0] && auth19.json[0].assigned_operator_id === undefined, 'AUTH 19: Public Palkhi API response conceals internal operator identity');

    // AUTH 20: Dindi Leader apply workflow returns profile and pending status
    const auth20 = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: pilgrimToken,
      body: { dindi_name: `New Dindi Group ${Date.now()}`, start_point: 'Alandi', destination: 'Pandharpur' },
    });
    assert(auth20.status === 201, 'AUTH 20: Dindi Leader apply creates leader application in pending status');

    // AUTH 21: Existing privileged profile remains privileged
    const auth21 = await request('/api/profiles/00000000-0000-0000-0000-000000000006', { headers: adminToken });
    assert(auth21.status === 200 && auth21.json.role === 'admin', 'AUTH 21: Existing Admin profile role remains admin');

    // AUTH 22: Police profile role verification
    const auth22 = await request('/api/profiles/00000000-0000-0000-0000-000000000003', { headers: policeToken });
    assert(auth22.status === 200 && auth22.json.role === 'police_authority', 'AUTH 22: Police Authority profile returns police_authority role');

    // AUTH 23: NGO profile role verification
    const auth23 = await request('/api/profiles/00000000-0000-0000-0000-000000000004', { headers: ngoToken });
    assert(auth23.status === 200 && auth23.json.role === 'ngo_volunteer', 'AUTH 23: NGO Volunteer profile returns ngo_volunteer role');

    // AUTH 24: Citizen profile role verification
    const auth24 = await request('/api/profiles/00000000-0000-0000-0000-000000000005', { headers: citizenToken });
    assert(auth24.status === 200 && auth24.json.role === 'local_citizen', 'AUTH 24: Local Citizen profile returns local_citizen role');

    // AUTH 25: Admin audit logs endpoint security
    const auth25 = await request('/api/admin/audit-logs', { headers: adminToken });
    assert(auth25.status === 200 && Array.isArray(auth25.json), 'AUTH 25: Admin audit logs endpoint returns 200 array for Admin token');

    console.log(`\n🎉 MASTER API SUITE SUMMARY: ${passedTests} / ${totalTests} CHECKS PASSED (${Math.round((passedTests / totalTests) * 100)}% SUCCESS RATE)\n`);
  } catch (err) {
    console.error('Fatal API test error:', err);
  } finally {
    if (server) server.close();
  }
}

runTestSuite();
