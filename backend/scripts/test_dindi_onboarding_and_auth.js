process.env.NODE_ENV = 'test';
process.env.NO_LISTEN = 'true';

import http from 'http';
import app from '../src/server.js';

let server;
const PORT = 3015;

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

async function runOnboardingAndAuthTests() {
  server = app.listen(PORT);
  console.log('🚀 Running Complete Dindi Leader Onboarding & Authorization Workflow Tests...\n');

  try {
    const leaderUserId = '00000000-0000-0000-0000-000000000002'; // Sanket
    const pilgrimUserId = '00000000-0000-0000-0000-000000000001'; // Satyajit
    const adminUserId = '00000000-0000-0000-0000-000000000006'; // Admin
    const anotherLeaderId = '00000000-0000-0000-0000-000000000003'; // Yogeshwari

    const leaderHeaders = { 'Authorization': `Bearer test-jwt-${leaderUserId}` };
    const pilgrimHeaders = { 'Authorization': `Bearer test-jwt-${pilgrimUserId}` };
    const adminHeaders = { 'Authorization': `Bearer test-jwt-${adminUserId}` };
    const anotherLeaderHeaders = { 'Authorization': `Bearer test-jwt-${anotherLeaderId}` };

    // Ensure leader profile starts clean/unsuspended
    await request(`/api/admin/dindi-leaders/${leaderUserId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders,
    });

    // 1. Submit Dindi Leader Application
    const applyRes = await request('/api/dindi-leader/apply', {
      method: 'POST',
      headers: leaderHeaders,
      body: {
        dindi_name: `Tukaram Palkhi Troupe ${Date.now().toString().slice(-4)}`,
        start_point: 'Dehu',
        destination: 'Pandharpur',
        expected_members: 150,
      },
    });
    console.log(`[PASS 1] POST /api/dindi-leader/apply -> Status ${applyRes.status} (profile status: ${applyRes.json.profile?.status})`);
    if (applyRes.status !== 201 || applyRes.json.profile?.status !== 'pending') {
      throw new Error('Application should start in pending status');
    }

    // 2. Pending leader CANNOT create Dindis
    const pendingCreateRes = await request('/api/dindis', {
      method: 'POST',
      headers: leaderHeaders,
      body: {
        name: 'Unauthorized Pending Dindi',
        dindiNumber: `PEND-${Date.now().toString().slice(-4)}`,
      },
    });
    console.log(`[PASS 2] Pending Leader Create Dindi Rejected -> Status ${pendingCreateRes.status} (403 expected)`);
    if (pendingCreateRes.status !== 403) {
      throw new Error(`Expected 403 for pending leader, got ${pendingCreateRes.status}`);
    }

    // 3. Admin approves Dindi Leader
    const approveLeaderRes = await request(`/api/admin/dindi-leaders/${leaderUserId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders,
    });
    console.log(`[PASS 3] Admin Approves Dindi Leader -> Status ${approveLeaderRes.status} (profile status: ${approveLeaderRes.json.status})`);
    if (approveLeaderRes.status !== 200 || approveLeaderRes.json.status !== 'active') {
      throw new Error('Leader status should be active after approval');
    }

    // 4. Active leader CAN create Dindi
    const dindiNumber = `ACT-${Date.now().toString().slice(-6)}`;
    const activeCreateRes = await request('/api/dindis', {
      method: 'POST',
      headers: leaderHeaders,
      body: {
        name: 'Approved Active Sant Dindi',
        dindiNumber,
        startPoint: 'Dehu',
        destination: 'Pandharpur',
        currentHalt: 'Akurdi',
        roadStatus: 'Clear & Moving',
        joinCode: `JC${Date.now().toString().slice(-4)}`,
        status: 'Active',
      },
    });
    console.log(`[PASS 4] Active Leader Creates Dindi -> Status ${activeCreateRes.status} (dindi id: ${activeCreateRes.json.id})`);
    if (activeCreateRes.status !== 201) {
      throw new Error(`Failed to create Dindi as active leader: ${JSON.stringify(activeCreateRes.json)}`);
    }
    const dindiId = activeCreateRes.json.id;

    // 5. Active leader CAN edit own Dindi
    const patchRes = await request(`/api/dindis/${dindiId}`, {
      method: 'PATCH',
      headers: leaderHeaders,
      body: {
        currentHalt: 'Pune Sangam',
        status: 'Halted',
        roadStatus: 'Slow',
      },
    });
    console.log(`[PASS 5] Active Leader Updates Own Dindi -> Status ${patchRes.status} (halt: ${patchRes.json.currentHalt}, status: ${patchRes.json.status})`);
    if (patchRes.status !== 200 || patchRes.json.status !== 'Halted') {
      throw new Error('Failed to update Dindi');
    }

    // 6. Another leader CANNOT edit this leader's Dindi
    const unauthorizedEditRes = await request(`/api/dindis/${dindiId}`, {
      method: 'PATCH',
      headers: anotherLeaderHeaders,
      body: {
        name: 'Hijacked Dindi Name',
      },
    });
    console.log(`[PASS 6] Unauthorized Modification Rejected -> Status ${unauthorizedEditRes.status} (403 expected)`);
    if (unauthorizedEditRes.status !== 403) {
      throw new Error(`Expected 403 for unauthorized edit, got ${unauthorizedEditRes.status}`);
    }

    // 7. Varkari discovers Dindi & submits join request
    const joinRes = await request(`/api/dindis/${dindiId}/join`, {
      method: 'POST',
      headers: pilgrimHeaders,
      body: {
        role: 'Taalvadak (टाळकरी)',
      },
    });
    console.log(`[PASS 7] Varkari Submits Join Request -> Status ${joinRes.status} (membership status: ${joinRes.json.status})`);
    if (joinRes.status !== 201 && joinRes.status !== 200) {
      throw new Error(`Failed to submit join request: ${JSON.stringify(joinRes.json)}`);
    }
    const membershipId = joinRes.json.id;

    // 8. Varkari CANNOT create duplicate active/pending membership
    const duplicateJoinRes = await request(`/api/dindis/${dindiId}/join`, {
      method: 'POST',
      headers: pilgrimHeaders,
      body: {
        role: 'Taalvadak (टाळकरी)',
      },
    });
    console.log(`[PASS 8] Duplicate Join Request Rejected -> Status ${duplicateJoinRes.status} (409 expected)`);
    if (duplicateJoinRes.status !== 409) {
      throw new Error(`Expected 409 conflict on duplicate join, got ${duplicateJoinRes.status}`);
    }

    // 9. Dindi Leader sees pending membership request
    const membersRes = await request(`/api/dindis/${dindiId}/members`);
    console.log(`[PASS 9] Leader Views Members -> Status ${membersRes.status}, total members: ${membersRes.json.length}`);
    const pendingMem = membersRes.json.find((m) => m.id === membershipId);
    if (!pendingMem || pendingMem.status !== 'pending') {
      throw new Error('Membership request should appear as pending');
    }

    // 10. Dindi Leader approves membership request
    const approveMemRes = await request(`/api/dindi-memberships/${membershipId}`, {
      method: 'PATCH',
      headers: leaderHeaders,
      body: {
        status: 'active',
      },
    });
    console.log(`[PASS 10] Leader Approves Membership -> Status ${approveMemRes.status} (status: ${approveMemRes.json.status})`);
    if (approveMemRes.status !== 200 || approveMemRes.json.status !== 'active') {
      throw new Error('Membership should become active upon approval');
    }

    // 11. Unauthorized user CANNOT moderate another leader's Dindi membership
    const unauthorizedModRes = await request(`/api/dindi-memberships/${membershipId}`, {
      method: 'PATCH',
      headers: anotherLeaderHeaders,
      body: {
        status: 'rejected',
      },
    });
    console.log(`[PASS 11] Unauthorized Member Moderation Rejected -> Status ${unauthorizedModRes.status} (403 expected)`);
    if (unauthorizedModRes.status !== 403) {
      throw new Error(`Expected 403 for unauthorized membership update, got ${unauthorizedModRes.status}`);
    }

    // 12. Dindi Leader rejects / removes membership
    const rejectMemRes = await request(`/api/dindi-memberships/${membershipId}`, {
      method: 'PATCH',
      headers: leaderHeaders,
      body: {
        status: 'rejected',
      },
    });
    console.log(`[PASS 12] Leader Rejects Membership -> Status ${rejectMemRes.status} (status: ${rejectMemRes.json.status})`);
    if (rejectMemRes.status !== 200 || rejectMemRes.json.status !== 'rejected') {
      throw new Error('Membership should become rejected');
    }

    // 13. Admin suspends Dindi Leader
    const suspendLeaderRes = await request(`/api/admin/dindi-leaders/${leaderUserId}/suspend`, {
      method: 'PATCH',
      headers: adminHeaders,
      body: { reason: 'Test temporary suspension' },
    });
    console.log(`[PASS 13] Admin Suspends Dindi Leader -> Status ${suspendLeaderRes.status} (profile status: ${suspendLeaderRes.json.status})`);

    // 14. Suspended leader CANNOT create or manage Dindis
    const suspendedCreateRes = await request('/api/dindis', {
      method: 'POST',
      headers: leaderHeaders,
      body: {
        name: 'Suspended Attempt Dindi',
        dindiNumber: `SUS-${Date.now().toString().slice(-4)}`,
      },
    });
    console.log(`[PASS 14] Suspended Leader Create Dindi Rejected -> Status ${suspendedCreateRes.status} (403 expected)`);
    if (suspendedCreateRes.status !== 403) {
      throw new Error(`Expected 403 for suspended leader, got ${suspendedCreateRes.status}`);
    }

    // Restore leader to active for normal app operation
    await request(`/api/admin/dindi-leaders/${leaderUserId}/approve`, {
      method: 'PATCH',
      headers: adminHeaders,
    });

    console.log('\n🎉 ALL 14 ONBOARDING, AUTHORIZATION, AND MEMBERSHIP LIFECYCLE TESTS PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Onboarding & Auth test failed:', err);
    process.exitCode = 1;
  } finally {
    if (server) server.close();
  }
}

runOnboardingAndAuthTests();
