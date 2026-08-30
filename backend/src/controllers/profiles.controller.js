import { getSupabaseClient } from '../db/supabase.js';

export async function getProfileById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Profile not found' });
      }
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateProfile(req, res, next) {
  try {
    const { id } = req.params;
    const { display_name, phone, email, status, language, profile_photo_url, role } = req.body;
    const client = getSupabaseClient();

    const updates = {
      id,
      updated_at: new Date().toISOString(),
    };
    if (display_name !== undefined) updates.display_name = display_name;
    if (phone !== undefined) updates.phone = phone;
    if (email !== undefined) updates.email = email;
    if (status !== undefined) updates.status = status;
    if (language !== undefined) updates.language = language;
    if (profile_photo_url !== undefined) updates.profile_photo_url = profile_photo_url;
    if (role !== undefined) {
      updates.role = role;
      if (status === undefined) {
        updates.status = (role === 'dindi_leader' || role === 'ngo_volunteer') ? 'pending' : 'active';
      }
    }

    // 1. Upsert profile with service role
    const { data, error } = await client
      .from('profiles')
      .upsert(updates, { onConflict: 'id' })
      .select()
      .single();

    if (error) throw error;

    // 2. If police_authority, ensure matching police_profiles row exists
    if (role === 'police_authority' || data?.role === 'police_authority') {
      const policeId = `POL-MH-${id.substring(0, Math.min(8, id.length)).toUpperCase()}`;
      await client
        .from('police_profiles')
        .upsert({
          user_id: id,
          police_id: policeId,
          name: display_name || data?.display_name || 'Police Officer',
          designation: 'Sub-Inspector',
          station_name: 'Pandharpur Sector Police',
          role: 'POLICE_OFFICER',
          status: 'ACTIVE',
          updated_at: new Date().toISOString(),
        }, { onConflict: 'user_id' });
    }

    // 3. If ngo_volunteer, ensure pending NGO application exists in ngos table
    if (role === 'ngo_volunteer' || data?.role === 'ngo_volunteer') {
      const { data: existingNgo } = await client
        .from('ngos')
        .select('id')
        .eq('user_id', id)
        .maybeSingle();

      if (!existingNgo) {
        const regNum = `NGO-MH-${id.substring(0, Math.min(8, id.length)).toUpperCase()}`;
        await client.from('ngos').insert({
          user_id: id,
          name: `${display_name || data?.display_name || 'Seva'} Seva Mandal`,
          registration_number: regNum,
          contact_person: display_name || data?.display_name || 'NGO Representative',
          phone: phone || data?.phone || '+91 9800000000',
          email: email || data?.email || '',
          primary_category: 'Food & Medical Seva',
          status: 'pending',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        });
      }
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}
