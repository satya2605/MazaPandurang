import { getSupabaseClient } from '../db/supabase.js';

export async function getAllNgos(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('ngos').select('*, ngo_images(id, image_url, caption)');
    if (status) {
      query = query.eq('status', status);
    } else {
      query = query.eq('status', 'approved');
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getNgoById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('ngos')
      .select('*, ngo_images(id, image_url, caption)')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'NGO not found' });
      }
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function createNgo(req, res, next) {
  try {
    const { user_id, name, registration_number, contact_person, phone, email, primary_category } = req.body;
    const client = getSupabaseClient();

    const payload = {
      user_id,
      name,
      registration_number,
      contact_person: contact_person || '',
      phone: phone || '',
      email: email || '',
      primary_category: primary_category || 'Medical & Food Seva',
      status: 'pending',
    };

    const { data, error } = await client
      .from('ngos')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateNgo(req, res, next) {
  try {
    const { id } = req.params;
    const { name, contact_person, phone, email, primary_category, status } = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (name !== undefined) updates.name = name;
    if (contact_person !== undefined) updates.contact_person = contact_person;
    if (phone !== undefined) updates.phone = phone;
    if (email !== undefined) updates.email = email;
    if (primary_category !== undefined) updates.primary_category = primary_category;
    if (status !== undefined) updates.status = status;

    const { data, error } = await client
      .from('ngos')
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

export async function getNgoImages(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('ngo_images')
      .select('*')
      .eq('ngo_id', id)
      .eq('is_active', true);

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}
