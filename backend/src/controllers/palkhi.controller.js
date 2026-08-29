import { getSupabaseClient } from '../db/supabase.js';

export async function getPalkhiTracking(req, res, next) {
  try {
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('palkhi_tracking')
      .select('*')
      .order('updated_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error || !data) {
      // Fallback demo stage data
      return res.json({
        id: 'PALKHI-DEMO-001',
        name: 'Sant Dnyaneshwar Maharaj Palkhi',
        currentStage: 'Saswad Stay (सासवड मुक्काम)',
        nextStop: 'Jejuri (जेजुरी)',
        latitude: 18.3411,
        longitude: 74.0305,
        lastUpdated: new Date().toISOString(),
      });
    }

    return res.json({
      id: data.id,
      name: data.name,
      currentStage: data.current_stage,
      nextStop: data.next_stop,
      latitude: parseFloat(data.latitude),
      longitude: parseFloat(data.longitude),
      lastUpdated: data.updated_at,
    });
  } catch (err) {
    next(err);
  }
}
