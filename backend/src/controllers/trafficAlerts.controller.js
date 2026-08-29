import { getSupabaseClient } from '../db/supabase.js';

export async function getAllTrafficAlerts(req, res, next) {
  try {
    const { status, severity } = req.query;
    const client = getSupabaseClient();

    let query = client.from('traffic_alerts').select('*');
    if (status) {
      query = query.eq('status', status);
    } else {
      query = query.eq('status', 'ACTIVE');
    }
    if (severity) {
      query = query.eq('severity', severity);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function createTrafficAlert(req, res, next) {
  try {
    const { alert_code, title, description, type, severity, latitude, longitude, created_by } = req.body;
    const client = getSupabaseClient();

    const payload = {
      alert_code: alert_code || `TRF-${Date.now()}`,
      title: title || 'Traffic Slowdown',
      description: description || '',
      type: type || 'SLOW_TRAFFIC',
      severity: severity || 'MEDIUM',
      status: 'ACTIVE',
      latitude: latitude || 18.3411,
      longitude: longitude || 74.0305,
      created_by: created_by || null,
    };

    const { data, error } = await client
      .from('traffic_alerts')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateTrafficAlert(req, res, next) {
  try {
    const { id } = req.params;
    const { status, severity, description } = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (status !== undefined) updates.status = status;
    if (severity !== undefined) updates.severity = severity;
    if (description !== undefined) updates.description = description;

    const { data, error } = await client
      .from('traffic_alerts')
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
