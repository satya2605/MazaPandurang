import { getSupabaseClient } from '../db/supabase.js';

export async function applyDindiLeader(req, res, next) {
  try {
    const { dindi_name, start_point, destination, expected_members, description, phone } = req.body;
    const userId = req.user.id;
    const client = getSupabaseClient();

    // 1. Update profile role to dindi_leader and status to pending
    const { data: updatedProfile, error: profileErr } = await client
      .from('profiles')
      .update({
        role: 'dindi_leader',
        status: 'pending',
        phone: phone || req.user.profile?.phone || '',
        updated_at: new Date().toISOString(),
      })
      .eq('id', userId)
      .select()
      .single();

    if (profileErr) throw profileErr;

    // 2. Create pending Dindi registration if dindi_name supplied
    let dindiRecord = null;
    if (dindi_name) {
      const { data: newDindi, error: dindiErr } = await client
        .from('dindis')
        .insert({
          dindi_number: `DND-${Date.now()}`,
          name: dindi_name,
          leader_id: userId,
          member_count: expected_members || 1,
          start_point: start_point || 'Alandi',
          destination: destination || 'Pandharpur',
          status: 'Pending',
          road_status: 'clear',
          join_code: `DND${Math.floor(100 + Math.random() * 900)}`,
        })
        .select()
        .single();

      if (!dindiErr) dindiRecord = newDindi;
    }

    res.status(201).json({
      message: 'Dindi Leader application submitted successfully. Pending Admin verification.',
      profile: updatedProfile,
      dindi: dindiRecord,
    });
  } catch (err) {
    next(err);
  }
}
