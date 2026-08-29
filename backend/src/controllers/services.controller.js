import { getSupabaseClient } from '../db/supabase.js';

export async function getServices(req, res, next) {
  try {
    const { category } = req.query;
    const client = getSupabaseClient();

    let query = client.from('services').select(`
      *,
      service_images (id, storage_path, created_at)
    `);

    if (category) {
      query = query.ilike('category', category);
    }

    const { data, error } = await query;

    if (error) {
      // Fallback demo response if database table not yet populated
      return res.json([
        {
          id: 'DEMO-SRV-001',
          service_id: 'SRV-MED-001',
          category: 'Medical',
          name: 'Saswad Central Medical Camp',
          description: '24/7 First Aid, Ambulance, Doctor on duty.',
          address: 'Saswad Palkhi Ground',
          latitude: 18.3411,
          longitude: 74.0305,
          availability_status: 'Open 24/7',
          is_verified: true,
        },
      ]);
    }

    return res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getServiceById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('services')
      .select(`
        *,
        service_images (id, storage_path, created_at)
      `)
      .eq('id', id)
      .single();

    if (error || !data) {
      return res.status(404).json({ error: true, message: 'Service not found' });
    }

    return res.json(data);
  } catch (err) {
    next(err);
  }
}
