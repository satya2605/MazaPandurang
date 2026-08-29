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
export class DevAIProvider extends AIProvider {
  async generateResponse({ systemPrompt, message, context, intent }) {
    const query = message.toLowerCase().trim();

    // 1. Safety & Emergency Intents
    if (intent === 'emergency' || query.includes('sos') || query.includes('emergency') || query.includes('accident') || query.includes('help me')) {
      return {
        reply: "🚩 Emergency Alert! Please stay calm. If you or someone around you requires immediate medical, police, or rescue assistance, tap the 'Send SOS' button below immediately to alert local authorities and emergency teams.",
        intent: 'emergency',
        actions: [
          { type: 'emergency', label: '🚨 Send Emergency SOS', targetRoute: '/help' },
          { type: 'service', label: '🏥 Find Medical Help', targetRoute: '/services' }
        ],
        sources: ['emergency_dispatch_system']
      };
    }

    if (query.includes('missing') || query.includes('lost person') || query.includes('lost child')) {
      return {
        reply: "If a pilgrim is missing or lost, you can view official missing person alerts or report a new case through the Lost & Found portal below.",
        intent: 'lost_person',
        actions: [
          { type: 'lost_person', label: '🔍 View Missing Person Reports', targetRoute: '/help' }
        ],
        sources: ['lost_person_portal']
      };
    }

    // 2. Live Palkhi Location Intent
    if (intent === 'palkhi' || query.includes('palkhi') || query.includes('where is the palkhi') || query.includes('palki')) {
      if (context.palkhi) {
        const p = context.palkhi;
        return {
          reply: `🚩 The ${p.name} is currently at ${p.currentStage}. Next upcoming stop is ${p.nextStop}. (Updated: ${p.lastUpdated ? p.lastUpdated.substring(11, 16) : 'Live'})`,
          intent: 'palkhi_location',
          actions: [
            { type: 'palkhi', label: '📍 Track Palkhi on Map', targetRoute: '/palkhi' }
          ],
          sources: ['palkhi_tracking']
        };
      } else {
        return {
          reply: "I couldn't retrieve the latest Wari information right now. Please check back shortly.",
          intent: 'palkhi_location',
          actions: [{ type: 'palkhi', label: '📍 Open Wari Map', targetRoute: '/map' }],
          sources: ['palkhi_tracking']
        };
      }
    }

    // 3. Wari Route Stages Intent
    if (intent === 'route' || query.includes('route') || query.includes('next stop') || query.includes('stage')) {
      if (context.nextStage) {
        return {
          reply: `The current route procession stage is ${context.currentStage?.stageName || 'Saswad Stay'}. The next upcoming stage is ${context.nextStage.stageName}.`,
          intent: 'wari_route',
          actions: [
            { type: 'route', label: '🗺️ View Full Wari Route', targetRoute: '/map' }
          ],
          sources: ['wari_route']
        };
      }
      return {
        reply: "The Wari procession spans from Alandi/Dehu through Pune, Saswad, Jejuri, Lonand, Phaltan to Pandharpur Dham.",
        intent: 'wari_route',
        actions: [{ type: 'route', label: '🗺️ View Wari Route', targetRoute: '/map' }],
        sources: ['wari_route']
      };
    }

    // 4. Medical Services Intent
    if (query.includes('medical') || query.includes('doctor') || query.includes('hospital') || query.includes('ambulance') || query.includes('first aid')) {
      const medical = context.services?.filter(s => s.category?.toLowerCase() === 'medical') || [];
      if (medical.length > 0) {
        const first = medical[0];
        return {
          reply: `Found ${medical.length} verified medical facilities. Nearest: ${first.name} at ${first.address} (${first.contactPhone || 'Open 24/7'}).`,
          intent: 'medical_service',
          actions: [
            { type: 'service', id: first.id, label: '🏥 Open Medical Camps', targetRoute: '/services' }
          ],
          sources: ['public_services']
        };
      }
      return {
        reply: "Verified medical camps with 24/7 doctors and ambulances are available along the Wari route.",
        intent: 'medical_service',
        actions: [{ type: 'service', label: '🏥 View All Medical Camps', targetRoute: '/services' }],
        sources: ['public_services']
      };
    }

    // 5. Drinking Water & Sanitation Intent
    if (query.includes('water') || query.includes('toilet') || query.includes('sanitation') || query.includes('food') || query.includes('shelter')) {
      return {
        reply: "Clean drinking water, Annachhatra (food distribution), restrooms, and shelter tents are set up by verified NGOs along the route.",
        intent: 'public_service',
        actions: [
          { type: 'service', label: '💧 View Water & Food Points', targetRoute: '/services' }
        ],
        sources: ['public_services']
      };
    }

    // 6. Dindi Intent
    if (intent === 'dindi' || query.includes('dindi')) {
      if (context.dindis && context.dindis.length > 0) {
        const count = context.dindis.length;
        const sample = context.dindis[0];
        return {
          reply: `There are ${count} active registered Dindis. Example: ${sample.dindi_number} — ${sample.name} led by ${sample.leader_name || 'Leader'}.`,
          intent: 'dindi_info',
          actions: [
            { type: 'dindi', id: sample.id, label: '🚩 View Dindis Directory', targetRoute: '/map' }
          ],
          sources: ['dindis_registry']
        };
      }
      return {
        reply: "Active Dindi troupes accompany the Palkhi with continuous Bhajan and Kirtan.",
        intent: 'dindi_info',
        actions: [{ type: 'dindi', label: '🚩 Find Nearby Dindis', targetRoute: '/map' }],
        sources: ['dindis_registry']
      };
    }

    // 7. Devotional / Culture Knowledge
    if (query.includes('pandurang') || query.includes('vitthal') || query.includes('wari') || query.includes('tradition') || query.includes('tilak')) {
      return {
        reply: "Ram Krishna Hari! 🚩 The Pandharpur Wari is a 800-year-old pilgrimage where lakhs of Varkaris walk to Pandharpur Dham to meet Lord Vitthal. The Tilak symbolizes devotion, equality, and surrender.",
        intent: 'general_knowledge',
        actions: [
          { type: 'bhakti', label: '🎵 Listen to Abhang & Bhakti Media', targetRoute: '/bhakti' }
        ],
        sources: ['wari_tradition_knowledge']
      };
    }

    // Default Fallback Response
    return {
      reply: "Ram Krishna Hari! I am Tilak, your Wari assistant. I can help you locate the Palkhi, find medical camps, discover water points, track Dindis, or navigate emergency services.",
      intent: 'general_assistance',
      actions: [
        { type: 'palkhi', label: '📍 Track Palkhi', targetRoute: '/palkhi' },
        { type: 'service', label: '🏥 Find Services', targetRoute: '/services' }
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
