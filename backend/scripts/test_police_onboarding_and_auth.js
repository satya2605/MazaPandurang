/**
 * ============================================================================
 * MAZA PANDURANG — POLICE AUTHORITY ONBOARDING, DATABASE PERSISTENCE & AUTH TEST SUITE
 * ============================================================================
 * Covers all 10 required test criteria:
 * TEST 1: User registers as Police Authority -> profiles.role == 'police_authority'
 * TEST 2: Police registration data creates corresponding police_profiles record
 * TEST 3: Fetching current profile returns role == 'police_authority' (not 'pilgrim')
 * TEST 4: Police Authority REST API Registration Endpoint (/api/police/register)
 * TEST 5: Security gate prevents unauthorized status escalation
 * TEST 6: Admin moderation lists registered police officers (/api/admin/police-officers)
 * TEST 7: Admin approval transitions status to "active" while preserving role "police_authority"
 * TEST 8: Police profile details (station, badge, designation) are retrievable
 * TEST 9: Foreign key integrity check (No orphan police_profiles)
 * TEST 10: Idempotent upsert prevents duplicate police_profiles on re-registration
 * ============================================================================
 */

process.env.NODE_ENV = 'test';
process.env.NO_LISTEN = 'true';

import http from 'http';
import assert from 'assert';
import app from '../src/server.js';
import { getSupabaseClient } from '../src/db/supabase.js';

let server;
const PORT = 3012;
const BASE_URL = `http://localhost:${PORT}`;

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

async function runPoliceTestSuite() {
  server = app.listen(PORT);
  console.log('🚀 Running Police Authority Database & API Lifecycle Test Suite...\n');

  try {
    const client = getSupabaseClient();
    const testOfficerId = '00000000-0000-0000-0000-000000000003'; // Yogeshwari test persona
    const testOfficerEmail = 'yogeshwari@mazapandurang.local';
    const testPoliceBadge = 'POL-MH-9988';
    const testOfficerName = 'Inspector Yogeshwari';
    const testStation = 'Saswad Central Police Station';

    // ── TEST 1: Base Profile Role Assignment ──────────────────────────────
    console.log('--- TEST 1: Base Profile Role Assignment ---');
    const { data: prof1, error: err1 } = await client
      .from('profiles')
      .upsert({
        id: testOfficerId,
        email: testOfficerEmail,
        display_name: testOfficerName,
        role: 'police_authority',
        status: 'pending',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'id' })
      .select()
      .single();

    assert(!err1, `Failed to upsert profile: ${err1?.message}`);
    assert.strictEqual(prof1.role, 'police_authority', 'TEST 1 FAIL: Profile role must be police_authority');
    assert.strictEqual(prof1.status, 'pending', 'TEST 1 FAIL: Initial profile status should be pending');
    console.log('  ✅ [PASS 1] profiles.role is strictly "police_authority" and status is "pending"');

    // ── TEST 2: Corresponding police_profiles Record Persistence ───────────────
    console.log('\n--- TEST 2: police_profiles Persistence ---');
    const { data: polProf2, error: err2 } = await client
      .from('police_profiles')
      .upsert({
        user_id: testOfficerId,
        police_id: testPoliceBadge,
        name: testOfficerName,
        designation: 'Sub-Inspector',
        station_name: testStation,
        phone: '+919876543212',
        role: 'POLICE_OFFICER',
        status: 'PENDING',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'user_id' })
      .select()
      .single();

    assert(!err2, `Failed to upsert police_profile: ${err2?.message}`);
    assert.strictEqual(polProf2.user_id, testOfficerId, 'TEST 2 FAIL: user_id foreign key must match');
    assert.strictEqual(polProf2.police_id, testPoliceBadge, 'TEST 2 FAIL: police_id badge must match');
    assert.strictEqual(polProf2.station_name, testStation, 'TEST 2 FAIL: station_name must match');
    console.log('  ✅ [PASS 2] police_profiles record persisted with badge, station, designation, and user_id foreign key');

    // ── TEST 3: Profile Lookup Returns police_authority (Not Pilgrim) ────────────
    console.log('\n--- TEST 3: Profile Query Role Verification ---');
    const { data: fetchedProf, error: err3 } = await client
      .from('profiles')
      .select('*, police_profiles(*)')
      .eq('id', testOfficerId)
      .single();

    assert(!err3, `Failed to fetch profile: ${err3?.message}`);
    assert.strictEqual(fetchedProf.role, 'police_authority', 'TEST 3 FAIL: Fetched role must be police_authority');
    assert.notStrictEqual(fetchedProf.role, 'pilgrim', 'TEST 3 FAIL: Fetched role must NOT be pilgrim');
    assert(fetchedProf.police_profiles !== null, 'TEST 3 FAIL: police_profiles joined relation must exist');
    console.log('  ✅ [PASS 3] Fetched profile returns role "police_authority" and not "pilgrim"');

    // ── TEST 4: Police Authority REST API Registration Endpoint ──────────────────
    console.log('\n--- TEST 4: Backend REST API Registration ---');
    const applicantId = '00000000-0000-0000-0000-000000000005'; // Gauri Citizen applying as Police
    const applicantEmail = 'gauri@mazapandurang.local';
    
    // Seed initial profile as local_citizen
    await client.from('profiles').upsert({
      id: applicantId,
      email: applicantEmail,
      display_name: 'Gauri Citizen',
      role: 'local_citizen',
      status: 'active',
      updated_at: new Date().toISOString(),
    }, { onConflict: 'id' });

    // Use police registration endpoint
    const regRes = await request('/api/police/register', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer test-jwt-${applicantId}`,
      },
      body: {
        police_id: 'POL-MH-7788',
        name: 'Gauri Officer',
        designation: 'Patrol Officer',
        station_name: 'Pandharpur Sector 2',
        phone: '+919876543214',
      },
    });

    assert.strictEqual(regRes.status, 201, `TEST 4 FAIL: Registration response status was ${regRes.status} (msg: ${JSON.stringify(regRes.json || regRes.text)})`);
    assert.strictEqual(regRes.json.profile.role, 'police_authority', 'TEST 4 FAIL: Role must be updated to police_authority');
    assert.strictEqual(regRes.json.police_profile.police_id, 'POL-MH-7788', 'TEST 4 FAIL: police_id badge must be set');
    console.log('  ✅ [PASS 4] POST /api/police/register successfully transitions profile to "police_authority" and creates police_profiles record');

    // ── TEST 5: Unauthenticated User Cannot Register Police Profile ──────────────
    console.log('\n--- TEST 5: Authentication Security Gate ---');
    const unauthRes = await request('/api/police/register', {
      method: 'POST',
      body: { name: 'Spoofed Officer' },
    });
    assert.strictEqual(unauthRes.status, 401, 'TEST 5 FAIL: Unauthenticated registration must return 401');
    console.log('  ✅ [PASS 5] Unauthenticated request to /api/police/register rejected with 401 Unauthorized');

    // ── TEST 6: Admin Moderation Lists Police Officers ───────────────────────────
    console.log('\n--- TEST 6: Admin Police Moderation List ---');
    const adminHeaders = {
      'Authorization': 'Bearer test-jwt-00000000-0000-0000-0000-000000000006', // Admin persona
    };
    const adminListRes = await request('/api/admin/police-officers', {
      headers: adminHeaders,
    });
    assert.strictEqual(adminListRes.status, 200, 'TEST 6 FAIL: Admin police list must return 200');
    assert(Array.isArray(adminListRes.json) && adminListRes.json.length > 0, 'TEST 6 FAIL: Admin should receive police officers list');
    console.log(`  ✅ [PASS 6] Admin retrieved ${adminListRes.json.length} registered police officers`);

    // ── TEST 7: Admin Approves Police Officer -> Status Becomes Active ────────────
    console.log('\n--- TEST 7: Admin Approval Workflow ---');
    const approveRes = await request(`/api/admin/police-officers/${applicantId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders,
    });
    assert.strictEqual(approveRes.status, 200, 'TEST 7 FAIL: Admin approve must return 200');
    assert.strictEqual(approveRes.json.status, 'active', 'TEST 7 FAIL: Status must become active');
    assert.strictEqual(approveRes.json.role, 'police_authority', 'TEST 7 FAIL: Role must remain police_authority');

    const { data: polProfApproved } = await client
      .from('police_profiles')
      .select('*')
      .eq('user_id', applicantId)
      .single();
    assert.strictEqual(polProfApproved.status, 'ACTIVE', 'TEST 7 FAIL: police_profiles status must be ACTIVE');
    console.log('  ✅ [PASS 7] Admin approval transitions status to "active" while preserving role "police_authority"');

    // ── TEST 8: Police Profile Data Fetch ────────────────────────────────────────
    console.log('\n--- TEST 8: Police Profile Retrieval ---');
    const fetchProfRes = await request(`/api/police/profile/${applicantId}`);
    assert.strictEqual(fetchProfRes.status, 200, 'TEST 8 FAIL: GET /api/police/profile/:id must return 200');
    assert.strictEqual(fetchProfRes.json.station_name, 'Pandharpur Sector 2', 'TEST 8 FAIL: Station name must match');
    console.log('  ✅ [PASS 8] Police profile data retrieved with full station and badge details');

    // ── TEST 9: Foreign Key Integrity Check (No Orphaned Records) ────────────────
    console.log('\n--- TEST 9: Foreign Key Relationship Integrity ---');
    const { data: allPoliceProfiles } = await client.from('police_profiles').select('user_id');
    const { data: allProfiles } = await client.from('profiles').select('id');
    const profileIdSet = new Set(allProfiles.map(p => p.id));
    
    for (const pp of allPoliceProfiles) {
      assert(profileIdSet.has(pp.user_id), `TEST 9 FAIL: Orphaned police_profile found with user_id: ${pp.user_id}`);
    }
    console.log('  ✅ [PASS 9] Foreign key integrity verified: 0 orphaned police_profiles records');

    // ── TEST 10: Idempotent Upsert (No Duplicate Records) ────────────────────────
    console.log('\n--- TEST 10: Idempotent Registration Updates ---');
    const updateRes = await request('/api/police/register', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer test-jwt-${applicantId}`,
      },
      body: {
        designation: 'Senior Inspector',
        station_name: 'Pandharpur Sector 1 Head Station',
      },
    });
    assert.strictEqual(updateRes.status, 201, 'TEST 10 FAIL: Re-register/update must succeed');
    
    const { data: checkDuplicates } = await client
      .from('police_profiles')
      .select('id')
      .eq('user_id', applicantId);
    assert.strictEqual(checkDuplicates.length, 1, 'TEST 10 FAIL: Exactly 1 police_profile must exist for user');
    console.log('  ✅ [PASS 10] Idempotent upsert verified: exactly 1 police_profile per officer after repeated calls');

    // Cleanup and restore Gauri citizen state
    await client.from('police_profiles').delete().eq('user_id', applicantId);
    await client.from('profiles').update({ role: 'local_citizen', status: 'active', display_name: 'Gauri (Local Citizen)' }).eq('id', applicantId);

    // Restore Yogeshwari active police state
    await client.from('profiles').update({ role: 'police_authority', status: 'active', display_name: 'Yogeshwari (Police Authority)' }).eq('id', testOfficerId);
    await client.from('police_profiles').upsert({
      user_id: testOfficerId,
      police_id: 'POL-MH-9988',
      name: 'Yogeshwari (Sub-Inspector)',
      designation: 'Sub-Inspector',
      station_name: 'Saswad Central Station',
      phone: '+919876543212',
      role: 'POLICE_OFFICER',
      status: 'ACTIVE',
      updated_at: new Date().toISOString(),
    }, { onConflict: 'user_id' });

    console.log('\n🎉 ALL 10 POLICE AUTHORITY INTEGRATION & DATABASE VERIFICATION CHECKS PASSED CLEANLY!\n');
  } finally {
    if (server) server.close();
  }
}

runPoliceTestSuite().catch((err) => {
  console.error('\n❌ Police Test Suite Error:', err);
  if (server) server.close();
  process.exit(1);
});
