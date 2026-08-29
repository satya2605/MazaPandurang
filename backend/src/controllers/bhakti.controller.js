import { getSupabaseClient } from '../db/supabase.js';

export async function getBhaktiContent(req, res, next) {
  try {
    const { category } = req.query;
    const client = getSupabaseClient();

    let query = client.from('bhakti_content').select('*').eq('is_active', true);
    if (category && category !== 'Featured') {
      query = query.ilike('category', category);
    }

    const { data, error } = await query;

    if (error || !data || data.length === 0) {
      return res.json([
        {
          id: 'BHK-001',
          title: 'Maza Pandurang Abhang',
          marathiTitle: 'माझा पांडुरंग अभंग',
          artist: 'Pandit Bhimsen Joshi',
          category: 'Abhang',
          duration: '04:30',
          externalUrl: 'https://example.com/audio/abhang1.mp3',
        },
        {
          id: 'BHK-002',
          title: 'Gyaneshwar Mauli Haripath',
          marathiTitle: 'ज्ञानेश्वर माउली हरिपाठ',
          artist: 'Lata Mangeshkar',
          category: 'Abhang',
          duration: '06:15',
          externalUrl: 'https://example.com/audio/haripath.mp3',
        },
      ]);
    }

    const formatted = data.map((b) => ({
      id: b.id,
      title: b.title,
      marathiTitle: b.marathi_title,
      artist: b.artist,
      category: b.category,
      duration: b.duration,
      externalUrl: b.external_url,
      thumbnailUrl: b.thumbnail_url || '',
    }));

    return res.json(formatted);
  } catch (err) {
    next(err);
  }
}
