import { getSupabaseClient } from '../db/supabase.js';

function formatDindi(item) {
  if (!item) return null;
  const leaderProfile = item.profiles || {};
  return {
    id: item.id,
    name: item.name || '',
    dindiNumber: item.dindi_number || '',
    dindi_number: item.dindi_number || '',
    leaderName: leaderProfile.display_name || item.leader_name || 'Dindi Leader',
    leader_name: leaderProfile.display_name || item.leader_name || 'Dindi Leader',
    leaderPhone: leaderProfile.phone || item.leader_phone || '',
    leader_phone: leaderProfile.phone || item.leader_phone || '',
    leaderUserId: item.leader_id || '00000000-0000-0000-0000-000000000002',
    leader_id: item.leader_id || '00000000-0000-0000-0000-000000000002',
    memberCount: item.member_count || 0,
    member_count: item.member_count || 0,
    status: item.status || 'Active',
    currentLocationName: item.current_location_name || '',
    current_location_name: item.current_location_name || '',
    latitude: item.latitude != null ? parseFloat(item.latitude) : 18.6772,
    longitude: item.longitude != null ? parseFloat(item.longitude) : 73.8967,
    startPoint: item.start_point || 'Alandi',
    start_point: item.start_point || 'Alandi',
    destination: item.destination || 'Pandharpur',
    currentHalt: item.current_halt || '',
    current_halt: item.current_halt || '',
    roadStatus: item.road_status || 'Clear & Moving',
    road_status: item.road_status || 'Clear & Moving',
    joinCode: item.join_code || '',
    join_code: item.join_code || '',
    createdAt: item.created_at,
    updatedAt: item.updated_at,
  };
}

export async function getAllDindis(req, res, next) {
  try {
    const client = getSupabaseClient();
    const leaderId = req.query.leader_id || req.query.leaderId;

    let query = client
      .from('dindis')
      .select('*, profiles:leader_id(display_name, phone)');

    if (leaderId) {
      query = query.eq('leader_id', leaderId);
    } else {
      // Public discovery: only list active Dindis (unapproved/suspended Dindis are hidden)
      query = query.eq('status', 'Active');
    }

    const { data, error } = await query.order('created_at', { ascending: false });

    if (error) {
      return res.status(500).json({
        success: false,
        error: { message: error.message, code: error.code },
      });
    }

    const formatted = (data || []).map(formatDindi);
    return res.json(formatted);
  } catch (err) {
    next(err);
  }
}

export const getDindis = getAllDindis;

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
        return res.status(404).json({
          success: false,
          error: { message: `Dindi '${id}' not found` },
        });
      }
      return res.status(500).json({
        success: false,
        error: { message: error.message, code: error.code },
      });
    }

    if (!data) {
      return res.status(404).json({
        success: false,
        error: { message: `Dindi '${id}' not found` },
      });
    }

    return res.json(formatDindi(data));
  } catch (err) {
    next(err);
  }
}

export async function createDindi(req, res, next) {
  try {
    const client = getSupabaseClient();

    // Enforce role and active approval status
    if (req.user && req.user.role !== 'admin') {
      if (req.user.role !== 'dindi_leader') {
        return res.status(403).json({
          success: false,
          error: { code: 'FORBIDDEN', message: 'Only registered Dindi Leaders can create Dindis.' },
        });
      }
      if (req.user.status !== 'active') {
        return res.status(403).json({
          success: false,
          error: { code: 'PENDING_APPROVAL', message: 'Dindi Leader account awaiting Admin approval.' },
        });
      }
    }

    const name = req.body.name;
    const dindiNumber = req.body.dindiNumber || req.body.dindi_number || `DND-${Date.now()}`;
    const startPoint = req.body.startPoint || req.body.start_point || 'Alandi';
    const destination = req.body.destination || req.body.destination || 'Pandharpur';
    const currentHalt = req.body.currentHalt || req.body.current_halt || '';
    const roadStatus = req.body.roadStatus || req.body.road_status || 'Clear & Moving';
    const joinCode =
      req.body.joinCode ||
      req.body.join_code ||
      `DND${Math.floor(100 + Math.random() * 900)}`;
    const leaderUserId =
      req.user?.id ||
      req.body.leaderUserId ||
      req.body.leader_id ||
      req.body.leaderId ||
      req.query.leader_id;
    const memberCount = req.body.memberCount || req.body.member_count || 1;
    const currentLocationName =
      req.body.currentLocationName || req.body.current_location_name || 'Alandi';
    const latitude = req.body.latitude ? parseFloat(req.body.latitude) : 18.6772;
    const longitude = req.body.longitude ? parseFloat(req.body.longitude) : 73.8967;

    if (!name) {
      return res.status(400).json({
        success: false,
        error: { message: 'name is a required field' },
      });
    }

    const insertPayload = {
      name: name.trim(),
      dindi_number: dindiNumber.trim(),
      leader_id: leaderUserId,
      start_point: startPoint.trim(),
      destination: destination.trim(),
      current_halt: currentHalt.trim(),
      road_status: roadStatus,
      join_code: joinCode.trim(),
      status: req.body.status || 'Pending',
      member_count: memberCount,
      current_location_name: currentLocationName,
      latitude,
      longitude,
    };

    const { data, error } = await client
      .from('dindis')
      .insert(insertPayload)
      .select('*, profiles:leader_id(display_name, phone)')
      .single();

    if (error) {
      if (error.code === '23505') {
        const detail = error.details || error.message || '';
        const field = detail.includes('dindi_number')
          ? 'Dindi Number'
          : detail.includes('join_code')
            ? 'Join Code'
            : 'Record';
        return res.status(409).json({
          success: false,
          error: {
            message: `${field} already exists. Please choose a unique value.`,
            code: error.code,
            details: error.details,
          },
        });
      }
      return res.status(500).json({
        success: false,
        error: { message: error.message, code: error.code },
      });
    }

    return res.status(201).json(formatDindi(data));
  } catch (err) {
    next(err);
  }
}

export async function updateDindi(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();
    const body = req.body;

    // Fetch existing Dindi to verify ownership
    const { data: existing, error: fetchErr } = await client
      .from('dindis')
      .select('*')
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .single();

    if (fetchErr || !existing) {
      return res.status(404).json({ success: false, error: { message: `Dindi '${id}' not found` } });
    }

    // Enforce ownership: Non-admin users can ONLY edit their own Dindi
    if (req.user && req.user.role !== 'admin') {
      if (existing.leader_id !== req.user.id) {
        return res.status(403).json({
          success: false,
          error: { code: 'FORBIDDEN', message: 'You are not authorized to modify another leader\'s Dindi.' },
        });
      }
      if (req.user.status !== 'active') {
        return res.status(403).json({
          success: false,
          error: { code: 'PENDING_APPROVAL', message: 'Dindi Leader account awaiting Admin approval.' },
        });
      }
    }

    const updatePayload = {
      updated_at: new Date().toISOString(),
    };

    if (body.name !== undefined) updatePayload.name = body.name.trim();
    if (body.dindiNumber !== undefined || body.dindi_number !== undefined) {
      updatePayload.dindi_number = (body.dindiNumber || body.dindi_number).trim();
    }
    if (body.startPoint !== undefined || body.start_point !== undefined) {
      updatePayload.start_point = (body.startPoint || body.start_point).trim();
    }
    if (body.destination !== undefined) updatePayload.destination = body.destination.trim();
    if (body.currentHalt !== undefined || body.current_halt !== undefined) {
      updatePayload.current_halt = (body.currentHalt || body.current_halt).trim();
    }
    if (body.roadStatus !== undefined || body.road_status !== undefined) {
      updatePayload.road_status = body.roadStatus || body.road_status;
    }
    if (body.memberCount !== undefined || body.member_count !== undefined) {
      updatePayload.member_count = body.memberCount || body.member_count;
    }
    if (body.currentLocationName !== undefined || body.current_location_name !== undefined) {
      updatePayload.current_location_name = body.currentLocationName || body.current_location_name;
    }
    if (body.latitude !== undefined) updatePayload.latitude = parseFloat(body.latitude);
    if (body.longitude !== undefined) updatePayload.longitude = parseFloat(body.longitude);
    if (body.status !== undefined) updatePayload.status = body.status;

    const { data, error } = await client
      .from('dindis')
      .update(updatePayload)
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .select('*, profiles:leader_id(display_name, phone)')
      .single();

    if (error) {
      if (error.code === '23505') {
        return res.status(409).json({
          success: false,
          error: {
            message: 'Dindi Number already exists for another Dindi.',
            code: error.code,
          },
        });
      }
      return res.status(500).json({
        success: false,
        error: { message: error.message, code: error.code },
      });
    }

    if (!data) {
      return res.status(404).json({
        success: false,
        error: { message: `Dindi '${id}' not found` },
      });
    }

    return res.json(formatDindi(data));
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
      .eq('dindi_id', id)
      .order('requested_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function joinDindi(req, res, next) {
  try {
    const { id } = req.params;
    const pilgrim_id = req.user?.id || req.body.pilgrim_id || '00000000-0000-0000-0000-000000000001';
    const role = req.body.role || 'warkari';
    const client = getSupabaseClient();

    // Verify Dindi exists
    const { data: dindi, error: dindiErr } = await client
      .from('dindis')
      .select('id, name, status')
      .eq('id', id)
      .single();

    if (dindiErr || !dindi) {
      return res.status(404).json({ error: { message: 'Dindi not found' } });
    }

    // Check if membership already exists
    const { data: existing } = await client
      .from('dindi_memberships')
      .select('*')
      .eq('dindi_id', id)
      .eq('pilgrim_id', pilgrim_id)
      .maybeSingle();

    if (existing) {
      if (existing.status === 'active') {
        return res.status(409).json({
          error: { code: 'ALREADY_MEMBER', message: 'You are already an active member of this Dindi.' },
        });
      }
      if (existing.status === 'pending') {
        return res.status(409).json({
          error: { code: 'ALREADY_REQUESTED', message: 'Your join request for this Dindi is already pending approval.' },
        });
      }
      // Re-apply if previously rejected
      const { data: updated, error: updateErr } = await client
        .from('dindi_memberships')
        .update({ status: 'pending', role, requested_at: new Date().toISOString() })
        .eq('id', existing.id)
        .select('*, profiles:pilgrim_id(display_name, phone, email)')
        .single();
      if (updateErr) throw updateErr;
      return res.status(200).json(updated);
    }

    const payload = {
      dindi_id: id,
      pilgrim_id,
      status: 'pending',
      role,
      requested_at: new Date().toISOString(),
    };

    const { data, error } = await client
      .from('dindi_memberships')
      .insert(payload)
      .select('*, profiles:pilgrim_id(display_name, phone, email)')
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

    // Fetch membership with Dindi info to verify leader ownership
    const { data: membership, error: memErr } = await client
      .from('dindi_memberships')
      .select('*, dindis(id, leader_id)')
      .eq('id', id)
      .single();

    if (memErr || !membership) {
      return res.status(404).json({ error: { message: `Membership '${id}' not found` } });
    }

    if (req.user && req.user.role !== 'admin') {
      if (membership.dindis?.leader_id !== req.user.id) {
        return res.status(403).json({
          error: { code: 'FORBIDDEN', message: 'You are not authorized to moderate members for another leader\'s Dindi.' },
        });
      }
    }

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (status !== undefined) {
      if (status === 'active' || status === 'approved') {
        updates.status = 'active';
        updates.joined_at = new Date().toISOString();
      } else {
        updates.status = status;
      }
    }
    if (role !== undefined) updates.role = role;

    const { data, error } = await client
      .from('dindi_memberships')
      .update(updates)
      .eq('id', id)
      .select('*, profiles:pilgrim_id(display_name, phone, email)')
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}
