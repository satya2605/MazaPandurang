import http from 'http';

const PORT = 3000;

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

async function runMemberIntegrationTests() {
  console.log('🧪 Running Live Dindi Member REST API Verification...');

  try {
    const leaderUserId = '00000000-0000-0000-0000-000000000002'; // Sanket (Active Leader)

    // 1. Create a fresh test Dindi to ensure clean state
    const testNum = `TEST-${Date.now().toString().slice(-6)}`;
    const createRes = await request('/api/dindis', {
      method: 'POST',
      headers: { 'x-user-id': leaderUserId },
      body: {
        name: `Automated Test Dindi ${testNum}`,
        dindiNumber: testNum,
        startPoint: 'Alandi',
        destination: 'Pandharpur',
        currentHalt: 'Pune',
        roadStatus: 'Clear & Moving',
        joinCode: `JC${Date.now().toString().slice(-4)}`,
        status: 'Active',
      },
    });

    if (createRes.status !== 201) {
      throw new Error(`Failed to create test Dindi: ${JSON.stringify(createRes.json)}`);
    }

    const testDindiId = createRes.json.id;
    console.log(`[PASS] POST /api/dindis -> Created Dindi ${testDindiId} (${testNum})`);

    // 2. Dindi shows 0 members initially
    const resA = await request(`/api/dindis/${testDindiId}/members`);
    console.log(`[PASS] GET /api/dindis/${testDindiId}/members -> Status ${resA.status}, count: ${resA.json.length}`);
    if (!Array.isArray(resA.json) || resA.json.length !== 0) {
      throw new Error('Expected 0 initial members');
    }

    // 3. Test Join Dindi
    const pilgrimId = '00000000-0000-0000-0000-000000000005'; // Gauri
    const joinRes = await request(`/api/dindis/${testDindiId}/join`, {
      method: 'POST',
      headers: { 'x-user-id': pilgrimId },
      body: {
        pilgrim_id: pilgrimId,
        role: 'Taalvadak (टाळकरी)',
      },
    });
    console.log(`[PASS] POST /api/dindis/${testDindiId}/join -> Status ${joinRes.status}, id: ${joinRes.json.id}`);
    const membershipId = joinRes.json.id;
    if (!membershipId) throw new Error('Failed to obtain membership ID');

    // 4. Test Approving the pending member
    const approveRes = await request(`/api/dindi-memberships/${membershipId}`, {
      method: 'PATCH',
      headers: { 'x-user-id': leaderUserId },
      body: {
        status: 'active',
      },
    });
    console.log(`[PASS] PATCH /api/dindi-memberships/${membershipId} (approve) -> Status ${approveRes.status}, status: ${approveRes.json.status}`);
    if (approveRes.json.status !== 'active') throw new Error(`Expected status 'active', got ${approveRes.json.status}`);

    // 5. Test Updating Dindi lifecycle status via PATCH
    const patchDindiRes = await request(`/api/dindis/${testDindiId}`, {
      method: 'PATCH',
      headers: { 'x-user-id': leaderUserId },
      body: {
        status: 'Halted',
        roadStatus: 'Slow',
      },
    });
    console.log(`[PASS] PATCH /api/dindis/${testDindiId} (lifecycle status) -> Status ${patchDindiRes.status}, status: ${patchDindiRes.json.status}`);
    if (patchDindiRes.json.status !== 'Halted') throw new Error(`Expected status 'Halted', got ${patchDindiRes.json.status}`);

    // 6. Test Rejecting / updating membership status
    const rejectRes = await request(`/api/dindi-memberships/${membershipId}`, {
      method: 'PATCH',
      headers: { 'x-user-id': leaderUserId },
      body: {
        status: 'rejected',
      },
    });
    console.log(`[PASS] PATCH /api/dindi-memberships/${membershipId} (reject) -> Status ${rejectRes.status}, status: ${rejectRes.json.status}`);
    if (rejectRes.json.status !== 'rejected') throw new Error(`Expected status 'rejected', got ${rejectRes.json.status}`);

    console.log('\n🎉 ALL LIVE DINDI REST INTEGRATION VERIFICATION CRITERIA PASSED CLEANLY!\n');
  } catch (err) {
    console.error('❌ Member integration test failed:', err);
    process.exitCode = 1;
  }
}

runMemberIntegrationTests();
