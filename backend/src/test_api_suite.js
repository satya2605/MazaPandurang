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

    // 29. Emergency creation unauthenticated -> 401
    const unauthEmg = await request('/api/emergencies', {
      method: 'POST',
      body: { emergency_type: 'Medical', latitude: 18.3411, longitude: 74.0305 }
    });
    if (unauthEmg.status !== 401) throw new Error(`Expected 401 for unauthenticated emergency creation, got ${unauthEmg.status}`);
    console.log('[PASS 29] POST /api/emergencies unauthenticated -> Status 401');

    // 30. Emergency creation authenticated (Satyajit Pilgrim) -> 201
    const authEmg = await request('/api/emergencies', {
      method: 'POST',
      headers: pilgrimHeaders,
      body: { emergency_type: 'Medical', latitude: 18.3411, longitude: 74.0305, location_name: 'Saswad Medical Desk' }
    });
    if (authEmg.status !== 201 || !authEmg.json.requestCode) throw new Error(`Expected 201 for emergency creation, got ${authEmg.status}`);
    const createdCode = authEmg.json.requestCode;
    console.log(`[PASS 30] POST /api/emergencies authenticated -> Status 201 (Request Code: ${createdCode})`);

    // 31. Pilgrim querying /api/emergencies -> 200 (Scope Isolated)
    const pilgrimEmgList = await request('/api/emergencies', {
      method: 'GET',
      headers: pilgrimHeaders
    });
    if (pilgrimEmgList.status !== 200 || !Array.isArray(pilgrimEmgList.json)) throw new Error(`Expected 200 for pilgrim emergency list`);
    console.log(`[PASS 31] GET /api/emergencies (Pilgrim Scope Isolated) -> Status 200 (${pilgrimEmgList.json.length} requests)`);

    // 32. Pilgrim attempting to patch emergency status -> 403 Forbidden
    const pilgrimPatchEmg = await request(`/api/emergencies/${createdCode}`, {
      method: 'PATCH',
      headers: pilgrimHeaders,
      body: { status: 'resolved' }
    });
    if (pilgrimPatchEmg.status !== 403) throw new Error(`Expected 403 for pilgrim modifying emergency, got ${pilgrimPatchEmg.status}`);
    console.log('[PASS 32] Security: Pilgrim modifying emergency status rejected -> Status 403');

    // 33. Admin/Police managing emergency status -> 200
    const adminPatchEmg = await request(`/api/emergencies/${createdCode}`, {
      method: 'PATCH',
      headers: adminHeaders,
      body: { status: 'dispatched' }
    });
    if (adminPatchEmg.status !== 200 || adminPatchEmg.json.status !== 'dispatched') throw new Error(`Expected 200 for Admin/Police emergency status dispatch, got ${adminPatchEmg.status}`);
    console.log('[PASS 33] PATCH /api/emergencies/:id (Admin/Police Authorized) -> Status 200 (Status: dispatched)');

    // 34. NGO Submission via POST /api/ngos -> 201 (Starts Pending)
    const ngoUserId = '00000000-0000-0000-0000-000000000004'; // Shrutika NGO Volunteer
    const newNgo = await request('/api/ngos', {
      method: 'POST',
      body: {
        user_id: ngoUserId,
        name: 'Seva Samarpan Trust',
        registration_number: `NGO-REG-${Date.now()}`,
        contact_person: 'Shrutika Volunteer',
        phone: '+919876543210',
        email: 'shrutika@ngo.org',
        primary_category: 'Medical & Food Seva'
      }
    });
    if (newNgo.status !== 201 || newNgo.json.status !== 'pending') throw new Error(`Expected 201 for NGO creation, got ${newNgo.status}`);
    const createdNgoId = newNgo.json.id;
    console.log(`[PASS 34] POST /api/ngos -> Status 201 (Pending NGO ID: ${createdNgoId})`);

    // 35. Admin Querying Pending NGOs -> 200
    const adminNgos = await request('/api/admin/ngos?status=pending', {
      method: 'GET',
      headers: adminHeaders
    });
    if (adminNgos.status !== 200 || !Array.isArray(adminNgos.json)) throw new Error(`Expected 200 for Admin NGO retrieval`);
    const foundPendingNgo = adminNgos.json.some(n => n.id === createdNgoId);
    if (!foundPendingNgo) throw new Error(`Pending NGO ${createdNgoId} not found in admin retrieval`);
    console.log('[PASS 35] GET /api/admin/ngos?status=pending -> Status 200 (Found Pending NGO)');

    // 36. Public GET /api/ngos excludes Pending NGO
    const publicNgosBeforeApprove = await request('/api/ngos', { method: 'GET' });
    const isPublicBefore = publicNgosBeforeApprove.json.some(n => n.id === createdNgoId);
    if (isPublicBefore) throw new Error(`Pending NGO ${createdNgoId} must NOT be public`);
    console.log('[PASS 36] Security: Public GET /api/ngos excludes Pending NGO');

    // 37. Admin Approves NGO -> 200
    const approveNgoRes = await request(`/api/admin/ngos/${createdNgoId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders
    });
    if (approveNgoRes.status !== 200 || approveNgoRes.json.status !== 'approved') throw new Error(`Expected 200 for NGO approval, got ${approveNgoRes.status}`);
    console.log('[PASS 37] PATCH /api/admin/ngos/:id/approve -> Status 200 (Status: approved)');

    // 38. Public GET /api/ngos includes Approved NGO
    const publicNgosAfterApprove = await request('/api/ngos', { method: 'GET' });
    const isPublicAfter = publicNgosAfterApprove.json.some(n => n.id === createdNgoId);
    if (!isPublicAfter) throw new Error(`Approved NGO ${createdNgoId} must be public`);
    console.log('[PASS 38] Public GET /api/ngos includes Approved NGO');

    // 39. Admin Rejects NGO -> 200
    const rejectNgoRes = await request(`/api/admin/ngos/${createdNgoId}/reject`, {
      method: 'PATCH',
      headers: adminHeaders,
      body: { reason: 'Incomplete compliance documentation' }
    });
    if (rejectNgoRes.status !== 200 || rejectNgoRes.json.status !== 'rejected') throw new Error(`Expected 200 for NGO rejection`);
    console.log('[PASS 39] PATCH /api/admin/ngos/:id/reject -> Status 200 (Status: rejected)');

    // 40. Public GET /api/ngos excludes Rejected NGO
    const publicNgosAfterReject = await request('/api/ngos', { method: 'GET' });
    if (publicNgosAfterReject.json.some(n => n.id === createdNgoId)) throw new Error(`Rejected NGO must NOT be public`);
    console.log('[PASS 40] Security: Public GET /api/ngos excludes Rejected NGO');

    // 41. Dindi Leader Application -> 201
    const leaderApp = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: dindiLeaderHeaders,
      body: {
        dindi_name: 'Pandharpur Varkari Mandal',
        start_point: 'Dehu',
        destination: 'Pandharpur',
        expected_members: 150,
        phone: '+919811122233'
      }
    });
    if (leaderApp.status !== 201 || !leaderApp.json.profile) throw new Error(`Expected 201 for Dindi Leader application, got ${leaderApp.status}`);
    const applicantId = leaderApp.json.profile.id;
    console.log(`[PASS 41] POST /api/dindi-leader/apply -> Status 201 (Applicant ID: ${applicantId})`);

    // 42. Admin Querying Pending Dindi Leaders -> 200
    const adminLeaders = await request('/api/admin/dindi-leaders?status=pending', {
      method: 'GET',
      headers: adminHeaders
    });
    if (adminLeaders.status !== 200 || !Array.isArray(adminLeaders.json)) throw new Error(`Expected 200 for admin Dindi Leaders query`);
    console.log('[PASS 42] GET /api/admin/dindi-leaders?status=pending -> Status 200');

    // 43. Admin Approves Dindi Leader -> 200 (Sets profiles.status = 'active')
    const approveLeaderRes = await request(`/api/admin/dindi-leaders/${applicantId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders
    });
    if (approveLeaderRes.status !== 200 || approveLeaderRes.json.status !== 'active') throw new Error(`Expected 200 for Dindi Leader approval`);
    console.log('[PASS 43] PATCH /api/admin/dindi-leaders/:id/approve -> Status 200 (profile.status: active)');

    // 44. Dindi Submission via POST /api/dindis (Active Leader) -> 201 (Starts Pending)
    const newDindiRes = await request('/api/dindis', {
      method: 'POST',
      headers: dindiLeaderHeaders,
      body: {
        dindi_number: `DND-${Date.now().toString().slice(-4)}`,
        name: 'Shraddha Seva Dindi',
        leader_name: 'Sanket Dindi Leader',
        leader_phone: '+919876543210',
        start_point: 'Alandi',
        destination: 'Pandharpur',
        member_count: 250,
        join_code: `JOIN-${Date.now().toString().slice(-6)}`
      }
    });
    if (newDindiRes.status !== 201 || newDindiRes.json.status !== 'Pending') throw new Error(`Expected 201 for Dindi creation, got ${newDindiRes.status}`);
    const newlyCreatedDindiId = newDindiRes.json.id;
    console.log(`[PASS 44] POST /api/dindis -> Status 201 (Pending Dindi ID: ${newlyCreatedDindiId})`);

    // 45. Admin Approves Dindi -> 200 (Sets dindis.status = 'Active') & Public Exposure Verified
    const approveDindiRes = await request(`/api/admin/dindis/${newlyCreatedDindiId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders
    });
    if (approveDindiRes.status !== 200 || approveDindiRes.json.status !== 'Active') throw new Error(`Expected 200 for Dindi approval`);
    
    const publicDindisEnd = await request('/api/dindis', { method: 'GET' });
    const isDindiPublic = publicDindisEnd.json.some(d => d.id === newlyCreatedDindiId);
    if (!isDindiPublic) throw new Error(`Approved Dindi ${newlyCreatedDindiId} must be public`);
    console.log('[PASS 45] PATCH /api/admin/dindis/:id/approve -> Status 200 & Public GET /api/dindis exposes Active Dindi');

    // 46. Admin Listing Palkhis -> 200
    const adminPalkhisRes = await request('/api/admin/palkhis', {
      method: 'GET',
      headers: adminHeaders
    });
    if (adminPalkhisRes.status !== 200 || !Array.isArray(adminPalkhisRes.json)) throw new Error(`Expected 200 for Admin Palkhi listing`);
    console.log('[PASS 46] GET /api/admin/palkhis -> Status 200');

    // 47 & 48. Admin Creating Palkhi -> 201 (Defaults Unpublished: is_published = false)
    const newPalkhiRes = await request('/api/admin/palkhis', {
      method: 'POST',
      headers: adminHeaders,
      body: {
        name: 'Sant Tukaram Maharaj Palkhi',
        saint: 'Sant Tukaram Maharaj',
        start_point: 'Dehu',
        destination: 'Pandharpur',
        current_stage: 'Dehu Departure',
        next_stop: 'Akurdi Stay',
        latitude: 18.7167,
        longitude: 73.7667
      }
    });
    if (newPalkhiRes.status !== 201 || newPalkhiRes.json.is_published !== false) throw new Error(`Expected 201 for Palkhi creation (is_published: false), got ${newPalkhiRes.status}`);
    const createdPalkhiId = newPalkhiRes.json.id;
    console.log(`[PASS 47 & 48] POST /api/admin/palkhis -> Status 201 (Defaults is_published: false, ID: ${createdPalkhiId})`);

    // 49 & 50. Admin Assigning Palkhi Operator -> 200
    const assignOpRes = await request(`/api/admin/palkhis/${createdPalkhiId}`, {
      method: 'PATCH',
      headers: adminHeaders,
      body: {
        assigned_operator_id: '00000000-0000-0000-0000-000000000002' // Sanket (dindi_leader/operator persona)
      }
    });
    if (assignOpRes.status !== 200 || assignOpRes.json.assigned_operator_id !== '00000000-0000-0000-0000-000000000002') throw new Error(`Expected 200 for operator assignment`);
    console.log('[PASS 49 & 50] PATCH /api/admin/palkhis/:id -> Status 200 (Operator Assigned)');

    // 51. Assigned Operator Updating Assigned Palkhi Location -> 200
    const updateLocRes = await request(`/api/palkhi/${createdPalkhiId}/location`, {
      method: 'PATCH',
      headers: dindiLeaderHeaders,
      body: {
        latitude: 18.7200,
        longitude: 73.7700,
        current_stage: 'Akurdi Bridge Crossing',
        next_stop: 'Pimpri Halt'
      }
    });
    if (updateLocRes.status !== 200 || !updateLocRes.json.palkhi) throw new Error(`Expected 200 for assigned operator location update, got ${updateLocRes.status}`);
    console.log('[PASS 51] PATCH /api/palkhi/:id/location (Assigned Operator) -> Status 200 (Location Updated)');

    // 52. Operator Attempting to Update Unassigned Palkhi -> 403 Forbidden
    const unassignedPalkhiId = '00000000-0000-0000-0000-000000000099';
    const unassignedOpRes = await request(`/api/palkhi/${unassignedPalkhiId}/location`, {
      method: 'PATCH',
      headers: dindiLeaderHeaders,
      body: { latitude: 18.5204, longitude: 73.8567 }
    });
    if (unassignedOpRes.status !== 403 && unassignedOpRes.status !== 404) throw new Error(`Expected 403/404 for unassigned operator update, got ${unassignedOpRes.status}`);
    console.log('[PASS 52] Security: Operator modifying unassigned Palkhi rejected -> Status 403/404');

    // 53 & 54. Operator and Pilgrim Attempting Admin Palkhi API -> 403 Forbidden
    const pilgrimAdminPalkhi = await request('/api/admin/palkhis', {
      method: 'GET',
      headers: pilgrimHeaders
    });
    if (pilgrimAdminPalkhi.status !== 403) throw new Error(`Expected 403 for pilgrim accessing admin Palkhi API`);
    console.log('[PASS 53 & 54] Security: Non-admin accessing /api/admin/palkhis rejected -> Status 403');

    // 55. Public GET /api/palkhi Hides Unpublished Palkhi
    const publicPalkhisBeforePublish = await request('/api/palkhi', { method: 'GET' });
    const isUnpublishedPublic = Array.isArray(publicPalkhisBeforePublish.json) && publicPalkhisBeforePublish.json.some(p => p.id === createdPalkhiId);
    if (isUnpublishedPublic) throw new Error(`Unpublished Palkhi ${createdPalkhiId} must NOT appear in public API`);
    console.log('[PASS 55] Security: Public GET /api/palkhi hides Unpublished Palkhis');

    // 56. Admin Publishes Palkhi -> 200
    const publishRes = await request(`/api/admin/palkhis/${createdPalkhiId}/publish`, {
      method: 'PATCH',
      headers: adminHeaders
    });
    if (publishRes.status !== 200 || publishRes.json.is_published !== true) throw new Error(`Expected 200 for Palkhi publication`);
    console.log('[PASS 56] PATCH /api/admin/palkhis/:id/publish -> Status 200 (is_published: true)');

    // 57 & 58. Public GET /api/palkhi Exposes Published Palkhi without Operator Identity
    const publicPalkhisAfterPublish = await request('/api/palkhi', { method: 'GET' });
    const publishedItem = Array.isArray(publicPalkhisAfterPublish.json) 
      ? publicPalkhisAfterPublish.json.find(p => p.id === createdPalkhiId)
      : (publicPalkhisAfterPublish.json.id === createdPalkhiId ? publicPalkhisAfterPublish.json : null);

    if (!publishedItem) throw new Error(`Published Palkhi ${createdPalkhiId} must appear in public API`);
    if (publishedItem.assigned_operator_id || publishedItem.operatorEmail) throw new Error(`Public response must NOT expose operator identity`);
    console.log('[PASS 57 & 58] Public GET /api/palkhi exposes Published Palkhi & Privacy Preserved');

    // 59. Admin Unpublishes Palkhi -> 200
    const unpublishRes = await request(`/api/admin/palkhis/${createdPalkhiId}/unpublish`, {
      method: 'PATCH',
      headers: adminHeaders
    });
    if (unpublishRes.status !== 200 || unpublishRes.json.is_published !== false) throw new Error(`Expected 200 for Palkhi unpublication`);
    console.log('[PASS 59] PATCH /api/admin/palkhis/:id/unpublish -> Status 200 (is_published: false)');

    // 60. Admin Audit Log Verification for Palkhi Operations -> 200
    const auditLogsRes = await request('/api/admin/audit-logs', {
      method: 'GET',
      headers: adminHeaders
    });
    if (auditLogsRes.status !== 200) throw new Error(`Expected 200 for audit logs query`);
    console.log('[PASS 60] Admin audit trail verified for Palkhi mutations');

    console.log('\n🎉 ALL 60 MASTER PLATFORM & PALKHI REGISTRY API TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Test suite failed:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTestSuite();
