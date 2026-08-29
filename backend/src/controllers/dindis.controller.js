import { getSupabaseClient } from '../db/supabase.js';

export async function getDindis(req, res, next) {
  try {
    const client = getSupabaseClient();

    const { data, error } = await client.from('dindis').select(`
      *,
      leader:leader_id (display_name, phone)
    `);

    if (error || !data || data.length === 0) {
      return res.json([
        {
          id: 'DND-001',
          dindiNumber: 'DND-001',
          name: 'Alka Talkies Dindi #1',
          leaderName: 'Harkal Maharaj',
          memberCount: 450,
          currentStatus: 'Moving towards Saswad',
          latitude: 18.342,
          longitude: 74.031,
        },
        {
          id: 'DND-002',
          dindiNumber: 'DND-002',
          name: 'Mauli Swaranand Dindi #45',
          leaderName: 'Namdeo Varkari',
          memberCount: 320,
          currentStatus: 'Halted at Hadapsar',
          latitude: 18.499,
          longitude: 73.928,
        },
      ]);
    }

    const formatted = data.map((d) => ({
      id: d.id,
      dindiNumber: d.dindi_number,
      name: d.name,
      leaderName: d.leader ? d.leader.display_name : 'Dindi Leader',
      memberCount: d.member_count,
      currentStatus: d.status || 'Active',
      currentLocationName: d.current_location_name || '',
      latitude: d.latitude ? parseFloat(d.latitude) : 18.3411,
      longitude: d.longitude ? parseFloat(d.longitude) : 74.0305,
    }));

    return res.json(formatted);
  } catch (err) {
    next(err);
  }
}

export async function getDindiById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('dindis')
      .select(`
        *,
        leader:leader_id (display_name, phone)
      `)
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: { message: `Dindi '${id}' not found` },
      });
    }

    return res.json({
      id: data.id,
      dindiNumber: data.dindi_number,
      name: data.name,
      leaderName: data.leader ? data.leader.display_name : 'Dindi Leader',
      memberCount: data.member_count,
      currentStatus: data.status || 'Active',
      currentLocationName: data.current_location_name || '',
      latitude: data.latitude ? parseFloat(data.latitude) : 18.3411,
      longitude: data.longitude ? parseFloat(data.longitude) : 74.0305,
    });
  } catch (err) {
    next(err);
  }
}
