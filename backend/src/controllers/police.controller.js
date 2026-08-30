import { getSupabaseClient } from '../db/supabase.js';

export async function getPoliceUnits(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('police_units').select('*, police_profiles:assigned_officer_id(name, designation, phone)');
    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function registerPoliceProfile(req, res, next) {
  try {
    const userId = req.user?.id;
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized: Authentication required to register police profile' });
    }

    const { police_id, name, designation, station_name, phone } = req.body;
    const client = getSupabaseClient();

    // 1. Fetch current profile
    const { data: currentProfile, error: profErr } = await client
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (profErr && profErr.code !== 'PGRST116') {
      throw profErr;
    }

    const officerName = name || currentProfile?.display_name || req.user.email?.split('@')[0] || 'Police Officer';
    const officerPhone = phone || currentProfile?.phone || null;
    const badgeId = police_id || ('POL-MH-' + userId.substring(0, 8).toUpperCase());
    const station = station_name || 'Pandharpur Sector Station';
    const desig = designation || 'Sub-Inspector';

    // 2. Update base profile: role = 'police_authority', status = 'pending'
    const profileUpdates = {
      role: 'police_authority',
      status: currentProfile?.status === 'active' ? 'active' : 'pending',
      display_name: officerName,
      updated_at: new Date().toISOString(),
    };
    if (officerPhone) profileUpdates.phone = officerPhone;

    let updatedProfile;
    if (currentProfile) {
      const { data: updProf, error: updErr } = await client
        .from('profiles')
        .update(profileUpdates)
        .eq('id', userId)
        .select()
        .single();
      if (updErr) throw updErr;
      updatedProfile = updProf;
    } else {
      const { data: insProf, error: insErr } = await client
        .from('profiles')
        .insert({
          id: userId,
          email: req.user.email,
          ...profileUpdates,
        })
        .select()
        .single();
      if (insErr) throw insErr;
      updatedProfile = insProf;
    }

    // 3. Upsert police_profiles record
    const policeProfileData = {
      user_id: userId,
      police_id: badgeId,
      name: officerName,
      designation: desig,
      station_name: station,
      phone: officerPhone,
      role: 'POLICE_OFFICER',
      status: updatedProfile.status === 'active' ? 'ACTIVE' : 'PENDING',
      updated_at: new Date().toISOString(),
    };

    const { data: policeProfile, error: ppErr } = await client
      .from('police_profiles')
      .upsert(policeProfileData, { onConflict: 'user_id' })
      .select()
      .single();

    if (ppErr) throw ppErr;

    res.status(201).json({
      message: 'Police Authority profile registered successfully',
      profile: updatedProfile,
      police_profile: policeProfile,
    });
  } catch (err) {
    next(err);
  }
}

export async function getPoliceProfile(req, res, next) {
  try {
    const userId = req.params.id || req.user?.id;
    if (!userId) {
      return res.status(400).json({ error: 'User ID required' });
    }
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('police_profiles')
      .select('*, profiles:user_id(id, display_name, email, role, status)')
      .eq('user_id', userId)
      .maybeSingle();

    if (error) throw error;
    if (!data) {
      return res.status(404).json({ error: 'Police profile not found' });
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}
