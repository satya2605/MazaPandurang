import { getSupabaseClient } from '../db/supabase.js';

function normalizeEmergencyType(typeStr) {
  if (!typeStr) return 'Medical';
  const lower = typeStr.toString().toLowerCase();
  if (lower.includes('med')) return 'Medical';
  if (lower.includes('pol')) return 'Police';
  if (lower.includes('lost')) return 'Lost Person';
  return 'Other';
}

export async function getAllEmergencies(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('emergency_requests').select('*');

    // Pilgrims can strictly read ONLY their own emergency requests
    if (req.user && req.user.role === 'pilgrim') {
      query = query.eq('requester_id', req.user.id);
    } else if (req.query.requester_id) {
      query = query.eq('requester_id', req.query.requester_id);
    }

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

export async function createEmergency(req, res, next) {
  try {
    const { emergency_type, latitude, longitude, location_name, description } = req.body;
    const client = getSupabaseClient();

    // SERVER-SIDE IDENTITY: Always derive requester_id from verified JWT
    const requesterId = req.user?.id || req.body.requester_id;
    if (!requesterId) {
      return res.status(401).json({
        error: { code: 'UNAUTHENTICATED', message: 'User identity required from Supabase JWT' },
      });
    }

    const payload = {
      request_code: `EMG-${Date.now()}`,
      requester_id: requesterId,
      emergency_type: normalizeEmergencyType(emergency_type),
      latitude: latitude !== undefined && latitude !== null ? parseFloat(latitude) : 18.3411,
      longitude: longitude !== undefined && longitude !== null ? parseFloat(longitude) : 74.0305,
      location_name: location_name || (description ? description.substring(0, 100) : 'Wari Location'),
      status: 'pending',
    };

    const { data, error } = await client
      .from('emergency_requests')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;

    res.status(201).json({
      message: 'Emergency SOS request dispatched successfully.',
      requestCode: data.request_code,
      emergency: data,
    });
  } catch (err) {
    next(err);
  }
}

export async function updateEmergency(req, res, next) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const client = getSupabaseClient();

    // Ensure status is valid enum
    const validStatuses = ['pending', 'dispatched', 'resolved', 'cancelled'];
    if (status && !validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid emergency status' });
    }

    const updates = {};
    if (status !== undefined) updates.status = status;
    if (status === 'resolved' || status === 'cancelled') {
      updates.resolved_at = new Date().toISOString();
    }

    const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
    let query = client.from('emergency_requests').update(updates);
    if (isUuid) {
      query = query.eq('id', id);
    } else {
      query = query.eq('request_code', id);
    }

    const { data, error } = await query.select().single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}
