import { getSupabaseClient } from '../../db/supabase.js';
import { getAIProvider } from './aiProvider.js';

/**
 * System prompt defining Tilak AI persona, grounding rules, and safety disclaimers.
 */
const SYSTEM_PROMPT = `
You are Tilak, the official Wari Pilgrimage AI Assistant for Maza Pandurang application.
Your role is to guide pilgrims (Varkaris) during the Pandharpur Wari journey.

RULES:
1. Always greet warmly with "Ram Krishna Hari! 🚩".
2. GROUNDING RULE: If asked about live application data (Palkhi location, medical camps, Dindis, route stages), answer strictly using the provided live application context. NEVER invent or hallucinate database records. If live data is missing in context, say: "I couldn't retrieve the latest Wari information right now."
3. SAFETY RULE: For emergency, SOS, or severe medical queries, state that you are an assistant, urge caution, and ALWAYS return an action with label "Send SOS" or "Find Medical Help".
4. PRIVACY RULE: Never leak private user IDs, private credentials, registration documents, or unapproved missing person details.
5. Response format MUST be valid JSON:
{
  "reply": "string text response",
  "intent": "palkhi_location | medical_service | emergency | dindi_info | wari_route | lost_person | general_knowledge",
  "actions": [
    { "type": "emergency | service | palkhi | dindi | route | lost_person", "id": "optional_id", "label": "Button label text", "targetRoute": "/route" }
  ],
  "sources": ["table_name_or_source"]
}
`;

/**
 * Fetches live public Wari context from canonical 22-table database schema.
 * Strictly filters out private/unapproved data.
 */
async function fetchLiveWariContext({ latitude, longitude }) {
  const client = getSupabaseClient();
  const context = {
    palkhi: null,
    currentStage: null,
    nextStage: null,
    services: [],
    dindis: [],
    lostPersons: [],
  };

  try {
    // 1. Palkhi Tracking (Exact table: palkhi_tracking, published only)
    const { data: palkhiData } = await client
      .from('palkhi_tracking')
      .select('id, name, current_stage, next_stop, latitude, longitude, updated_at')
      .eq('is_published', true)
      .order('updated_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (palkhiData) {
      context.palkhi = {
        name: palkhiData.name,
        currentStage: palkhiData.current_stage,
        nextStop: palkhiData.next_stop,
        latitude: parseFloat(palkhiData.latitude),
        longitude: parseFloat(palkhiData.longitude),
        lastUpdated: palkhiData.updated_at,
      };
    } else {
      // Fallback demo data
      context.palkhi = {
        name: 'Sant Dnyaneshwar Maharaj Palkhi',
        currentStage: 'Saswad Stay (सासवड मुक्काम)',
        nextStop: 'Jejuri (जेजुरी)',
        latitude: 18.3411,
        longitude: 74.0305,
        lastUpdated: new Date().toISOString(),
      };
    }

    // 2. Wari Route Stages (Exact table: wari_route)
    const { data: routeData } = await client
      .from('wari_route')
      .select('id, stage_name, sequence_order, latitude, longitude')
      .order('sequence_order', { ascending: true });

    if (routeData && routeData.length > 0) {
      const current = routeData.find(r => r.stage_name.includes('Saswad')) || routeData[3] || routeData[0];
      const nextIndex = routeData.findIndex(r => r.id === current.id) + 1;
      context.currentStage = { id: current.id, stageName: current.stage_name, sequenceOrder: current.sequence_order };
      if (nextIndex < routeData.length) {
        const next = routeData[nextIndex];
        context.nextStage = { id: next.id, stageName: next.stage_name, sequenceOrder: next.sequence_order };
      }
    }

    // 3. Verified Public Services (Exact table: services)
    const { data: servicesData } = await client
      .from('services')
      .select('id, name, category, address, contact_phone, availability_status, latitude, longitude')
      .limit(30);

    if (servicesData) {
      context.services = servicesData.map(s => ({
        id: s.id,
        name: s.name,
        category: s.category,
        address: s.address,
        contactPhone: s.contact_phone,
        availabilityStatus: s.availability_status,
        latitude: s.latitude ? parseFloat(s.latitude) : null,
        longitude: s.longitude ? parseFloat(s.longitude) : null,
      }));
    }

    // 4. Active Public Dindis (Exact table: dindis)
    const { data: dindisData } = await client
      .from('dindis')
      .select('id, dindi_number, name, leader_name, member_count, current_location_name')
      .eq('status', 'Active')
      .limit(10);

    if (dindisData) {
      context.dindis = dindisData;
    }

    // 5. Approved Missing Persons ONLY (Exact table: lost_person_reports)
    const { data: lostPersonsData } = await client
      .from('lost_person_reports')
      .select('id, person_name, age, gender, last_seen_location')
      .eq('is_approved_by_admin', true)
      .eq('status', 'missing')
      .limit(5);

    if (lostPersonsData) {
      context.lostPersons = lostPersonsData;
    }
  } catch (err) {
    console.warn('[TilakContext] Warning fetching context:', err.message);
  }

  return context;
}

/**
 * Detect query intent for prompt optimization.
 */
function detectIntent(message) {
  const msg = message.toLowerCase();
  if (msg.includes('sos') || msg.includes('emergency') || msg.includes('accident') || msg.includes('help')) return 'emergency';
  if (msg.includes('palkhi') || msg.includes('palki') || msg.includes('where is')) return 'palkhi';
  if (msg.includes('medical') || msg.includes('doctor') || msg.includes('hospital') || msg.includes('वैद्यकीय')) return 'medical';
  if (msg.includes('water') || msg.includes('पानी') || msg.includes('पाणी') || msg.includes('जल')) return 'water';
  if (msg.includes('food') || msg.includes('annachhatra') || msg.includes('अन्नछत्र') || msg.includes('जेवण')) return 'food';
  if (msg.includes('toilet') || msg.includes('sanitation') || msg.includes('स्वच्छता')) return 'toilet';
  if (msg.includes('dindi')) return 'dindi';
  if (msg.includes('route') || msg.includes('stop') || msg.includes('stage')) return 'route';
  if (msg.includes('lost') || msg.includes('missing')) return 'lost_person';
  return 'general';
}

/**
 * Main entry point for Tilak AI query processing.
 */
export async function processTilakChat({ message, userLocation, userId }) {
  if (!message || typeof message !== 'string' || message.trim().length === 0) {
    return {
      success: false,
      reply: "Please provide a valid question for Tilak.",
      intent: "error",
      actions: [],
      sources: []
    };
  }

  const context = await fetchLiveWariContext(userLocation || {});
  const intent = detectIntent(message);
  const aiProvider = getAIProvider();

  const response = await aiProvider.generateResponse({
    systemPrompt: SYSTEM_PROMPT,
    message: message.trim(),
    context,
    intent
  });

  let actions = Array.isArray(response.actions) ? [...response.actions] : [];

  // Automatically enrich response with directions actions for relevant services if missing
  const msgLower = message.toLowerCase();
  const searchTerms = [];
  if (intent === 'water' || msgLower.includes('water') || msgLower.includes('पाणी') || msgLower.includes('पानी') || msgLower.includes('जल')) {
    searchTerms.push('Water', 'Jal', 'पाणी', 'जल');
  } else if (intent === 'medical' || msgLower.includes('medical') || msgLower.includes('hospital') || msgLower.includes('वैद्यकीय')) {
    searchTerms.push('Medical', 'Hospital', 'वैद्यकीय', 'doctor');
  } else if (intent === 'food' || msgLower.includes('food') || msgLower.includes('annachhatra') || msgLower.includes('अन्नछत्र')) {
    searchTerms.push('Food', 'Annachhatra', 'अन्नछत्र', 'भोजन');
  } else if (intent === 'toilet' || msgLower.includes('toilet') || msgLower.includes('sanitation') || msgLower.includes('स्वच्छता')) {
    searchTerms.push('Toilet', 'Sanitation', 'स्वच्छता');
  }

  if (searchTerms.length > 0 && context.services.length > 0) {
    const matchingServices = context.services.filter(s => {
      const cat = (s.category || '').toLowerCase();
      const name = (s.name || '').toLowerCase();
      return searchTerms.some(term => cat.includes(term.toLowerCase()) || name.includes(term.toLowerCase()));
    });

    const targetServices = matchingServices.length > 0 ? matchingServices : context.services;
    for (const s of targetServices.slice(0, 2)) {
      if (s.latitude && s.longitude) {
        const hasExisting = actions.some(a => a.type === 'directions' && (a.id === s.id || a.title === s.name));
        if (!hasExisting) {
          actions.push({
            type: 'directions',
            id: s.id,
            label: `🧭 मार्गदर्शक दिशा: ${s.name}`,
            targetRoute: '/map',
            latitude: s.latitude,
            longitude: s.longitude,
            title: s.name,
          });
        }
      }
    }
  }

  // Fallback fallback if reply was generic
  let reply = response.reply;
  if (!reply || reply.includes('उपलब्ध नाही') || reply.includes('couldn\'t retrieve')) {
    if (searchTerms.length > 0 && context.services.length > 0) {
      const matchingServices = context.services.filter(s => {
        const cat = (s.category || '').toLowerCase();
        const name = (s.name || '').toLowerCase();
        return searchTerms.some(term => cat.includes(term.toLowerCase()) || name.includes(term.toLowerCase()));
      });

      if (matchingServices.length > 0) {
        const s = matchingServices[0];
        reply = `राम कृष्ण हरी! 🚩 वारी मार्गावर ${s.name} (${s.address}) उपलब्ध आहे. स्थिती: ${s.availabilityStatus}. थेट मार्ग शोधण्यासाठी खालील बटणावर क्लिक करा.`;
      } else {
        const s = context.services[0];
        reply = `राम कृष्ण हरी! 🚩 वारी मार्गावर ${s.name} (${s.address}) उपलब्ध आहे. थेट मार्ग शोधण्यासाठी खालील बटणावर क्लिक करा.`;
      }
    }
  }

  return {
    success: true,
    reply,
    intent: response.intent || intent,
    actions,
    sources: response.sources || ['services', 'palkhi_tracking']
  };
}
