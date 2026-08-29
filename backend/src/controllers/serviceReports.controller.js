import { getSupabaseClient } from '../db/supabase.js';

export async function createServiceReport(req, res, next) {
  try {
    const { service_id, reporter_id, report_type, description } = req.body;
    const client = getSupabaseClient();

    const payload = {
      service_id,
      reporter_id: reporter_id || null,
      report_type: report_type || 'INCORRECT_INFORMATION',
      description: description || '',
      status: 'pending',
    };

    const { data, error } = await client
      .from('service_reports')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function getServiceReports(req, res, next) {
  try {
    const { status, service_id } = req.query;
    const client = getSupabaseClient();

    let query = client.from('service_reports').select('*, services(name, category)');
    if (status) {
      query = query.eq('status', status);
    }
    if (service_id) {
      query = query.eq('service_id', service_id);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function updateServiceReport(req, res, next) {
  try {
    const { id } = req.params;
    const { status, admin_notes } = req.body;
    const client = getSupabaseClient();

    const updates = {};
    if (status !== undefined) updates.status = status;
    if (admin_notes !== undefined) updates.admin_notes = admin_notes;
    if (status === 'resolved' || status === 'rejected') {
      updates.resolved_at = new Date().toISOString();
    }

    const { data, error } = await client
      .from('service_reports')
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
