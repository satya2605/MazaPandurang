import { getSupabaseClient } from '../db/supabase.js';

export async function getAllEmergencies(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('emergency_requests').select('*');
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
    const { requester_id, emergency_type, latitude, longitude, location_name } = req.body;
    const client = getSupabaseClient();

    const payload = {
      request_code: `EMG-${Date.now()}`,
      requester_id: requester_id || null,
      emergency_type: emergency_type || 'Medical',
      latitude: latitude || 18.3411,
      longitude: longitude || 74.0305,
      location_name: location_name || 'Wari Route Location',
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

    const updates = {};
    if (status !== undefined) updates.status = status;
    if (status === 'resolved' || status === 'cancelled') {
      updates.resolved_at = new Date().toISOString();
    }

    const { data, error } = await client
      .from('emergency_requests')
      .update(updates)
      .or(`id.eq.${id},request_code.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}
