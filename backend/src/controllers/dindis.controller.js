import { getSupabaseClient } from '../db/supabase.js';

export async function getAllDindis(req, res, next) {
  try {
    const client = getSupabaseClient();
    let query = client.from('dindis').select('*, profiles:leader_id(display_name, phone)');

    // Public endpoint excludes pending/rejected/suspended dindis unless caller is admin
    if (!req.user || req.user.role !== 'admin') {
      query = query.eq('status', 'Active');
    }

    const { data, error } = await query;

    if (error) throw error;

    const mapped = (data || []).map((item) => ({
      id: item.id,
      dindiNumber: item.dindi_number,
      name: item.name,
      leaderId: item.leader_id,
      leaderName: item.profiles?.display_name || item.leader_name || 'Dindi Leader',
      leaderPhone: item.profiles?.phone || item.leader_phone || '',
      memberCount: item.member_count || 1,
      currentLocationName: item.current_location_name || '',
      latitude: item.latitude ? parseFloat(item.latitude) : 18.3411,
      longitude: item.longitude ? parseFloat(item.longitude) : 74.0305,
      status: item.status || 'Active',
      startPoint: item.start_point || '',
      destination: item.destination || '',
      currentHalt: item.current_halt || '',
      roadStatus: item.road_status || 'clear',
      joinCode: item.join_code || '',
    }));

    res.json(mapped);
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
      .select('*, profiles:leader_id(display_name, phone)')
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Dindi not found' });
      }
      throw error;
    }

    res.json({
      id: data.id,
      dindiNumber: data.dindi_number,
      name: data.name,
      leaderId: data.leader_id,
      leaderName: data.profiles?.display_name || data.leader_name || 'Dindi Leader',
      leaderPhone: data.profiles?.phone || data.leader_phone || '',
      memberCount: data.member_count || 1,
      currentLocationName: data.current_location_name || '',
      latitude: data.latitude ? parseFloat(data.latitude) : 18.3411,
      longitude: data.longitude ? parseFloat(data.longitude) : 74.0305,
      status: data.status || 'Active',
      startPoint: data.start_point || '',
      destination: data.destination || '',
      currentHalt: data.current_halt || '',
      roadStatus: data.road_status || 'clear',
      joinCode: data.join_code || '',
    });
  } catch (err) {
    next(err);
  }
}

export async function createDindi(req, res, next) {
  try {
    const {
      dindi_number,
      name,
      leader_id,
      member_count,
      current_location_name,
      latitude,
      longitude,
      start_point,
      destination,
      current_halt,
      road_status,
      join_code,
    } = req.body;

    if (req.user && req.user.role !== 'admin') {
      if (req.user.role !== 'dindi_leader') {
        return res.status(403).json({ error: { code: 'FORBIDDEN', message: 'Only Dindi Leaders can create Dindis.' } });
      }
      if (req.user.status !== 'active') {
        return res.status(403).json({ error: { code: 'PENDING_APPROVAL', message: 'Dindi Leader account awaiting Admin approval.' } });
      }
    }

    const effectiveLeaderId = req.user?.id || leader_id || null;

    const client = getSupabaseClient();
    const payload = {
      dindi_number: dindi_number || `DND-${Date.now()}`,
      name: name || 'Wari Dindi Troupe',
      leader_id: effectiveLeaderId,
      member_count: member_count || 1,
      current_location_name: current_location_name || 'Alandi',
      latitude: latitude || 18.6772,
      longitude: longitude || 73.8967,
      status: 'Pending',
      start_point: start_point || 'Alandi',
      destination: destination || 'Pandharpur',
      current_halt: current_halt || '',
      road_status: road_status || 'clear',
      join_code: join_code || `DND${Math.floor(100 + Math.random() * 900)}`,
    };

    const { data, error } = await client
      .from('dindis')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateDindi(req, res, next) {
  try {
    const { id } = req.params;
    const body = req.body;
    const client = getSupabaseClient();

    // Fetch existing Dindi to verify ownership
    const { data: existing, error: fetchErr } = await client
      .from('dindis')
      .select('*')
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .single();

    if (fetchErr || !existing) {
      return res.status(404).json({ error: 'Dindi not found' });
    }

    if (req.user && req.user.role !== 'admin' && existing.leader_id !== req.user.id) {
      return res.status(403).json({ error: { code: 'FORBIDDEN', message: 'You are not authorized to modify another leader\'s Dindi.' } });
    }

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (body.name !== undefined) updates.name = body.name;
    if (body.member_count !== undefined) updates.member_count = body.member_count;
    if (body.current_location_name !== undefined) updates.current_location_name = body.current_location_name;
    if (body.latitude !== undefined) updates.latitude = body.latitude;
    if (body.longitude !== undefined) updates.longitude = body.longitude;
    if (body.status !== undefined && req.user?.role === 'admin') updates.status = body.status;
    if (body.start_point !== undefined) updates.start_point = body.start_point;
    if (body.destination !== undefined) updates.destination = body.destination;
    if (body.current_halt !== undefined) updates.current_halt = body.current_halt;
    if (body.road_status !== undefined) updates.road_status = body.road_status;

    const { data, error } = await client
      .from('dindis')
      .update(updates)
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function getDindiMembers(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('dindi_memberships')
      .select('*, profiles:pilgrim_id(display_name, phone, email)')
      .eq('dindi_id', id);

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function joinDindi(req, res, next) {
  try {
    const { id } = req.params;
    const { pilgrim_id, role } = req.body;
    const client = getSupabaseClient();

    const payload = {
      dindi_id: id,
      pilgrim_id,
      status: 'pending',
      role: role || 'warkari',
      requested_at: new Date().toISOString(),
    };

    const { data, error } = await client
      .from('dindi_memberships')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateDindiMembership(req, res, next) {
  try {
    const { id } = req.params;
    const { status, role } = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (status !== undefined) updates.status = status;
    if (role !== undefined) updates.role = role;
    if (status === 'active') updates.joined_at = new Date().toISOString();

    const { data, error } = await client
      .from('dindi_memberships')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}
