import { getSupabaseClient } from '../db/supabase.js';
import { calculateDistance } from '../utils/geo.js';

export async function getAllServices(req, res, next) {
  try {
    const { category, search, status, all } = req.query;
    const client = getSupabaseClient();

    let query = client
      .from('services')
      .select('*, service_images(id, storage_path), service_details(*)');

    if (all !== 'true') {
      query = query.eq('is_verified', true);
    }
    if (category) {
      const formattedCat = category.charAt(0).toUpperCase() + category.slice(1).toLowerCase();
      query = query.eq('category', formattedCat);
    }
    if (status) {
      query = query.eq('availability_status', status);
    }
    if (search) {
      query = query.or(`name.ilike.%${search}%,description.ilike.%${search}%,address.ilike.%${search}%`);
    }

    const { data, error } = await query;
    if (error) throw error;

    const mapped = (data || []).map((item) => {
      const details = Array.isArray(item.service_details)
        ? item.service_details[0] || {}
        : item.service_details || {};

      return {
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
        capacity: details.service_capacity || item.capacity,
        operatingHours: details.operating_hours || item.operating_hours,
        isOpen24Hours: details.is_open_24_hours || false,
        mealsPerDay: details.meals_per_day,
        beneficiariesPerDay: details.beneficiaries_per_day,
        doctorsAvailable: details.doctors_available,
        bedsAvailable: details.beds_available,
        medicinesAvailable: details.medicines_available,
        waterCapacityLitresPerDay: details.water_capacity_litres_per_day,
        waterTapsCount: details.water_taps_count,
        availableSpaces: details.available_spaces,
        currentOccupancy: details.current_occupancy,
        alternateContactPhone: details.alternate_contact_phone || item.alternate_contact_phone,
        whatsappAvailable: details.whatsapp_available ?? item.whatsapp_available ?? false,
        wheelchairAccessible: details.wheelchair_accessible ?? item.wheelchair_accessible ?? false,
        drinkingWaterAvailable: details.drinking_water ?? item.drinking_water_available ?? false,
        seatingAvailable: details.seating_available ?? item.seating_available ?? false,
        accessibleToilet: details.accessible_toilet ?? item.accessible_toilet ?? false,
        seniorCitizenFriendly: details.senior_citizen_friendly ?? item.senior_citizen_friendly ?? false,
        importantInstructions: details.important_instructions || item.important_instructions,
        emergencySupportAvailable: item.emergency_support_available ?? false,
        ambulanceAvailable: item.ambulance_available ?? false,
        emergencyContactPhone: item.emergency_contact_phone,
        ambulanceContactPhone: item.ambulance_contact_phone,
        emergencyInstructions: item.emergency_instructions,
        categoryDetails: item.category_details || {},
        serviceDetails: details,
        images: item.service_images || [],
      };
    });

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
      .select('*, service_images(id, storage_path), service_details(*)')
      .or(`id.eq.${id},service_id.eq.${id}`)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return res.status(404).json({ error: 'Service not found' });
      }
      throw error;
    }

    const details = Array.isArray(data.service_details)
      ? data.service_details[0] || {}
      : data.service_details || {};

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
      capacity: details.service_capacity || data.capacity,
      operatingHours: details.operating_hours || data.operating_hours,
      isOpen24Hours: details.is_open_24_hours || false,
      mealsPerDay: details.meals_per_day,
      beneficiariesPerDay: details.beneficiaries_per_day,
      doctorsAvailable: details.doctors_available,
      bedsAvailable: details.beds_available,
      medicinesAvailable: details.medicines_available,
      waterCapacityLitresPerDay: details.water_capacity_litres_per_day,
      waterTapsCount: details.water_taps_count,
      availableSpaces: details.available_spaces,
      currentOccupancy: details.current_occupancy,
      alternateContactPhone: details.alternate_contact_phone || data.alternate_contact_phone,
      whatsappAvailable: details.whatsapp_available ?? data.whatsapp_available ?? false,
      wheelchairAccessible: details.wheelchair_accessible ?? data.wheelchair_accessible ?? false,
      drinkingWaterAvailable: details.drinking_water ?? data.drinking_water_available ?? false,
      seatingAvailable: details.seating_available ?? data.seating_available ?? false,
      accessibleToilet: details.accessible_toilet ?? data.accessible_toilet ?? false,
      seniorCitizenFriendly: details.senior_citizen_friendly ?? data.senior_citizen_friendly ?? false,
      importantInstructions: details.important_instructions || data.important_instructions,
      emergencySupportAvailable: data.emergency_support_available ?? false,
      ambulanceAvailable: data.ambulance_available ?? false,
      emergencyContactPhone: data.emergency_contact_phone,
      ambulanceContactPhone: data.ambulance_contact_phone,
      emergencyInstructions: data.emergency_instructions,
      categoryDetails: data.category_details || {},
      serviceDetails: details,
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
      provider_id,
      provider_type,
      provider_name,
      capacity,
      operating_hours,
      alternate_contact_phone,
      whatsapp_available,
      wheelchair_accessible,
      drinking_water_available,
      drinking_water,
      seating_available,
      accessible_toilet,
      senior_citizen_friendly,
      important_instructions,
      emergency_support_available,
      ambulance_available,
      emergency_contact_phone,
      ambulance_contact_phone,
      emergency_instructions,
      category_details,
      service_details,
    } = req.body;

    const client = getSupabaseClient();

    // 1. Core service insertion with strict server-side is_verified = false
    const corePayload = {
      service_id: service_id || `SRV-${Date.now()}`,
      category: category || 'Medical',
      name: name || 'Wari Seva Facility',
      description: description || '',
      address: address || 'Wari Route',
      latitude: latitude || 18.3411,
      longitude: longitude || 74.0305,
      contact_phone: contact_phone || '',
      availability_status: availability_status || 'Open 24/7',
      is_verified: false, // Security: server always ensures false for newly created services
      provider_id: provider_id || null,
      provider_type: provider_type || 'NGO',
      provider_name: provider_name || '',
      capacity: capacity || null,
      operating_hours: operating_hours || null,
      alternate_contact_phone: alternate_contact_phone || null,
      whatsapp_available: whatsapp_available === true,
      wheelchair_accessible: wheelchair_accessible === true,
      drinking_water_available: (drinking_water_available === true || drinking_water === true),
      seating_available: seating_available === true,
      accessible_toilet: accessible_toilet === true,
      senior_citizen_friendly: senior_citizen_friendly === true,
      important_instructions: important_instructions || null,
      emergency_support_available: emergency_support_available === true,
      ambulance_available: ambulance_available === true,
      emergency_contact_phone: emergency_contact_phone || null,
      ambulance_contact_phone: ambulance_contact_phone || null,
      emergency_instructions: emergency_instructions || null,
      category_details: category_details || {},
    };

    const { data: createdService, error: coreError } = await client
      .from('services')
      .insert(corePayload)
      .select()
      .single();

    if (coreError) throw coreError;

    // 2. Insert into public.service_details table using created UUID
    const sDetails = service_details || {};
    const detailsPayload = {
      service_id: createdService.id,
      service_capacity: sDetails.service_capacity || capacity || null,
      operating_hours: sDetails.operating_hours || operating_hours || null,
      is_open_24_hours: sDetails.is_open_24_hours === true || (operating_hours && operating_hours.toLowerCase().includes('24')),
      meals_per_day: sDetails.meals_per_day !== undefined ? sDetails.meals_per_day : (category_details?.meals_per_day || null),
      beneficiaries_per_day: sDetails.beneficiaries_per_day !== undefined ? sDetails.beneficiaries_per_day : (category_details?.beneficiaries_per_day || null),
      doctors_available: sDetails.doctors_available !== undefined ? sDetails.doctors_available : (category_details?.doctors_available || null),
      beds_available: sDetails.beds_available !== undefined ? sDetails.beds_available : (category_details?.beds_available || null),
      medicines_available: sDetails.medicines_available || category_details?.medicines_first_aid_available || null,
      water_capacity_litres_per_day: sDetails.water_capacity_litres_per_day !== undefined ? sDetails.water_capacity_litres_per_day : (category_details?.water_capacity_litres_per_day || null),
      water_taps_count: sDetails.water_taps_count !== undefined ? sDetails.water_taps_count : (category_details?.water_taps || null),
      available_spaces: sDetails.available_spaces !== undefined ? sDetails.available_spaces : (category_details?.available_beds_spaces || null),
      current_occupancy: sDetails.current_occupancy || category_details?.current_occupancy || null,
      alternate_contact_phone: sDetails.alternate_contact_phone || alternate_contact_phone || null,
      whatsapp_available: sDetails.whatsapp_available ?? whatsapp_available ?? false,
      wheelchair_accessible: sDetails.wheelchair_accessible ?? wheelchair_accessible ?? false,
      drinking_water: sDetails.drinking_water ?? (drinking_water || drinking_water_available) ?? false,
      seating_available: sDetails.seating_available ?? seating_available ?? false,
      accessible_toilet: sDetails.accessible_toilet ?? accessible_toilet ?? false,
      senior_citizen_friendly: sDetails.senior_citizen_friendly ?? senior_citizen_friendly ?? false,
      important_instructions: sDetails.important_instructions || important_instructions || null,
    };

    const { data: createdDetails, error: detailsError } = await client
      .from('service_details')
      .upsert(detailsPayload, { onConflict: 'service_id' })
      .select()
      .maybeSingle();

    if (detailsError) {
      console.warn('[ServicesController] service_details upsert notice:', detailsError.message);
    }

    res.status(201).json({
      ...createdService,
      service_details: createdDetails || detailsPayload,
    });
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
    if (body.capacity !== undefined) updates.capacity = body.capacity;
    if (body.operating_hours !== undefined) updates.operating_hours = body.operating_hours;
    if (body.alternate_contact_phone !== undefined) updates.alternate_contact_phone = body.alternate_contact_phone;
    if (body.whatsapp_available !== undefined) updates.whatsapp_available = body.whatsapp_available;
    if (body.wheelchair_accessible !== undefined) updates.wheelchair_accessible = body.wheelchair_accessible;
    if (body.drinking_water_available !== undefined) updates.drinking_water_available = body.drinking_water_available;
    if (body.seating_available !== undefined) updates.seating_available = body.seating_available;
    if (body.accessible_toilet !== undefined) updates.accessible_toilet = body.accessible_toilet;
    if (body.senior_citizen_friendly !== undefined) updates.senior_citizen_friendly = body.senior_citizen_friendly;
    if (body.important_instructions !== undefined) updates.important_instructions = body.important_instructions;
    if (body.emergency_support_available !== undefined) updates.emergency_support_available = body.emergency_support_available;
    if (body.ambulance_available !== undefined) updates.ambulance_available = body.ambulance_available;
    if (body.emergency_contact_phone !== undefined) updates.emergency_contact_phone = body.emergency_contact_phone;
    if (body.ambulance_contact_phone !== undefined) updates.ambulance_contact_phone = body.ambulance_contact_phone;
    if (body.emergency_instructions !== undefined) updates.emergency_instructions = body.emergency_instructions;
    if (body.category_details !== undefined) updates.category_details = body.category_details;

    const { data: updatedService, error: updateError } = await client
      .from('services')
      .update(updates)
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (updateError) throw updateError;

    // Update / Upsert in public.service_details
    const sDetails = body.service_details || {};
    const serviceUuid = updatedService.id;
    const detailsPayload = {
      service_id: serviceUuid,
      updated_at: new Date().toISOString(),
    };
    if (sDetails.service_capacity !== undefined || body.capacity !== undefined) {
      detailsPayload.service_capacity = sDetails.service_capacity || body.capacity;
    }
    if (sDetails.operating_hours !== undefined || body.operating_hours !== undefined) {
      detailsPayload.operating_hours = sDetails.operating_hours || body.operating_hours;
      detailsPayload.is_open_24_hours = (detailsPayload.operating_hours && detailsPayload.operating_hours.toLowerCase().includes('24'));
    }
    if (sDetails.meals_per_day !== undefined || body.category_details?.meals_per_day !== undefined) {
      detailsPayload.meals_per_day = sDetails.meals_per_day ?? body.category_details?.meals_per_day;
    }
    if (sDetails.beneficiaries_per_day !== undefined || body.category_details?.beneficiaries_per_day !== undefined) {
      detailsPayload.beneficiaries_per_day = sDetails.beneficiaries_per_day ?? body.category_details?.beneficiaries_per_day;
    }
    if (sDetails.doctors_available !== undefined || body.category_details?.doctors_available !== undefined) {
      detailsPayload.doctors_available = sDetails.doctors_available ?? body.category_details?.doctors_available;
    }
    if (sDetails.beds_available !== undefined || body.category_details?.beds_available !== undefined) {
      detailsPayload.beds_available = sDetails.beds_available ?? body.category_details?.beds_available;
    }
    if (sDetails.medicines_available !== undefined || body.category_details?.medicines_first_aid_available !== undefined) {
      detailsPayload.medicines_available = sDetails.medicines_available ?? body.category_details?.medicines_first_aid_available;
    }
    if (sDetails.water_capacity_litres_per_day !== undefined || body.category_details?.water_capacity_litres_per_day !== undefined) {
      detailsPayload.water_capacity_litres_per_day = sDetails.water_capacity_litres_per_day ?? body.category_details?.water_capacity_litres_per_day;
    }
    if (sDetails.water_taps_count !== undefined || body.category_details?.water_taps !== undefined) {
      detailsPayload.water_taps_count = sDetails.water_taps_count ?? body.category_details?.water_taps;
    }
    if (sDetails.available_spaces !== undefined || body.category_details?.available_beds_spaces !== undefined) {
      detailsPayload.available_spaces = sDetails.available_spaces ?? body.category_details?.available_beds_spaces;
    }
    if (sDetails.current_occupancy !== undefined || body.category_details?.current_occupancy !== undefined) {
      detailsPayload.current_occupancy = sDetails.current_occupancy ?? body.category_details?.current_occupancy;
    }
    if (sDetails.alternate_contact_phone !== undefined || body.alternate_contact_phone !== undefined) {
      detailsPayload.alternate_contact_phone = sDetails.alternate_contact_phone ?? body.alternate_contact_phone;
    }
    if (sDetails.whatsapp_available !== undefined || body.whatsapp_available !== undefined) {
      detailsPayload.whatsapp_available = sDetails.whatsapp_available ?? body.whatsapp_available;
    }
    if (sDetails.wheelchair_accessible !== undefined || body.wheelchair_accessible !== undefined) {
      detailsPayload.wheelchair_accessible = sDetails.wheelchair_accessible ?? body.wheelchair_accessible;
    }
    if (sDetails.drinking_water !== undefined || body.drinking_water_available !== undefined) {
      detailsPayload.drinking_water = sDetails.drinking_water ?? body.drinking_water_available;
    }
    if (sDetails.seating_available !== undefined || body.seating_available !== undefined) {
      detailsPayload.seating_available = sDetails.seating_available ?? body.seating_available;
    }
    if (sDetails.accessible_toilet !== undefined || body.accessible_toilet !== undefined) {
      detailsPayload.accessible_toilet = sDetails.accessible_toilet ?? body.accessible_toilet;
    }
    if (sDetails.senior_citizen_friendly !== undefined || body.senior_citizen_friendly !== undefined) {
      detailsPayload.senior_citizen_friendly = sDetails.senior_citizen_friendly ?? body.senior_citizen_friendly;
    }
    if (sDetails.important_instructions !== undefined || body.important_instructions !== undefined) {
      detailsPayload.important_instructions = sDetails.important_instructions ?? body.important_instructions;
    }

    const { data: updatedDetails, error: detailsError } = await client
      .from('service_details')
      .upsert(detailsPayload, { onConflict: 'service_id' })
      .select()
      .maybeSingle();

    if (detailsError) {
      console.warn('[ServicesController] service_details update notice:', detailsError.message);
    }

    res.json({
      ...updatedService,
      service_details: updatedDetails || detailsPayload,
    });
  } catch (err) {
    next(err);
  }
}

export async function getServiceImages(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    let serviceUuid = id;
    if (!id.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
      const { data: s } = await client.from('services').select('id').eq('service_id', id).maybeSingle();
      if (s) serviceUuid = s.id;
    }

    const { data, error } = await client
      .from('service_images')
      .select('*')
      .eq('service_id', serviceUuid);

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function addServiceImage(req, res, next) {
  try {
    const { id } = req.params;
    const { storage_path } = req.body;
    const client = getSupabaseClient();

    if (!storage_path) {
      return res.status(400).json({ error: 'storage_path is required' });
    }

    let serviceUuid = id;
    if (!id.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i)) {
      const { data: s } = await client.from('services').select('id').eq('service_id', id).maybeSingle();
      if (s) serviceUuid = s.id;
    }

    const { data, error } = await client
      .from('service_images')
      .insert({
        service_id: serviceUuid,
        storage_path,
      })
      .select()
      .single();

    if (error) throw error;
    res.status(201).json(data);
  } catch (err) {
    next(err);
  }
}

export async function deleteServiceImage(req, res, next) {
  try {
    const { id, imageId } = req.params;
    const client = getSupabaseClient();

    const { error } = await client
      .from('service_images')
      .delete()
      .eq('id', imageId);

    if (error) throw error;
    res.json({ success: true, message: 'Service image record removed' });
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

    const list = (data || []).map((item) => ({
      ...item,
      distanceKm: Math.round(calculateDistance(lat, lng, item.latitude, item.longitude) * 100) / 100,
    }));

    list.sort((a, b) => a.distanceKm - b.distanceKm);
    res.json(list.slice(0, limit));
  } catch (err) {
    next(err);
  }
}
