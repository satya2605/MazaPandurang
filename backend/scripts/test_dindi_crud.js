import assert from 'node:assert';

const BASE_URL = 'http://localhost:3000/api/dindis';

async function run() {
  console.log('Testing Dindi API Endpoints...');

  // 1. GET by leader_id
  const getRes = await fetch(`${BASE_URL}?leader_id=00000000-0000-0000-0000-000000000002`);
  assert.strictEqual(getRes.status, 200);
  const dindis = await getRes.json();
  assert(Array.isArray(dindis));
  console.log(`✓ GET /api/dindis?leader_id returned ${dindis.length} records`);

  // 2. POST create dindi
  const uniqueCode = 'TEST' + Math.floor(Math.random() * 89 + 10);
  const uniqueNum = 'DND-T' + Math.floor(Math.random() * 899 + 100);
  const postRes = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: 'Automated Test Dindi',
      dindi_number: uniqueNum,
      start_point: 'Alandi',
      destination: 'Pandharpur',
      current_halt: 'Dive Ghat Base',
      road_status: 'Clear & Moving',
      join_code: uniqueCode,
      leader_id: '00000000-0000-0000-0000-000000000002'
    })
  });
  assert.strictEqual(postRes.status, 201);
  const created = await postRes.json();
  assert.strictEqual(created.name, 'Automated Test Dindi');
  assert.strictEqual(created.dindiNumber, uniqueNum);
  assert.strictEqual(created.leaderName, 'Sanket Maharaj');
  console.log(`✓ POST /api/dindis created ID: ${created.id}`);

  // 3. PUT update dindi
  const putRes = await fetch(`${BASE_URL}/${created.id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      current_halt: 'Saswad Central',
      road_status: 'Slow'
    })
  });
  assert.strictEqual(putRes.status, 200);
  const updated = await putRes.json();
  assert.strictEqual(updated.currentHalt, 'Saswad Central');
  assert.strictEqual(updated.roadStatus, 'Slow');
  console.log(`✓ PUT /api/dindis/${created.id} updated halt and status`);

  // 4. Duplicate POST check
  const duplicateRes = await fetch(BASE_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: 'Duplicate Test Dindi',
      dindi_number: uniqueNum, // duplicate
      start_point: 'Alandi',
      destination: 'Pandharpur',
      current_halt: 'Dive Ghat',
      road_status: 'Clear & Moving',
      join_code: 'DUP999',
      leader_id: '00000000-0000-0000-0000-000000000002'
    })
  });
  assert.strictEqual(duplicateRes.status, 409);
  console.log('✓ POST /api/dindis correctly rejected duplicate dindi_number with 409 Conflict');

  console.log('ALL API TESTS PASSED SUCCESSFULLY!');
}

run().catch((err) => {
  console.error('API Test Error:', err);
  process.exit(1);
});
