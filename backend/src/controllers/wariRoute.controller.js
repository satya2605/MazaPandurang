import { getSupabaseClient } from '../db/supabase.js';

export async function getWariRoute(req, res, next) {
  try {
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('wari_route')
      .select('*')
      .order('sequence_order', { ascending: true });

    if (error || !data || data.length === 0) {
      return res.json([
        { id: '1', stageName: 'Alandi (आळंदी)', sequenceOrder: 1, latitude: 18.6772, longitude: 73.8967 },
        { id: '2', stageName: 'Pune Stay (पुणे मुक्काम)', sequenceOrder: 2, latitude: 18.5204, longitude: 73.8567 },
        { id: '3', stageName: 'Dive Ghat (दिवे घाट)', sequenceOrder: 3, latitude: 18.4100, longitude: 73.9700 },
        { id: '4', stageName: 'Saswad Stay (सासवड मुक्काम)', sequenceOrder: 4, latitude: 18.3411, longitude: 74.0305 },
        { id: '5', stageName: 'Jejuri (जेजुरी)', sequenceOrder: 5, latitude: 18.2764, longitude: 74.1611 },
        { id: '6', stageName: 'Lonand (लोणंद)', sequenceOrder: 6, latitude: 18.0415, longitude: 74.1906 },
        { id: '7', stageName: 'Phaltan (फलटण)', sequenceOrder: 7, latitude: 17.9877, longitude: 74.4312 },
        { id: '8', stageName: 'Pandharpur (पंढरपूर धाम)', sequenceOrder: 8, latitude: 17.6777, longitude: 75.3283 },
      ]);
    }

    const formatted = data.map((st) => ({
      id: st.id,
      stageName: st.stage_name,
      sequenceOrder: st.sequence_order,
      latitude: parseFloat(st.latitude),
      longitude: parseFloat(st.longitude),
    }));

    return res.json(formatted);
  } catch (err) {
    next(err);
  }
}
