import { getSupabaseClient } from '../src/db/supabase.js';
import { config } from '../src/config/env.js';
import app from '../src/server.js';
import http from 'http';

async function checkDatabaseAndBackend() {
  console.log('========================================================');
  console.log('🔍 MAZA PANDURANG — DATABASE & BACKEND HEALTH CHECK');
  console.log('========================================================\n');

  console.log('1. Checking Environment Variables:');
  console.log(`   - PORT: ${config.port}`);
  console.log(`   - SUPABASE_URL: ${config.supabaseUrl ? config.supabaseUrl.replace(/^(https:\/\/[^.]+).*/, '$1.supabase.co') : 'MISSING'}`);
  console.log(`   - SUPABASE_SERVICE_ROLE_KEY: ${config.supabaseServiceRoleKey ? 'CONFIGURED (' + config.supabaseServiceRoleKey.substring(0, 12) + '...)' : 'MISSING'}`);
  console.log(`   - Storage Buckets:`, config.storageBuckets);
  console.log();

  let supabase;
  try {
    supabase = getSupabaseClient();
    console.log('✅ Supabase client created successfully.\n');
  } catch (err) {
    console.error('❌ Failed to initialize Supabase client:', err.message);
    process.exit(1);
  }

  // 2. Test Tables in Database
  console.log('2. Checking Database Tables:');
  const tables = [
    'profiles',
    'dindis',
    'dindi_memberships',
    'palkhi_tracking',
    'services',
    'service_images',
    'service_reports',
    'emergency_requests',
    'lost_person_reports',
    'lost_person_images',
    'lost_person_sightings',
    'bhakti_content',
    'donations_info',
    'wari_route',
  ];

  let tableSuccessCount = 0;
  for (const table of tables) {
    try {
      const { data, count, error } = await supabase
        .from(table)
        .select('*', { count: 'exact' })
        .limit(3);

      if (error) {
        console.log(`   ❌ [${table}] Error: ${error.message} (${error.code || 'N/A'})`);
      } else {
        tableSuccessCount++;
        console.log(`   ✅ [${table}] Accessible — Total rows: ${count}, Sample fetched: ${data.length}`);
      }
    } catch (e) {
      console.log(`   ❌ [${table}] Exception: ${e.message}`);
    }
  }

  console.log(`\n   Summary: ${tableSuccessCount}/${tables.length} tables verified.\n`);

  // 3. Test Storage Buckets
  console.log('3. Checking Supabase Storage Buckets:');
  try {
    const { data: buckets, error: bucketErr } = await supabase.storage.listBuckets();
    if (bucketErr) {
      console.log(`   ⚠️ Storage listBuckets error: ${bucketErr.message}`);
    } else {
      console.log(`   ✅ Found ${buckets.length} storage buckets:`);
      buckets.forEach(b => console.log(`      - ${b.name} (public: ${b.public})`));
    }
  } catch (e) {
    console.log(`   ⚠️ Storage check exception: ${e.message}`);
  }
  console.log();

  // 4. Test REST API Server
  console.log('4. Testing REST API Server Endpoints:');
  const testPort = 3001;
  const server = http.createServer(app);

  await new Promise((resolve) => server.listen(testPort, resolve));
  console.log(`   🚀 Test API Server listening on http://localhost:${testPort}\n`);

  const endpoints = [
    { method: 'GET', path: '/api/health' },
    { method: 'GET', path: '/api/palkhi' },
    { method: 'GET', path: '/api/services' },
    { method: 'GET', path: '/api/services/nearest?latitude=18.3411&longitude=74.0305&category=Medical' },
    { method: 'GET', path: '/api/dindis' },
    { method: 'GET', path: '/api/wari-route' },
    { method: 'GET', path: '/api/bhakti' },
    { method: 'GET', path: '/api/donations' },
    { method: 'GET', path: '/api/lost-persons' },
  ];

  for (const ep of endpoints) {
    try {
      const response = await fetch(`http://localhost:${testPort}${ep.path}`, {
        method: ep.method,
      });
      const json = await response.json();
      const statusText = response.status === 200 ? '✅ 200 OK' : `⚠️ ${response.status}`;
      console.log(`   ${statusText} ${ep.method} ${ep.path}`);
      if (ep.path === '/api/health') {
        console.log(`      Health Response:`, JSON.stringify(json));
      } else if (Array.isArray(json)) {
        console.log(`      Count returned: ${json.length} items`);
      } else {
        console.log(`      Payload keys: [${Object.keys(json).join(', ')}]`);
      }
    } catch (e) {
      console.log(`   ❌ Error calling ${ep.path}: ${e.message}`);
    }
  }

  // Test POST Emergency SOS
  try {
    const postRes = await fetch(`http://localhost:${testPort}/api/emergency`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        emergency_type: 'Medical',
        latitude: 18.3411,
        longitude: 74.0305,
        location_description: 'Near Saswad Palkhi Camp',
        requester_name: 'Dev Test Pilgrim',
        requester_phone: '9876543210',
        dindi_number: 'DINDI-001',
        description: 'Automated Diagnostic Verification Test'
      }),
    });
    const postJson = await postRes.json();
    console.log(`\n   ${postRes.status === 201 ? '✅ 201 Created' : '⚠️ ' + postRes.status} POST /api/emergency`);
    console.log(`      Result:`, JSON.stringify(postJson));
  } catch (e) {
    console.log(`   ❌ Error calling POST /api/emergency: ${e.message}`);
  }

  server.close();
  console.log('\n========================================================');
  console.log('🏁 HEALTH CHECK COMPLETED');
  console.log('========================================================');
}

checkDatabaseAndBackend().catch(console.error);
