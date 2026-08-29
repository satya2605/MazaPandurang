import { getSupabaseClient } from '../db/supabase.js';
import { config } from '../config/env.js';

export async function uploadServiceImage(req, res, next) {
  try {
    const { serviceId } = req.params;
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: { message: 'No image file uploaded or invalid format (allowed: JPG, PNG, WEBP)' },
      });
    }

    const client = getSupabaseClient();
    const fileName = `${serviceId}/${Date.now()}_${req.file.originalname}`;
    const bucketName = config.storageBuckets.services;

    const { data: uploadData, error: uploadError } = await client.storage
      .from(bucketName)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      throw uploadError;
    }

    // Save reference in service_images table
    const { data: imgRecord } = await client
      .from('service_images')
      .insert([
        {
          service_id: serviceId,
          storage_path: uploadData.path,
        },
      ])
      .select()
      .maybeSingle();

    const publicUrl = `${config.storageBuckets.publicUrlPrefix}/${bucketName}/${uploadData.path}`;

    return res.status(201).json({
      success: true,
      message: 'Service image uploaded successfully',
      storagePath: uploadData.path,
      publicUrl,
      record: imgRecord,
    });
  } catch (err) {
    next(err);
  }
}

export async function uploadLostPersonImage(req, res, next) {
  try {
    const { id } = req.params;
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: { message: 'No image file uploaded or invalid format' },
      });
    }

    const client = getSupabaseClient();
    const fileName = `${id}/${Date.now()}_${req.file.originalname}`;
    const bucketName = config.storageBuckets.lostPerson;

    // Upload to PRIVATE bucket
    const { data: uploadData, error: uploadError } = await client.storage
      .from(bucketName)
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      throw uploadError;
    }

    // Save reference in lost_person_images table
    const { data: imgRecord } = await client
      .from('lost_person_images')
      .insert([
        {
          lost_person_id: id,
          storage_path: uploadData.path,
        },
      ])
      .select()
      .maybeSingle();

    return res.status(201).json({
      success: true,
      message: 'Private lost person photo uploaded successfully',
      storagePath: uploadData.path,
      record: imgRecord,
    });
  } catch (err) {
    next(err);
  }
}
