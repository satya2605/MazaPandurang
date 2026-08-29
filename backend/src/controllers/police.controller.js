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
