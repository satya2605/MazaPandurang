import { getSupabaseClient } from '../../db/supabase.js';

/**
 * Strict System Prompt for Pilgrim AI Assistant.
 * Forbids tables/lists and mandates single nearest service identification grounded in Saswad hub.
 */
export const SYSTEM_PROMPT = `
You are Tilak, the official Wari Pilgrimage AI Assistant for Maza Pandurang application.
Your role is to guide pilgrims (Varkaris) during the Pandharpur Wari journey.

STRICT RULES:
1. Always greet warmly with "Ram Krishna Hari! 🚩".
2. ABSOLUTELY NO LISTS OR TABLES: NEVER output markdown tables, numbered lists, bulleted dumps, or multiple service listings.
3. SASWAD HUB PROXIMITY: The pilgrim's location is assumed to be at the Center of Saswad (सासवड).
4. SINGLE NEAREST FACILITY: When asked for any service (water, medical, food, toilet, shelter, police), identify ONLY the SINGLE NEAREST facility relative to Saswad center based on the provided distance (dist_from_saswad_km).
5. RESPONSE FORMAT: State the name of the single nearest facility, its exact address, distance in km from Saswad center, and operating status in 2 short warm sentences in Marathi.
6. JSON OUTPUT FORMAT: You MUST return a single JSON object:
{
  "reply": "Warm 2-sentence Marathi response naming ONLY the single nearest service and distance in km from Saswad.",
  "intent": "water_service | medical_service | food_service | toilet_service | palkhi_location | emergency | general",
  "actions": [
    {
      "type": "directions",
      "id": "service_id",
      "label": "🧭 Start Navigation (Service Name)",
      "targetRoute": "/map",
      "latitude": 18.3420,
      "longitude": 74.0310,
      "title": "Service Name"
    }
  ]
}
`;

/**
 * Haversine distance calculator in kilometers.
 */
function getDistanceKm(lat1, lon1, lat2, lon2) {
  if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return 999.9;
  const R = 6371; // Earth radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return parseFloat((R * c).toFixed(1));
}

/**
 * Builds authoritative trusted context for the Pilgrim AI Assistant.
 * Queries Supabase database tables directly for published Palkhis,
 * halts, verified services, and active public Dindis.
 * Calculates exact distance from Saswad Center (18.3411, 74.0305) and pre-sorts services.
 */
export async function buildTrustedAssistantContext({ userId, userLocation = {} } = {}) {
  const client = getSupabaseClient();

  const userLat = userLocation.latitude ? parseFloat(userLocation.latitude) : 18.3411;
  const userLng = userLocation.longitude ? parseFloat(userLocation.longitude) : 74.0305;
  const userLocName = userLocation.name || 'सासवड मध्यवर्ती केंद्र (Saswad Center)';

  const context = {
    user_location: {
      latitude: userLat,
      longitude: userLng,
      name: userLocName
    },
    palkhis: [],
    services: [],
    dindis: [],
    emergencyContacts: [],
  };

  try {
    // 1. Published Palkhis and Multi-Day Halts
    const { data: palkhiRows } = await client
      .from('palkhi_tracking')
      .select('id, name, saint, description, start_point, destination, current_stage, next_stop, latitude, longitude, status, is_published, updated_at')
      .eq('is_published', true);

    const { data: haltRows } = await client
      .from('palkhi_halts')
      .select('id, palkhi_id, day_number, halt_date, location_name, approx_latitude, approx_longitude, next_destination, expected_arrival, expected_departure')
      .order('day_number', { ascending: true });

    const haltsByPalkhi = {};
    if (Array.isArray(haltRows)) {
      for (const h of haltRows) {
        if (!haltsByPalkhi[h.palkhi_id]) haltsByPalkhi[h.palkhi_id] = [];
        haltsByPalkhi[h.palkhi_id].push({
          day_number: h.day_number,
          halt_date: h.halt_date,
          location_name: h.location_name,
          approx_latitude: h.approx_latitude ? parseFloat(h.approx_latitude) : null,
          approx_longitude: h.approx_longitude ? parseFloat(h.approx_longitude) : null,
          next_destination: h.next_destination,
          expected_arrival: h.expected_arrival,
          expected_departure: h.expected_departure
        });
      }
    }

    if (Array.isArray(palkhiRows)) {
      context.palkhis = palkhiRows.map(p => {
        const pLat = p.latitude ? parseFloat(p.latitude) : 18.3411;
        const pLng = p.longitude ? parseFloat(p.longitude) : 74.0305;
        return {
          id: p.id,
          name: p.name,
          saint: p.saint || 'Sant Dnyaneshwar Maharaj',
          start_point: p.start_point || 'Alandi',
          destination: p.destination || 'Pandharpur',
          current_stage: p.current_stage || '',
          next_stop: p.next_stop || '',
          latitude: pLat,
          longitude: pLng,
          dist_from_saswad_km: getDistanceKm(userLat, userLng, pLat, pLng),
          status: p.status || 'ACTIVE',
          updated_at: p.updated_at,
          planned_halts: haltsByPalkhi[p.id] || []
        };
      });
    }

    // 2. Verified Active Public Services (Medical, Water, Food, Sanitation, Shelter)
    const { data: serviceRows } = await client
      .from('services')
      .select('id, name, category, address, contact_phone, availability_status, latitude, longitude')
      .limit(40);

    if (Array.isArray(serviceRows)) {
      const mappedServices = serviceRows.map(s => {
        const sLat = s.latitude ? parseFloat(s.latitude) : 18.3411;
        const sLng = s.longitude ? parseFloat(s.longitude) : 74.0305;
        return {
          id: s.id,
          name: s.name,
          category: s.category,
          address: s.address,
          contact_phone: s.contact_phone,
          availability_status: s.availability_status,
          latitude: sLat,
          longitude: sLng,
          dist_from_saswad_km: getDistanceKm(userLat, userLng, sLat, sLng)
        };
      });

      // Sort services ascending by distance from Saswad Center
      mappedServices.sort((a, b) => a.dist_from_saswad_km - b.dist_from_saswad_km);
      context.services = mappedServices;
    }

    // 3. Active Public Dindis ONLY
    const { data: dindiRows } = await client
      .from('dindis')
      .select('id, dindi_number, name, start_point, destination, member_count, current_location_name, status')
      .eq('status', 'Active')
      .limit(10);

    if (Array.isArray(dindiRows)) {
      context.dindis = dindiRows.map(d => ({
        id: d.id,
        dindi_number: d.dindi_number,
        name: d.name,
        start_point: d.start_point,
        destination: d.destination,
        member_count: d.member_count,
        current_location_name: d.current_location_name
      }));
    }

    // 4. Public Emergency Assistance Contacts
    context.emergencyContacts = [
      { name: 'Police Control Room', phone: '112', type: 'police' },
      { name: 'Ambulance & Medical Emergency', phone: '108', type: 'medical' },
      { name: 'Wari Disaster Cell', phone: '1077', type: 'disaster' },
    ];
  } catch (err) {
    console.warn('[AssistantContext] Warning building trusted context:', err.message);
  }

  return context;
}

export const SYSTEM_PROMPT = `
You are Tilak, the official Marathi-first Wari Pilgrimage AI Assistant for Maza Pandurang application.
Your mission is to assist Varkari pilgrims on the Pandharpur Wari pilgrimage.

STRICT HALLUCINATION CONTROL RULES:
1. Ground every operational answer (Palkhi location, stage, halt dates, medical camps, services, Dindis) STRICTLY in the supplied AUTHORITATIVE LIVE PLATFORM CONTEXT JSON.
2. NEVER invent, fabricate, or hallucinate GPS coordinates, halt dates, Palkhi locations, service records, or emergency details.
3. If the platform context does not contain the answer, explicitly answer in Marathi: "क्षमस्व, सध्या ही माहिती प्रणालीमध्ये उपलब्ध नाही." ("Sorry, this information is currently unavailable in the system.")
4. Greet Varkaris warmly with "राम कृष्ण हरी! 🚩" ("Ram Krishna Hari! 🚩").
5. Respond in clear, respectful Marathi by default. You may also provide responses in English if the user asks in English.
6. Never expose internal user IDs, operator identities, JWT tokens, API keys, or admin metadata.
`;
