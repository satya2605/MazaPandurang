import { getSupabaseClient } from '../src/db/supabase.js';

async function createAdminUser() {
  const client = getSupabaseClient();
  const email = 'admin@mp.com';
  const password = 'Admin@123456';
  const displayName = 'System Administrator';

  console.log(`\n🔐 Creating/Configuring Admin account in Supabase for: ${email}...`);

  // 1. Check or create in Supabase auth.users
  const { data: userList } = await client.auth.admin.listUsers();
  let existingUser = userList?.users?.find((u) => u.email === email);

  let userId;
  if (!existingUser) {
    const { data: newUser, error: createErr } = await client.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        display_name: displayName,
        role: 'admin',
      },
    });

    if (createErr) {
      console.error('❌ Error creating Supabase auth user:', createErr);
      process.exit(1);
    }
    userId = newUser.user.id;
    console.log(`✅ Created Supabase Auth User with ID: ${userId}`);
  } else {
    userId = existingUser.id;
    const { error: updateErr } = await client.auth.admin.updateUserById(userId, {
      password,
      email_confirm: true,
      user_metadata: {
        display_name: displayName,
        role: 'admin',
      },
    });
    if (updateErr) {
      console.error('❌ Error updating Supabase auth user:', updateErr);
      process.exit(1);
    }
    console.log(`✅ Updated existing Supabase Auth User with ID: ${userId}`);
  }

  // 2. Upsert matching record in public.profiles table
  const { data: profile, error: profErr } = await client
    .from('profiles')
    .upsert(
      {
        id: userId,
        email,
        display_name: displayName,
        role: 'admin',
        status: 'active',
        phone: '+91 99999 88888',
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'id' }
    )
    .select()
    .single();

  if (profErr) {
    console.error('❌ Error upserting admin profile:', profErr);
    process.exit(1);
  }

  console.log('\n🎉 SUCCESS! Admin account is live in Supabase:');
  console.log('───────────────────────────────────────────────────────');
  console.log(`📧 Email:    ${email}`);
  console.log(`🔑 Password: ${password}`);
  console.log(`🆔 User ID:  ${userId}`);
  console.log(`🛡️ Role:     ${profile.role}`);
  console.log(`⚡ Status:   ${profile.status}`);
  console.log('───────────────────────────────────────────────────────\n');
}

createAdminUser();
