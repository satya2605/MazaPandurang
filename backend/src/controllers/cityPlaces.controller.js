import { getSupabaseClient } from '../db/supabase.js';

export async function getCityPlaces(req, res, next) {
  try {
    const { category } = req.query;
    const client = getSupabaseClient();

    let query = client.from('city_places').select('*').eq('is_active', true);
    if (category) {
      query = query.ilike('category', category);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}
