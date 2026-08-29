import { getSupabaseClient } from '../db/supabase.js';
import { calculateDistance } from '../utils/geo.js';

export async function getAllServices(req, res, next) {
  try {
    const { category, search, status } = req.query;
    const client = getSupabaseClient();

    let query = client
      .from('services')
      .select('*, service_images(id, storage_path)');

    if (category) {
      query = query.ilike('category', category);
    }
    if (status) {
      query = query.eq('availability_status', status);
    }
    if (search) {
      query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%,address.ilike.%${search}%`);
    }

    const { data, error } = await query;
    if (error) throw error;

    const mapped = (data || []).map((item) => ({
      id: item.id,
      serviceCode: item.service_id,
      category: item.category,
      name: item.name,
      description: item.description,
      address: item.address,
      latitude: parseFloat(item.latitude),
      longitude: parseFloat(item.longitude),
      contactPhone: item.contact_phone,
      availabilityStatus: item.availability_status,
      isVerified: item.is_verified,
      providerId: item.provider_id,
      providerType: item.provider_type,
      providerName: item.provider_name,
      images: item.service_images || [],
    }));

    res.json(mapped);
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
      .select('*, service_images(id, storage_path)')
      .or(`id.eq.${id},service_id.eq.${id}`)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Service not found' });
      }
      throw error;
    }

    res.json({
      id: data.id,
      serviceCode: data.service_id,
      category: data.category,
      name: data.name,
      description: data.description,
      address: data.address,
      latitude: parseFloat(data.latitude),
      longitude: parseFloat(data.longitude),
      contactPhone: data.contact_phone,
      availabilityStatus: data.availability_status,
      isVerified: data.is_verified,
      providerId: data.provider_id,
      providerType: data.provider_type,
      providerName: data.provider_name,
      images: data.service_images || [],
    });
  } catch (err) {
    next(err);
  }
}

export async function createService(req, res, next) {
  try {
    const {
      service_id,
      category,
      name,
      description,
      address,
      latitude,
      longitude,
      contact_phone,
      availability_status,
      is_verified,
      provider_id,
      provider_type,
      provider_name,
    } = req.body;

    const client = getSupabaseClient();
    const payload = {
      service_id: service_id || `SRV-${Date.now()}`,
      category: category || 'Medical',
      name: name || 'Wari Seva Facility',
      description: description || '',
      address: address || 'Wari Route',
      latitude: latitude || 18.3411,
      longitude: longitude || 74.0305,
      contact_phone: contact_phone || '',
      availability_status: availability_status || 'Open 24/7',
      is_verified: is_verified !== undefined ? is_verified : false,
      provider_id: provider_id || null,
      provider_type: provider_type || 'NGO',
      provider_name: provider_name || '',
    };

    const { data, error } = await client
      .from('services')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function updateService(req, res, next) {
  try {
    const { id } = req.params;
    const body = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (body.name !== undefined) updates.name = body.name;
    if (body.description !== undefined) updates.description = body.description;
    if (body.address !== undefined) updates.address = body.address;
    if (body.latitude !== undefined) updates.latitude = body.latitude;
    if (body.longitude !== undefined) updates.longitude = body.longitude;
    if (body.contact_phone !== undefined) updates.contact_phone = body.contact_phone;
    if (body.availability_status !== undefined) updates.availability_status = body.availability_status;
    if (body.is_verified !== undefined) updates.is_verified = body.is_verified;
    if (body.provider_type !== undefined) updates.provider_type = body.provider_type;
    if (body.provider_name !== undefined) updates.provider_name = body.provider_name;

    const { data, error } = await client
      .from('services')
      .update(updates)
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function getServiceImages(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('service_images')
      .select('*')
      .eq('service_id', id);

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getNearestServices(req, res, next) {
  try {
    const lat = parseFloat(req.query.latitude);
    const lng = parseFloat(req.query.longitude);
    const limit = parseInt(req.query.limit || '10', 10);
    const category = req.query.category;

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ error: 'Valid latitude and longitude required' });
    }

    const client = getSupabaseClient();
    let query = client.from('services').select('*');
    if (category) {
      query = query.ilike('category', category);
    }

    const { data, error } = await query;
    if (error) throw error;

    const list = (data || []).map((item) => {
      const distanceKm = calculateDistance(lat, lng, item.latitude, item.longitude);
      return {
        ...item,
        distanceKm: Math.round(distanceKm * 100) / 100,
      };
    });

    list.sort((a, b) => a.distanceKm - b.distanceKm);
    res.json(list.slice(0, limit));
  } catch (err) {
    next(err);
  }
}
