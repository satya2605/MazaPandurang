import { getSupabaseClient } from '../db/supabase.js';

export async function getProfileById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Profile not found' });
      }
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateProfile(req, res, next) {
  try {
    const { id } = req.params;
    const { display_name, phone, email, status, language, profile_photo_url } = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (display_name !== undefined) updates.display_name = display_name;
    if (phone !== undefined) updates.phone = phone;
    if (email !== undefined) updates.email = email;
    if (status !== undefined) updates.status = status;
    if (language !== undefined) updates.language = language;
    if (profile_photo_url !== undefined) updates.profile_photo_url = profile_photo_url;

    const { data, error } = await client
      .from('profiles')
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
