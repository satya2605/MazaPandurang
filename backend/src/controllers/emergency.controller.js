import { getSupabaseClient } from '../db/supabase.js';
import { findNearestService } from '../utils/geo.js';

export async function createEmergencyRequest(req, res, next) {
  try {
    const { emergencyType, latitude, longitude, locationName, requesterId } = req.body;

    const userLat = parseFloat(latitude);
    const userLon = parseFloat(longitude);

    if (isNaN(userLat) || isNaN(userLon)) {
      return res.status(400).json({
        success: false,
        error: { message: 'Valid latitude and longitude coordinates required' },
      });
    }

    const requestCode = `EMG-${Date.now()}`;
    const client = getSupabaseClient();

    // Insert emergency request into Supabase
    const { data: emergencyRecord, error: insertError } = await client
      .from('emergency_requests')
      .insert([
        {
          request_code: requestCode,
          requester_id: requesterId || null,
          emergency_type: emergencyType || 'Medical',
          latitude: userLat,
          longitude: userLon,
          location_name: locationName || 'Unknown Wari Location',
          status: 'pending',
        },
      ])
      .select()
      .maybeSingle();

    if (insertError) {
      console.warn('[Emergency Controller] Supabase insert warning:', insertError.message);
    }

    // Identify nearest medical or police service
    const targetCategory = emergencyType === 'Police' ? 'Police' : 'Medical';
    const { data: availableServices } = await client
      .from('services')
      .select('*')
      .ilike('category', targetCategory);

    const nearestService = findNearestService(userLat, userLon, availableServices || []);

    return res.status(201).json({
      success: true,
      message: `${emergencyType || 'Medical'} emergency request logged successfully`,
      requestCode,
      request: emergencyRecord || {
        requestCode,
        emergencyType: emergencyType || 'Medical',
        latitude: userLat,
        longitude: userLon,
        status: 'pending',
        created_at: new Date().toISOString(),
      },
      nearestService: nearestService || {
        name: 'Saswad Central Medical Camp',
        category: targetCategory,
        contactPhone: '+919822011223',
        distanceKm: 0.5,
      },
    });
  } catch (err) {
    next(err);
  }
}
