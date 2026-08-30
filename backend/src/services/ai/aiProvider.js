/**
 * Vendor-Neutral AI Provider Abstraction Interface.
 * Supports Dev (Deterministic Local Engine), Gemini, and OpenAI providers.
 */
export class AIProvider {
  async generateResponse({ systemPrompt, message, context, intent }) {
    throw new Error('AIProvider.generateResponse must be implemented by subclass.');
  }
}

/**
 * Deterministic Development AI Provider (Runs locally without external API keys).
 * Grounds answers strictly in live context or safety disclaimers.
 */
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
 * Deterministic Development AI Provider (Runs locally without external API keys).
 * Grounds answers strictly in live context, location proximity, or safety disclaimers.
 */
export class DevAIProvider extends AIProvider {
  async generateResponse({ systemPrompt, message, context, intent }) {
    const query = message.toLowerCase().trim();

    // Default User Location: Center of Saswad Wari Hub (18.3411, 74.0305)
    const userLat = context.userLocation?.latitude ? parseFloat(context.userLocation.latitude) : 18.3411;
    const userLng = context.userLocation?.longitude ? parseFloat(context.userLocation.longitude) : 74.0305;
    const locationName = context.userLocation?.name || 'सासवड मध्यवर्ती केंद्र (Saswad Center)';

    // 1. Safety & Emergency Intents
    if (intent === 'emergency' || query.includes('sos') || query.includes('emergency') || query.includes('accident') || query.includes('help')) {
      return {
        reply: "🚩 आपत्कालीन इशारा (Emergency Alert)! शांत रहा. तातडीने वैद्यकीय किंवा बचाव मदतीची गरज असल्यास, खालील 'Send SOS' किंवा 'वैद्यकीय मदत' बटणावर क्लीक करा.",
        intent: 'emergency',
        actions: [
          { type: 'emergency', label: '🚨 Send Emergency SOS', targetRoute: '/help' },
          { type: 'service', label: '🏥 Find Medical Help', targetRoute: '/services' }
        ],
        sources: ['emergency_dispatch_system']
      };
    }

    if (query.includes('missing') || query.includes('lost') || query.includes('हरवलेले')) {
      return {
        reply: "वारीमध्ये कोणतीही व्यक्ती हरवल्यास किंवा सापडल्यास, आपण खालील पोर्टलवरून अधिकृत माहिती पाहू शकता किंवा नवीन तक्रार नोंदवू शकता.",
        intent: 'lost_person',
        actions: [
          { type: 'lost_person', label: '🔍 View Missing Person Reports', targetRoute: '/help' }
        ],
        sources: ['lost_person_portal']
      };
    }

    // 2. Service Location Intent (Water, Medical, Food, Toilet/Sanitation, Shelter, Police)
    const isWater = query.includes('water') || query.includes('पाणी') || query.includes('पानी') || query.includes('जल');
    const isMedical = query.includes('medical') || query.includes('doctor') || query.includes('hospital') || query.includes('वैद्यकीय') || query.includes('दवाखाना');
    const isFood = query.includes('food') || query.includes('annachhatra') || query.includes('अन्नछत्र') || query.includes('जेवण') || query.includes('महाप्रसाद');
    const isToilet = query.includes('toilet') || query.includes('sanitation') || query.includes('swachh') || query.includes('स्वच्छता') || query.includes('टॉयलेट');
    const isShelter = query.includes('shelter') || query.includes('rest') || query.includes('विश्राम') || query.includes('मुक्काम') || query.includes('निवास');
    const isPolice = query.includes('police') || query.includes('पोलीस') || query.includes('सुरक्षा');

    if (isWater || isMedical || isFood || isToilet || isShelter || isPolice) {
      let filterCategory = 'water';
      let categoryLabel = 'पिण्याचे पाणी केंद्र (Drinking Water)';
      if (isMedical) { filterCategory = 'medical'; categoryLabel = 'वैद्यकीय केंद्र (Medical Camp)'; }
      else if (isFood) { filterCategory = 'food'; categoryLabel = 'अन्नछत्र (Annachhatra / Food)'; }
      else if (isToilet) { filterCategory = 'toilet'; categoryLabel = 'स्वच्छता गृह (Sanitation / Toilet)'; }
      else if (isShelter) { filterCategory = 'shelter'; categoryLabel = 'विश्राम धाम (Shelter)'; }
      else if (isPolice) { filterCategory = 'police'; categoryLabel = 'पोलीस मदत कक्ष (Police Booth)'; }

      const allServices = context.services || [];
      const categoryServices = allServices.filter(s => (s.category || '').toLowerCase() === filterCategory);
      const matchedServices = categoryServices.length > 0 ? categoryServices : allServices;

      if (matchedServices.length > 0) {
        // Calculate distance from Saswad Center for each service & sort by nearest distance
        const sortedWithDist = matchedServices.map(s => {
          const sLat = s.latitude ? parseFloat(s.latitude) : 18.3411;
          const sLng = s.longitude ? parseFloat(s.longitude) : 74.0305;
          const distKm = getDistanceKm(userLat, userLng, sLat, sLng);
          return { ...s, sLat, sLng, distKm };
        }).sort((a, b) => a.distKm - b.distKm);

        const nearest = sortedWithDist[0];

        return {
          reply: `राम कृष्ण हरी! 🚩 ${locationName} पासून सर्वात जवळील ${categoryLabel}:\n\n📍 "${nearest.name}"\n• अंतर: ${nearest.distKm} किमी (${nearest.address})\n• स्थिती: ${nearest.availability_status || nearest.availabilityStatus || 'Available'}\n\nथेट मार्ग शोधण्यासाठी खालील बटणावर क्लिक करा.`,
          intent: `${filterCategory}_service`,
          actions: [
            {
              type: 'directions',
              id: nearest.id,
              label: `🧭 Start Navigation (${nearest.name})`,
              targetRoute: `/map?lat=${nearest.sLat}&lng=${nearest.sLng}&title=${encodeURIComponent(nearest.name)}`,
              latitude: nearest.sLat,
              longitude: nearest.sLng,
              title: nearest.name
            },
            {
              type: 'service',
              label: `📋 सर्व ${categoryLabel} यादी`,
              targetRoute: '/services'
            }
          ],
          sources: ['public_services']
        };
      }
    }

    // 3. Live Palkhi Location Intent
    if (intent === 'palkhi' || query.includes('palkhi') || query.includes('palki') || query.includes('पालखी')) {
      if (context.palkhis && context.palkhis.length > 0) {
        const p = context.palkhis[0];
        const pLat = p.latitude ? parseFloat(p.latitude) : 18.3411;
        const pLng = p.longitude ? parseFloat(p.longitude) : 74.0305;
        const distKm = getDistanceKm(userLat, userLng, pLat, pLng);

        return {
          reply: `राम कृष्ण हरी! 🚩 ${p.name} सध्या ${p.current_stage || p.currentStage || 'सासवड मुक्काम (Saswad Stay)'} येथे आहे. पुढील टप्पा: ${p.next_stop || p.nextStop || 'जेजुरी (Jejuri)'}.\n• ${locationName} पासून अंतर: ${distKm} किमी.`,
          intent: 'palkhi_location',
          actions: [
            {
              type: 'directions',
              id: p.id,
              label: `🧭 Start Navigation to Palkhi (${distKm} km)`,
              targetRoute: `/map?lat=${pLat}&lng=${pLng}&title=${encodeURIComponent(p.name)}`,
              latitude: pLat,
              longitude: pLng,
              title: p.name
            },
            { type: 'palkhi', label: '📍 Track Palkhi on Map', targetRoute: '/palkhi' }
          ],
          sources: ['palkhi_tracking']
        };
      }
    }

    // 4. Wari Route Stages Intent
    if (intent === 'route' || query.includes('route') || query.includes('next stop') || query.includes('stage') || query.includes('मार्ग')) {
      return {
        reply: "राम कृष्ण हरी! 🚩 देहू/आळंदी ➔ पुणे ➔ सासवड ➔ जेजुरी ➔ लोणंद ➔ फलटण ➔ पंढरपूर हा अधिकृत वारी मार्ग आहे. सासवड हे पालखीचे मुख्य मुक्कामाचे ठिकाण आहे.",
        intent: 'wari_route',
        actions: [{ type: 'route', label: '🗺️ View Full Wari Route Map', targetRoute: '/map' }],
        sources: ['wari_route']
      };
    }

    // 5. Dindi Intent
    if (intent === 'dindi' || query.includes('dindi') || query.includes('दिंडी')) {
      if (context.dindis && context.dindis.length > 0) {
        const sample = context.dindis[0];
        return {
          reply: `राम कृष्ण हरी! 🚩 सासवड येथे ${context.dindis.length} नोंदणीकृत दिंड्या सध्या कार्यरत आहेत. उदा. ${sample.name} (${sample.member_count || sample.memberCount || 50} वारकरी).`,
          intent: 'dindi_info',
          actions: [{ type: 'dindi', label: '🚩 Find Nearby Dindis', targetRoute: '/map' }],
          sources: ['dindis_registry']
        };
      }
    }

    // Default Fallback Response Grounded on Saswad Hub
    return {
      reply: "राम कृष्ण हरी! 🚩 मी तिलक, आपला वारी AI मार्गदर्शक आहे. सासवड मध्यवर्ती केंद्रावरून पिण्याचे पाणी, वैद्यकीय मदत, पालखी स्थान किंवा अन्नछत्राची माहिती आणि नेव्हिगेशन मिळवण्यासाठी विचारू शकता.",
      intent: 'general_assistance',
      actions: [
        { type: 'service', label: '💧 Find Nearest Water & Services', targetRoute: '/services' },
        { type: 'palkhi', label: '📍 Track Palkhi on Map', targetRoute: '/palkhi' }
      ],
      sources: ['tilak_knowledge']
    };
  }
}

/**
 * Google Gemini API AI Provider Implementation.
 */
export class GeminiAIProvider extends AIProvider {
  constructor(apiKey) {
    super();
    this.apiKey = apiKey;
  }

  async generateResponse({ systemPrompt, message, context, intent }) {
    if (!this.apiKey) {
      const dev = new DevAIProvider();
      return dev.generateResponse({ systemPrompt, message, context, intent });
    }

    try {
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${this.apiKey}`;
      const payload = {
        contents: [
          {
            role: 'user',
            parts: [
              { text: `${systemPrompt}\n\nLive Wari Application Context JSON:\n${JSON.stringify(context, null, 2)}\n\nUser Question: "${message}"` }
            ]
          }
        ],
        generationConfig: {
          responseMimeType: 'application/json',
          temperature: 0.2
        }
      };

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      if (!res.ok) {
        console.warn('[GeminiAIProvider] HTTP Error:', res.status);
        const dev = new DevAIProvider();
        return dev.generateResponse({ systemPrompt, message, context, intent });
      }

      const json = await res.json();
      const rawText = json.candidates?.[0]?.content?.parts?.[0]?.text;
      if (rawText) {
        const parsed = JSON.parse(rawText);
        return {
          reply: parsed.reply || "Ram Krishna Hari! How can I assist your Wari journey?",
          intent: parsed.intent || intent || 'general_assistance',
          actions: parsed.actions || [],
          sources: parsed.sources || ['gemini_ai']
        };
      }
    } catch (e) {
      console.warn('[GeminiAIProvider] Exception:', e.message);
    }

    const dev = new DevAIProvider();
    return dev.generateResponse({ systemPrompt, message, context, intent });
  }
}

/**
 * OpenAI API AI Provider Implementation.
 */
export class OpenAIAIProvider extends AIProvider {
  constructor(apiKey) {
    super();
    this.apiKey = apiKey;
  }

  async generateResponse({ systemPrompt, message, context, intent }) {
    if (!this.apiKey) {
      const dev = new DevAIProvider();
      return dev.generateResponse({ systemPrompt, message, context, intent });
    }

    try {
      const res = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [
            { role: 'system', content: `${systemPrompt}\n\nLive Wari Context:\n${JSON.stringify(context)}` },
            { role: 'user', content: message }
          ],
          response_format: { type: 'json_object' }
        })
      });

      if (!res.ok) {
        const dev = new DevAIProvider();
        return dev.generateResponse({ systemPrompt, message, context, intent });
      }

      const json = await res.json();
      const content = json.choices?.[0]?.message?.content;
      if (content) {
        const parsed = JSON.parse(content);
        return {
          reply: parsed.reply || "Ram Krishna Hari!",
          intent: parsed.intent || intent || 'general',
          actions: parsed.actions || [],
          sources: parsed.sources || ['openai_ai']
        };
      }
    } catch (e) {
      console.warn('[OpenAIAIProvider] Exception:', e.message);
    }

    const dev = new DevAIProvider();
    return dev.generateResponse({ systemPrompt, message, context, intent });
  }
}

/**
 * AI Provider Factory.
 */
export function getAIProvider(providerName = 'dev') {
  const provider = (providerName || process.env.AI_PROVIDER || 'dev').toLowerCase();
  if (provider === 'gemini' && process.env.GEMINI_API_KEY) {
    return new GeminiAIProvider(process.env.GEMINI_API_KEY);
  }
  if (provider === 'openai' && process.env.OPENAI_API_KEY) {
    return new OpenAIAIProvider(process.env.OPENAI_API_KEY);
  }
  return new DevAIProvider();
}
