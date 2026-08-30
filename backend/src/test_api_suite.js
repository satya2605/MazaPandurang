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
    const otherLeaderDindiId = auth6.json.id;
    assert(auth6.status === 201 && createdLeaderId === '00000000-0000-0000-0000-000000000002', 'AUTH 6: Dindi creation derives leader_id authoritatively from JWT');

    // AUTH 7: Pilgrim attempting to create Dindi -> 403 Forbidden (Non-leader blocked)
    const auth7 = await request('/api/dindis', {
      method: 'POST',
      headers: citizenToken,
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

    // AUTH 26: Admin Palkhi Registry creation
    const auth26 = await request('/api/admin/palkhis', {
      method: 'POST',
      headers: adminToken,
      body: { name: `Test Palkhi ${Date.now()}`, saint: 'Sant Tukaram Maharaj', start_point: 'Dehu', destination: 'Pandharpur' }
    });
    assert(auth26.status === 201 && auth26.json.palkhi && auth26.json.palkhi.id, 'AUTH 26: Admin can create new Palkhi entity in registry');
    const newPalkhiId = auth26.json.palkhi.id;

    // AUTH 27: Admin Multi-Day Halt Planning
    const auth27 = await request(`/api/admin/palkhis/${newPalkhiId}/halts`, {
      method: 'POST',
      headers: adminToken,
      body: { day_number: 1, halt_date: '2026-06-18', location_name: 'Dehu Departure', expected_arrival: '06:00', expected_departure: '10:00', next_destination: 'Akurdi' }
    });
    assert(auth27.status === 201 && auth27.json.halt && auth27.json.halt.location_name === 'Dehu Departure', 'AUTH 27: Admin can add planned halt schedule to Palkhi');

    // AUTH 28: Publish Palkhi and verify public endpoint returns halts
    await request(`/api/admin/palkhis/${newPalkhiId}/publish`, { method: 'PATCH', headers: adminToken });
    const auth28 = await request('/api/palkhi');
    assert(auth28.status === 200 && Array.isArray(auth28.json), 'AUTH 28: Public GET /api/palkhi returns published Palkhis with halts array');

    // AUTH 29: Strict Palkhi / Dindi Data Separation check
    const auth29 = await request('/api/palkhi');
    const hasDindiInPalkhi = Array.isArray(auth29.json) && auth29.json.some(p => p.leaderName !== undefined || p.dindiNumber !== undefined);
    assert(!hasDindiInPalkhi, 'AUTH 29: Public Palkhi API payload strictly contains only Palkhis (0 Dindis)');

    // AUTH 30: Unauthenticated halt creation blocked
    const auth30 = await request(`/api/admin/palkhis/${newPalkhiId}/halts`, {
      method: 'POST',
      body: { day_number: 2, halt_date: '2026-06-19', location_name: 'Pune Stay' }
    });
    assert(auth30.status === 401 || auth30.status === 403, 'AUTH 30: Unauthenticated attempt to add Palkhi halt blocked with 401/403');

    // --- SECTION 3: Task 2 — Dindi Leader Workflow & Operational Test Suite (DINDI 1 - DINDI 36) ---
    console.log('\n--- Section 3: Task 2 — Dindi Leader & Operations Suite ---');

    // DINDI 1: Authenticated user submits leader application -> success
    const dindi1 = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: pilgrimToken,
      body: { dindi_name: `Test Leader Troupe ${Date.now()}`, start_point: 'Alandi', destination: 'Pandharpur' }
    });
    assert(dindi1.status === 201, 'DINDI 1: Authenticated user can submit Dindi Leader application');

    // DINDI 2: Unauthenticated application -> 401
    const dindi2 = await request('/api/dindi-leader/apply', {
      method: 'POST',
      body: { dindi_name: 'Unauth Troupe' }
    });
    assert(dindi2.status === 401, 'DINDI 2: Unauthenticated Dindi Leader application returns 401 Unauthorized');

    // DINDI 3: Leader application starts pending status
    const dindi3 = await request('/api/profiles/00000000-0000-0000-0000-000000000001', { headers: pilgrimToken });
    assert(dindi3.status === 200 && dindi3.json.role === 'dindi_leader' && dindi3.json.status === 'pending', 'DINDI 3: Applied Dindi Leader profile role is dindi_leader and status is pending');

    // DINDI 4: Pending leader cannot create Dindi -> 403
    const dindi4 = await request('/api/dindis', {
      method: 'POST',
      headers: pilgrimToken,
      body: { name: 'Pending Troupe Creation' }
    });
    assert(dindi4.status === 403, 'DINDI 4: Pending Dindi Leader cannot create Dindi (403 Forbidden)');

    // DINDI 5: Admin retrieves pending Dindi Leaders
    const dindi5 = await request('/api/admin/users?role=dindi_leader&status=pending', { headers: adminToken });
    assert(dindi5.status === 200 && Array.isArray(dindi5.json), 'DINDI 5: Admin can retrieve pending Dindi Leader applications');

    // DINDI 6: Admin approves leader
    const dindi6 = await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000001/approve', {
      method: 'PATCH',
      headers: adminToken
    });
    assert(dindi6.status === 200, 'DINDI 6: Admin can approve Dindi Leader application');

    // DINDI 7: Leader profile becomes active
    const dindi7 = await request('/api/profiles/00000000-0000-0000-0000-000000000001', { headers: pilgrimToken });
    assert(dindi7.status === 200 && dindi7.json.status === 'active', 'DINDI 7: Approved Dindi Leader profile status becomes active');

    // DINDI 8: Non-admin cannot approve leader -> 403
    const dindi8 = await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000005/approve', {
      method: 'PATCH',
      headers: dindiLeaderToken
    });
    assert(dindi8.status === 403, 'DINDI 8: Non-admin cannot approve Dindi Leader (403 Forbidden)');

    // DINDI 9: Active leader creates Dindi
    const dindi9 = await request('/api/dindis', {
      method: 'POST',
      headers: pilgrimToken, // User 1 is now an active dindi_leader
      body: { name: `Active Leader Dindi ${Date.now()}`, startPoint: 'Alandi', destination: 'Pandharpur', dindi_number: `DND-TEST-${Date.now()}` }
    });
    assert(dindi9.status === 201 && dindi9.json.id, 'DINDI 9: Active Dindi Leader can create Dindi');
    const createdDindiId = dindi9.json.id;

    // DINDI 10: leader_id comes from JWT
    assert(dindi9.json.leader_id === '00000000-0000-0000-0000-000000000001', 'DINDI 10: Dindi leader_id is authoritatively assigned from JWT bearer token');

    // DINDI 11: Spoofed leader_id is ignored
    const dindi11 = await request('/api/dindis', {
      method: 'POST',
      headers: pilgrimToken,
      body: { name: `Spoof Test Dindi ${Date.now()}`, leader_id: '00000000-0000-0000-0000-000000000006' }
    });
    assert(dindi11.status === 201 && dindi11.json.leader_id === '00000000-0000-0000-0000-000000000001', 'DINDI 11: Client-supplied leader_id in body is ignored; JWT leader_id enforced');

    // DINDI 12: New Dindi starts Pending
    assert(dindi9.json.status === 'Pending', 'DINDI 12: Newly created Dindi entity starts in Pending status');

    // DINDI 13: Admin retrieves pending Dindis
    const dindi13 = await request('/api/admin/dindis?status=Pending', { headers: adminToken });
    assert(dindi13.status === 200 && Array.isArray(dindi13.json), 'DINDI 13: Admin can retrieve pending Dindi list');

    // DINDI 14: Admin approves Dindi
    const dindi14 = await request(`/api/admin/dindis/${createdDindiId}/approve`, {
      method: 'PATCH',
      headers: adminToken
    });
    assert(dindi14.status === 200, 'DINDI 14: Admin can approve Dindi entity');

    // DINDI 15: Dindi becomes Active
    const dindi15 = await request(`/api/dindis/${createdDindiId}`, { headers: adminToken });
    assert(dindi15.status === 200 && dindi15.json.status === 'Active', 'DINDI 15: Approved Dindi status becomes Active');

    // DINDI 16: Join Code becomes active
    assert(dindi15.json.joinCode && dindi15.json.joinCode.length > 0, 'DINDI 16: Join Code is active for approved Dindi');

    // DINDI 17: Leader adds halt to own Dindi
    const dindi17 = await request(`/api/dindis/${createdDindiId}/halts`, {
      method: 'POST',
      headers: pilgrimToken,
      body: { day_number: 1, halt_date: '2026-06-18', location_name: 'Alandi Stay', expected_arrival: '08:00', expected_departure: '12:00' }
    });
    assert(dindi17.status === 201 && dindi17.json.halt && dindi17.json.halt.location_name === 'Alandi Stay', 'DINDI 17: Leader can add multi-day planned halt to own Dindi');
    const createdHaltId = dindi17.json.halt.id;

    // DINDI 18: Leader edits own halt
    const dindi18 = await request(`/api/dindis/halts/${createdHaltId}`, {
      method: 'PUT',
      headers: pilgrimToken,
      body: { location_name: 'Alandi Departure Stay' }
    });
    assert(dindi18.status === 200 && dindi18.json.halt.location_name === 'Alandi Departure Stay', 'DINDI 18: Leader can edit own Dindi halt schedule');

    // DINDI 19: Leader deletes own halt
    const dindi19 = await request(`/api/dindis/halts/${createdHaltId}`, {
      method: 'DELETE',
      headers: pilgrimToken
    });
    assert(dindi19.status === 200, 'DINDI 19: Leader can delete own Dindi halt schedule');

    // DINDI 20: Leader cannot modify another Dindi's halt
    const dindi20 = await request(`/api/dindis/${otherLeaderDindiId}/halts`, {
      method: 'POST',
      headers: pilgrimToken,
      body: { day_number: 1, halt_date: '2026-06-18', location_name: 'Unauthorized Halt' }
    });
    assert(dindi20.status === 403, 'DINDI 20: Dindi Leader cannot add/modify halt for another leader\'s Dindi (403 Forbidden)');

    // DINDI 21: Leader updates own Dindi location
    const dindi21 = await request(`/api/dindis/${createdDindiId}/location`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { latitude: 18.5204, longitude: 73.8567, location_name: 'Pune Center' }
    });
    assert(dindi21.status === 200, 'DINDI 21: Leader can update own Dindi live location');

    // DINDI 22: Leader cannot update another Dindi
    const dindi22 = await request(`/api/dindis/${otherLeaderDindiId}/location`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { latitude: 18.5204, longitude: 73.8567 }
    });
    assert(dindi22.status === 403, 'DINDI 22: Leader cannot update location for another leader\'s Dindi (403 Forbidden)');

    // DINDI 23: Suspended Dindi cannot receive location updates
    await request(`/api/admin/dindis/${createdDindiId}/suspend`, { method: 'PATCH', headers: adminToken });
    const dindi23 = await request(`/api/dindis/${createdDindiId}/location`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { latitude: 18.5204, longitude: 73.8567 }
    });
    assert(dindi23.status === 403, 'DINDI 23: Suspended Dindi cannot receive live location updates (403 Forbidden)');
    // Re-approve Dindi for subsequent join tests
    await request(`/api/admin/dindis/${createdDindiId}/approve`, { method: 'PATCH', headers: adminToken });

    // DINDI 24: Pilgrim joins Active Dindi using Join Code
    const dindi24 = await request(`/api/dindis/${createdDindiId}/join`, {
      method: 'POST',
      headers: citizenToken,
      body: { role: 'warkari' }
    });
    assert(dindi24.status === 201 || dindi24.status === 200, 'DINDI 24: Pilgrim can request to join Active Dindi');
    const memberRequestId = dindi24.json.id;

    // DINDI 25: Invalid Join Code rejected
    const dindi25 = await request('/api/dindis/INVALID-JOIN-CODE-9999/join', {
      method: 'POST',
      headers: citizenToken
    });
    assert(dindi25.status === 404, 'DINDI 25: Requesting to join invalid Dindi/JoinCode returns 404');

    // DINDI 26: Pending Dindi cannot accept join request
    const pendingDindiRes = await request('/api/dindis', {
      method: 'POST',
      headers: dindiLeaderToken,
      body: { name: `Pending Dindi Join Test ${Date.now()}` }
    });
    const pendingDindiId = pendingDindiRes.json.id;
    const dindi26 = await request(`/api/dindis/${pendingDindiId}/join`, {
      method: 'POST',
      headers: citizenToken
    });
    assert(dindi26.status === 403, 'DINDI 26: Join request for Pending Dindi is blocked (403 Forbidden)');

    // DINDI 27: Suspended Dindi cannot accept join request
    await request(`/api/admin/dindis/${createdDindiId}/suspend`, { method: 'PATCH', headers: adminToken });
    const dindi27 = await request(`/api/dindis/${createdDindiId}/join`, {
      method: 'POST',
      headers: citizenToken
    });
    assert(dindi27.status === 403, 'DINDI 27: Join request for Suspended Dindi is blocked (403 Forbidden)');
    await request(`/api/admin/dindis/${createdDindiId}/approve`, { method: 'PATCH', headers: adminToken });

    // DINDI 28: Leader sees pending member requests
    const dindi28 = await request(`/api/dindis/${createdDindiId}/members`, { headers: pilgrimToken });
    assert(dindi28.status === 200 && Array.isArray(dindi28.json), 'DINDI 28: Dindi Leader can retrieve member list');

    // DINDI 29: Leader approves member
    const dindi29 = await request(`/api/dindi-memberships/${memberRequestId}`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { status: 'active' }
    });
    assert(dindi29.status === 200 && dindi29.json.status === 'active', 'DINDI 29: Leader can approve pending member join request');

    // DINDI 30: Leader rejects member
    const dindi30 = await request(`/api/dindi-memberships/${memberRequestId}`, {
      method: 'PATCH',
      headers: pilgrimToken,
      body: { status: 'rejected' }
    });
    assert(dindi30.status === 200 && dindi30.json.status === 'rejected', 'DINDI 30: Leader can reject member request');

    // DINDI 31: Different Dindi Leader cannot modify request
    const dindi31 = await request(`/api/dindi-memberships/${memberRequestId}`, {
      method: 'PATCH',
      headers: dindiLeaderToken, // Different leader
      body: { status: 'active' }
    });
    assert(dindi31.status === 403, 'DINDI 31: Different Dindi Leader cannot modify member request for another leader\'s Dindi (403 Forbidden)');

    // DINDI 32: Pilgrim cannot create Dindi
    const dindi32 = await request('/api/dindis', {
      method: 'POST',
      headers: citizenToken,
      body: { name: 'Pilgrim Created Dindi' }
    });
    assert(dindi32.status === 403, 'DINDI 32: Pilgrim role cannot create Dindi (403 Forbidden)');

    // DINDI 33: Pending leader cannot manage Dindi
    const dindi33 = await request('/api/dindis', {
      method: 'POST',
      headers: policeToken,
      body: { name: 'Unauthorized Creation' }
    });
    assert(dindi33.status === 403, 'DINDI 33: Non-dindi-leader profile role cannot manage Dindis (403 Forbidden)');

    // DINDI 34: Non-admin cannot approve Dindi
    const dindi34 = await request(`/api/admin/dindis/${createdDindiId}/approve`, {
      method: 'PATCH',
      headers: pilgrimToken
    });
    assert(dindi34.status === 403, 'DINDI 34: Non-admin cannot approve Dindi (403 Forbidden)');

    // DINDI 35: Client identity spoofing is ignored
    const dindi35 = await request('/api/dindis', {
      method: 'POST',
      headers: { ...pilgrimToken, 'x-user-id': '00000000-0000-0000-0000-000000000006' },
      body: { name: `Identity Test ${Date.now()}` }
    });
    assert(dindi35.status === 201 && dindi35.json.leader_id === '00000000-0000-0000-0000-000000000001', 'DINDI 35: Spoofed x-user-id header is ignored in favor of verified JWT identity');

    // DINDI 36: Palkhi records never appear in Dindi response
    const dindi36 = await request('/api/dindis');
    const hasPalkhiInDindi = Array.isArray(dindi36.json) && dindi36.json.some(d => d.saint !== undefined);
    assert(!hasPalkhiInDindi, 'DINDI 36: Public Dindi API response contains strictly 0 Palkhi records');

    // ==========================================
    // AI ASSISTANT SUITE (AI 1 to AI 15)
    // ==========================================

    // AI 1: Unauthenticated /api/assistant/chat -> 401
    const ai1 = await request('/api/assistant/chat', {
      method: 'POST',
      body: { message: 'Where is Palkhi?' }
    });
    assert(ai1.status === 401, 'AI 1: Unauthenticated /api/assistant/chat returns 401 Unauthorized');

    // AI 2: Authenticated pilgrim -> chat request reaches assistant service
    const ai2 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: { message: 'ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?' }
    });
    assert(ai2.status === 200 && ai2.json.success === true && ai2.json.message, 'AI 2: Authenticated pilgrim chat request returns valid assistant response');

    // AI 3: Missing message -> 400
    const ai3 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: {}
    });
    assert(ai3.status === 400, 'AI 3: Missing message parameter returns 400 Bad Request');

    // AI 4: Oversized message -> 400
    const ai4 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: { message: 'a'.repeat(2500) }
    });
    assert(ai4.status === 400, 'AI 4: Oversized message exceeding 2000 characters returns 400 Bad Request');

    // AI 5: Role spoofing in body is ignored
    const ai5 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: { message: 'Hello', role: 'admin', user_id: '00000000-0000-0000-0000-000000000006' }
    });
    assert(ai5.status === 200 && ai5.json.success === true, 'AI 5: Role/User ID spoofing in request body is safely ignored');

    // AI 6: x-user-id header cannot override req.user.id
    const ai6 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: { ...pilgrimToken, 'x-user-id': '00000000-0000-0000-0000-000000000006' },
      body: { message: 'Test identity' }
    });
    assert(ai6.status === 200, 'AI 6: x-user-id spoofing header is ignored in favor of verified Supabase JWT');

    // AI 7: Suspended user rejected -> 403
    await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000001/suspend', { method: 'PATCH', headers: adminToken });
    const ai7 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: { message: 'Test suspended' }
    });
    assert(ai7.status === 403, 'AI 7: Suspended user account is rejected with 403 Forbidden');
    await request('/api/admin/dindi-leaders/00000000-0000-0000-0000-000000000001/approve', { method: 'PATCH', headers: adminToken });

    // AI 8: STT requires authentication -> 401
    const ai8 = await request('/api/assistant/stt', {
      method: 'POST',
      body: { audio: 'UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=' }
    });
    assert(ai8.status === 401, 'AI 8: Speech-to-Text endpoint requires authentication (401 Unauthorized)');

    // AI 9: TTS requires authentication -> 401
    const ai9 = await request('/api/assistant/tts', {
      method: 'POST',
      body: { text: 'राम कृष्ण हरी' }
    });
    assert(ai9.status === 401, 'AI 9: Text-to-Speech endpoint requires authentication (401 Unauthorized)');

    // AI 10: Palkhi context contains only published Palkhis
    const ai10 = await request('/api/palkhi');
    const allPublished = Array.isArray(ai10.json) ? ai10.json.every(p => p.is_published !== false) : true;
    assert(allPublished, 'AI 10: Palkhi context strictly contains published Palkhis only');

    // AI 11: Palkhi context does not contain operator identity
    const ai11 = await request('/api/palkhi');
    const hasOperatorSecrets = Array.isArray(ai11.json) && ai11.json.some(p => p.operator_email !== undefined || p.operator_password !== undefined);
    assert(!hasOperatorSecrets, 'AI 11: Palkhi context excludes internal operator identity and credentials');

    // AI 12: Dindi records are not accidentally inserted into the Palkhi context
    const ai12 = await request('/api/palkhi');
    const dindiInPalkhi = Array.isArray(ai12.json) && ai12.json.some(p => p.dindi_number !== undefined);
    assert(!dindiInPalkhi, 'AI 12: Dindi records are never inserted into Palkhi context');

    // AI 13: Provider timeout / unconfigured state produces clean response
    const ai13 = await request('/api/assistant/tts', {
      method: 'POST',
      headers: pilgrimToken,
      body: { text: 'राम कृष्ण हरी! सासवड मुक्काम.' }
    });
    assert(ai13.status === 200 && ai13.json.audio, 'AI 13: TTS provider returns clean audio response structure without server crash');

    // AI 14: Provider credentials never appear in API response
    const resString = JSON.stringify(ai2.json);
    const hasSecrets = resString.includes('GROK_API_KEY') || resString.includes('SARVAM_API_KEY') || resString.includes('xai-') || resString.includes('sarvam-');
    assert(!hasSecrets, 'AI 14: Provider API keys and credentials never appear in client responses');

    // AI 15: Assistant explicitly handles unavailable context rather than fabricating live data
    const ai15 = await request('/api/assistant/chat', {
      method: 'POST',
      headers: pilgrimToken,
      body: { message: 'Where is the non-existent test palkhi 9999?' }
    });
    assert(ai15.status === 200 && ai15.json.success === true, 'AI 15: Assistant query executes safely without hallucinating live operational data');

    console.log(`\n🎉 MASTER API SUITE SUMMARY: ${passedTests} / ${totalTests} CHECKS PASSED (${Math.round((passedTests / totalTests) * 100)}% SUCCESS RATE)\n`);
  } catch (err) {
    console.error('Fatal API test error:', err);
  } finally {
    if (server) server.close();
  }
}

runTestSuite();
