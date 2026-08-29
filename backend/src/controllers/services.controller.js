import { getSupabaseClient } from '../db/supabase.js';
import { findNearestService } from '../utils/geo.js';

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
      // Fallback demo data if database table not yet seeded
      return res.json([
        {
          id: 'DEMO-SRV-001',
          serviceCode: 'SRV-MED-001',
          category: 'Medical',
          name: 'Saswad Emergency Medical Camp',
          description: '24/7 First Aid, Ambulance, Free Medication.',
          address: 'Saswad Palkhi Ground',
          latitude: 18.3411,
          longitude: 74.0305,
          contactPhone: '+919822011223',
          availabilityStatus: 'Open 24/7',
          isVerified: true,
          images: [],
        },
      ]);
    }

    // Format response consistent with Flutter model expectations
    const formatted = (data || []).map((s) => ({
      id: s.id,
      serviceCode: s.service_id || s.serviceCode || s.id,
      category: s.category,
      name: s.name,
      description: s.description || '',
      address: s.address || '',
      latitude: parseFloat(s.latitude),
      longitude: parseFloat(s.longitude),
      contactPhone: s.contact_phone || '',
      availabilityStatus: s.availability_status || 'Open 24/7',
      isVerified: s.is_verified ?? true,
      images: (s.service_images || []).map((img) => img.storage_path),
    }));

    return res.json(formatted);
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
      .or(`id.eq.${id},service_id.eq.${id}`)
      .single();

    if (error || !data) {
      return res.status(404).json({
        success: false,
        error: { message: `Service '${id}' not found` },
      });
    }

    return res.json({
      id: data.id,
      serviceCode: data.service_id,
      category: data.category,
      name: data.name,
      description: data.description || '',
      address: data.address || '',
      latitude: parseFloat(data.latitude),
      longitude: parseFloat(data.longitude),
      contactPhone: data.contact_phone || '',
      availabilityStatus: data.availability_status || 'Open 24/7',
      isVerified: data.is_verified ?? true,
      images: (data.service_images || []).map((img) => img.storage_path),
    });
  } catch (err) {
    next(err);
  }
}

export async function submitServiceReport(req, res, next) {
  try {
    const { serviceId } = req.params;
    const { reportType, description, reporterId } = req.body;

    if (!description) {
      return res.status(400).json({
        success: false,
        error: { message: 'Description is required for service report' },
      });
    }

    const client = getSupabaseClient();

    // Verify service exists or fetch UUID
    const { data: serviceData } = await client
      .from('services')
      .select('id')
      .or(`id.eq.${serviceId},service_id.eq.${serviceId}`)
      .maybeSingle();

    const targetServiceUuid = serviceData ? serviceData.id : null;

    if (!targetServiceUuid) {
      return res.status(404).json({
        success: false,
        error: { message: `Service '${serviceId}' not found` },
      });
    }

    const { data, error } = await client
      .from('service_reports')
      .insert([
        {
          service_id: targetServiceUuid,
          reporter_id: reporterId || null,
          report_type: reportType || 'incorrect_information',
          description,
          status: 'pending',
        },
      ])
      .select()
      .single();

    if (error) {
      throw error;
    }

    return res.status(201).json({
      success: true,
      message: 'Service report submitted successfully for review',
      report: data,
    });
  } catch (err) {
    next(err);
  }
}

export async function getNearestServices(req, res, next) {
  try {
    const { latitude, longitude, category } = req.query;

    const userLat = parseFloat(latitude);
    const userLon = parseFloat(longitude);

    if (isNaN(userLat) || isNaN(userLon)) {
      return res.status(400).json({
        success: false,
        error: { message: 'Valid latitude and longitude query parameters required' },
      });
    }

    const client = getSupabaseClient();

    let query = client.from('services').select('*');
    if (category) {
      query = query.ilike('category', category);
    }

    const { data: services } = await query;
    const nearest = findNearestService(userLat, userLon, services || []);

    return res.json({
      success: true,
      userLocation: { latitude: userLat, longitude: userLon },
      nearestService: nearest,
    });
  } catch (err) {
    next(err);
  }
}
