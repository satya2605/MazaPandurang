import { getSupabaseClient } from '../db/supabase.js';
import { config } from '../config/env.js';

export async function getApprovedLostPersons(req, res, next) {
  try {
    const { all } = req.query;
    const client = getSupabaseClient();

    let query = client.from('lost_person_reports').select('*, lost_person_images(id, storage_path)');
    if (all !== 'true') {
      query = query.eq('is_approved_by_admin', true).eq('status', 'missing');
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function createLostPersonReport(req, res, next) {
  try {
    const { person_name, age, description, last_seen_location, last_seen_latitude, last_seen_longitude, reporter_id } = req.body;
    const client = getSupabaseClient();

    const payload = {
      person_name,
      age: age ? parseInt(age, 10) : null,
      description,
      last_seen_location,
      last_seen_latitude: last_seen_latitude ? parseFloat(last_seen_latitude) : null,
      last_seen_longitude: last_seen_longitude ? parseFloat(last_seen_longitude) : null,
      reporter_id: reporter_id || null,
      is_approved_by_admin: false,
      status: 'missing',
    };

    const { data, error } = await client
      .from('lost_person_reports')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;

    res.status(201).json({
      message: 'Lost person report submitted successfully. Pending police/admin approval before public broadcast.',
      report: data,
    });
  } catch (err) {
    next(err);
  }
}

export async function updateLostPersonReport(req, res, next) {
  try {
    const { id } = req.params;
    const { is_approved_by_admin, status } = req.body;
    const client = getSupabaseClient();

    const updates = {};
    if (is_approved_by_admin !== undefined) updates.is_approved_by_admin = is_approved_by_admin;
    if (status !== undefined) updates.status = status;
    if (status === 'found') updates.resolved_at = new Date().toISOString();

    const { data, error } = await client
      .from('lost_person_reports')
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

export async function createSighting(req, res, next) {
  try {
    const { id } = req.params;
    const { reporter_id, location_description, latitude, longitude } = req.body;
    const client = getSupabaseClient();

    const payload = {
      lost_person_id: id,
      reporter_id: reporter_id || null,
      location_description,
      latitude: latitude ? parseFloat(latitude) : null,
      longitude: longitude ? parseFloat(longitude) : null,
    };

    const { data, error } = await client
      .from('lost_person_sightings')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function getSightings(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_sightings')
      .select('*')
      .eq('lost_person_id', id);

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getSignedPhotoUrl(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data: imgData, error: imgErr } = await client
      .from('lost_person_images')
      .select('storage_path')
      .eq('lost_person_id', id)
      .limit(1)
      .single();

    if (imgErr || !imgData) {
      return res.status(404).json({ error: 'Photo not found for this report' });
    }

    const { data: signedData, error: signedErr } = await client.storage
      .from(config.storageBuckets.lostPerson)
      .createSignedUrl(imgData.storage_path, 3600);

    if (signedErr) throw signedErr;
    res.json({ signedUrl: signedData.signedUrl });
  } catch (err) {
    next(err);
  }
}
