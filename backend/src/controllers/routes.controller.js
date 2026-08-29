import { getSupabaseClient } from '../db/supabase.js';

export async function getApplicationRoutes(req, res, next) {
  try {
    const { type } = req.query;
    const client = getSupabaseClient();

    let query = client.from('routes').select('*');
    if (type) {
      query = query.eq('type', type);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}
