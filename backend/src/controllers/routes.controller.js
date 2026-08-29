import { getSupabaseClient } from '../db/supabase.js';

export async function getApplicationRoutes(req, res, next) {
  try {
    const { type } = req.query;
    const client = getSupabaseClient();

    let query = client.from('routes').select('*');
    if (type) {
      query = query.eq('type', type);
    }

    let { data, error } = await query;
    if (error) {
      const { data: wariData } = await client.from('wari_route').select('*');
      data = wariData || [];
    }
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}
