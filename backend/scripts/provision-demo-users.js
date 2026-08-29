import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { config, validateEnv } from '../src/config/env.js';

if (!global.WebSocket) {
  global.WebSocket = class {};
}

validateEnv();

const supabaseUrl = config.supabaseUrl;
const serviceRoleKey = config.supabaseServiceRoleKey;

if (!serviceRoleKey) {
  console.error('❌ Error: SUPABASE_SERVICE_KEY (service-role key) is required to provision auth users.');
  process.exit(1);
}

const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
  realtime: {
    enabled: false,
  },
});

const personas = [
  {
    id: '00000000-0000-0000-0000-000000000001',
    email: 'satyajit@mazapandurang.local',
    role: 'pilgrim',
    displayName: 'Satyajit (Pilgrim Lead)',
    phone: '+919876543210',
  },
  {
    id: '00000000-0000-0000-0000-000000000002',
    email: 'sanket@mazapandurang.local',
    role: 'dindi_leader',
    displayName: 'Sanket (Dindi Leader)',
    phone: '+919876543211',
  },
  {
    id: '00000000-0000-0000-0000-000000000003',
    email: 'yogeshwari@mazapandurang.local',
    role: 'police_authority',
    displayName: 'Yogeshwari (Police Authority)',
    phone: '+919876543212',
  },
  {
    id: '00000000-0000-0000-0000-000000000004',
    email: 'shrutika@mazapandurang.local',
    role: 'ngo_volunteer',
    displayName: 'Shrutika (NGO Volunteer)',
    phone: '+919876543213',
  },
  {
    id: '00000000-0000-0000-0000-000000000005',
    email: 'gauri@mazapandurang.local',
    role: 'local_citizen',
    displayName: 'Gauri (Local Citizen)',
    phone: '+919876543214',
  },
  {
    id: '00000000-0000-0000-0000-000000000006',
    email: 'admin@mazapandurang.local',
    role: 'admin',
    displayName: 'Admin Control Plane',
    phone: '+919876543215',
  },
];

function generateDevPassword() {
  return 'Wari2026!' + crypto.randomBytes(4).toString('hex');
}

async function provision() {
  console.log('🚀 Provisioning 6 Supabase Auth personas...');
  const credentials = [];

  for (const persona of personas) {
    const password = process.env[`DEMO_${persona.role.toUpperCase()}_PASSWORD`] || generateDevPassword();

    // 1. Try to create user
    const { data: user, error: createErr } = await supabaseAdmin.auth.admin.createUser({
      id: persona.id,
      email: persona.email,
      password: password,
      email_confirm: true,
      user_metadata: { display_name: persona.displayName, role: persona.role },
    });

    if (createErr && createErr.message?.includes('already registered')) {
      console.log(`ℹ️  User ${persona.email} already exists. Updating password...`);
      await supabaseAdmin.auth.admin.updateUserById(persona.id, {
        password: password,
        email_confirm: true,
      });
    } else if (createErr) {
      console.error(`⚠️  Failed to create ${persona.email}:`, createErr.message);
    } else {
      console.log(`✅ Provisioned ${persona.email} (ID: ${user.user.id})`);
    }

    // 2. Ensure corresponding profiles row exists with exact role
    const { error: profileErr } = await supabaseAdmin
      .from('profiles')
      .upsert({
        id: persona.id,
        role: persona.role,
        display_name: persona.displayName,
        phone: persona.phone,
        email: persona.email,
        status: 'active',
        updated_at: new Date().toISOString(),
      }, { onConflict: 'id' });

    if (profileErr) {
      console.error(`⚠️  Profile upsert error for ${persona.email}:`, profileErr.message);
    }

    credentials.push({
      persona: persona.displayName,
      role: persona.role,
      uuid: persona.id,
      email: persona.email,
      password: password,
    });
  }

  // Save credentials locally in gitignored file
  const scratchDir = path.join(process.cwd(), 'scratch');
  if (!fs.existsSync(scratchDir)) {
    fs.mkdirSync(scratchDir, { recursive: true });
  }

  const credentialsPath = path.join(scratchDir, 'demo_credentials.json');
  fs.writeFileSync(credentialsPath, JSON.stringify(credentials, null, 2));

  console.log(`\n🎉 All 6 Supabase Auth personas provisioned successfully!`);
  console.log(`🔒 Local gitignored credentials saved to: ${credentialsPath}\n`);
}

provision().catch((err) => {
  console.error('Fatal provisioning failure:', err);
  process.exit(1);
});
