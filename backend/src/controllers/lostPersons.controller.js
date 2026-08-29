import { getSupabaseClient } from '../db/supabase.js';
import { config } from '../config/env.js';

export async function createLostPersonReport(req, res, next) {
  try {
    const { personName, age, description, lastSeenLocation, latitude, longitude, reporterId } = req.body;

    if (!personName || !description || !lastSeenLocation) {
      return res.status(400).json({
        success: false,
        error: { message: 'Person name, description, and last seen location are required' },
      });
    }

    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .insert([
        {
          person_name: personName,
          age: age ? parseInt(age) : null,
          description,
          last_seen_location: lastSeenLocation,
          last_seen_latitude: latitude ? parseFloat(latitude) : null,
          last_seen_longitude: longitude ? parseFloat(longitude) : null,
          reporter_id: reporterId || null,
          is_approved_by_admin: false, // Must be approved by admin before broadcast
          status: 'missing',
        },
      ])
      .select()
      .single();

    if (error) {
      throw error;
    }

    return res.status(201).json({
      success: true,
      message: 'Lost person report submitted for admin verification',
      report: data,
    });
  } catch (err) {
    next(err);
  }
}

export async function getApprovedLostPersons(req, res, next) {
  try {
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .select(`
        *,
        lost_person_images (id, storage_path, created_at)
      `)
      .eq('is_approved_by_admin', true)
      .eq('status', 'missing');

    if (error) {
      return res.json([]);
    }

    const formatted = (data || []).map((p) => ({
      id: p.id,
      personName: p.person_name,
      age: p.age,
      description: p.description,
      lastSeenLocation: p.last_seen_location,
      status: p.status,
      createdAt: p.created_at,
      images: (p.lost_person_images || []).map((img) => img.storage_path),
    }));

    return res.json(formatted);
  } catch (err) {
    next(err);
  }
}

export async function getLostPersonById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .select(`
        *,
        lost_person_images (id, storage_path, created_at),
        lost_person_sightings (id, location_description, latitude, longitude, created_at)
      `)
      .eq('id', id)
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: { message: `Lost person report '${id}' not found` },
      });
    }

    // Generate signed URLs for private images
    const signedImageUrls = [];
    if (data.lost_person_images && data.lost_person_images.length > 0) {
      for (const img of data.lost_person_images) {
        const { data: signedData } = await client.storage
          .from(config.storageBuckets.lostPerson)
          .createSignedUrl(img.storage_path, 3600); // 1 hour expiration

        if (signedData?.signedUrl) {
          signedImageUrls.push(signedData.signedUrl);
        }
      }
    }

    return res.json({
      id: data.id,
      personName: data.person_name,
      age: data.age,
      description: data.description,
      lastSeenLocation: data.last_seen_location,
      isApprovedByAdmin: data.is_approved_by_admin,
      status: data.status,
      createdAt: data.created_at,
      signedImageUrls,
      sightings: data.lost_person_sightings || [],
    });
  } catch (err) {
    next(err);
  }
}

export async function createSighting(req, res, next) {
  try {
    const { id } = req.params;
    const { locationDescription, latitude, longitude, reporterId } = req.body;

    if (!locationDescription) {
      return res.status(400).json({
        success: false,
        error: { message: 'Location description is required for sighting report' },
      });
    }

    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_sightings')
      .insert([
        {
          lost_person_id: id,
          reporter_id: reporterId || null,
          location_description: locationDescription,
          latitude: latitude ? parseFloat(latitude) : null,
          longitude: longitude ? parseFloat(longitude) : null,
        },
      ])
      .select()
      .single();

    if (error) {
      throw error;
    }

    return res.status(201).json({
      success: true,
      message: 'Sighting recorded successfully',
      sighting: data,
    });
  } catch (err) {
    next(err);
  }
}
