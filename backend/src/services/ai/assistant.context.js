import { getSupabaseClient } from '../../db/supabase.js';

/**
 * Builds authoritative trusted context for the Pilgrim AI Assistant.
 * Queries Supabase database tables directly for published Palkhis,
 * halts, verified services, and active public Dindis.
 * Strictly excludes operator identity, user secrets, and private metadata.
 */
export async function buildTrustedAssistantContext({ userId, userLocation = {} } = {}) {
  const client = getSupabaseClient();
  const context = {
    palkhis: [],
    services: [],
    dindis: [],
    emergencyContacts: [],
  };

  try {
    // 1. Published Palkhis and Multi-Day Halts (NO internal operator identity)
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
      context.palkhis = palkhiRows.map(p => ({
        id: p.id,
        name: p.name,
        saint: p.saint || 'Sant Dnyaneshwar Maharaj',
        start_point: p.start_point || 'Alandi',
        destination: p.destination || 'Pandharpur',
        current_stage: p.current_stage || '',
        next_stop: p.next_stop || '',
        latitude: p.latitude ? parseFloat(p.latitude) : 18.6772,
        longitude: p.longitude ? parseFloat(p.longitude) : 73.8967,
        status: p.status || 'ACTIVE',
        updated_at: p.updated_at,
        planned_halts: haltsByPalkhi[p.id] || []
      }));
    }

    // 2. Verified Active Public Services (Medical, Water, Food, Sanitation, Shelter)
    const { data: serviceRows } = await client
      .from('services')
      .select('id, name, category, address, contact_phone, availability_status, latitude, longitude')
      .eq('is_verified', true)
      .eq('is_active', true)
      .limit(15);

    if (Array.isArray(serviceRows)) {
      context.services = serviceRows.map(s => ({
        id: s.id,
        name: s.name,
        category: s.category,
        address: s.address,
        contact_phone: s.contact_phone,
        availability_status: s.availability_status
      }));
    }

    // 3. Active Public Dindis ONLY (strictly exclude private leader info)
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
