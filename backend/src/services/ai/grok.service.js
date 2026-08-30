import { config } from '../../config/env.js';

/**
 * Service for LLM completions (Grok / Groq / OpenAI compatible).
 * Auto-detects key format:
 *  - gsk_* -> Groq API (https://api.groq.com/openai/v1/chat/completions)
 *  - xai-* -> x.ai Grok API (https://api.x.ai/v1/chat/completions)
 */
export async function sendGrokChatCompletion({ systemPrompt, userMessage, context, timeoutMs = 12000 }) {
  const apiKey = process.env.GROK_API_KEY || config.grokApiKey;

  if (!apiKey || apiKey.trim().length === 0) {
    console.log('[LLMService] No API key configured in environment');
    return null;
  }

  const isGroq = apiKey.startsWith('gsk_');
  const endpoint = isGroq
    ? 'https://api.groq.com/openai/v1/chat/completions'
    : 'https://api.x.ai/v1/chat/completions';

  let model = process.env.GROK_MODEL || process.env.GROQ_MODEL;
  if (isGroq && (!model || model.includes('grok'))) {
    model = 'groq/compound-mini';
  } else if (!model) {
    model = 'grok-2-latest';
  }

  console.log(`[LLMService] Initiating request to ${isGroq ? 'Groq' : 'x.ai'} API (model: ${model})`);

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const payload = {
      model,
      messages: [
        {
          role: 'system',
          content: `${systemPrompt}\n\nAUTHORITATIVE LIVE PLATFORM CONTEXT (JSON):\n${JSON.stringify(context, null, 2)}`
        },
        {
          role: 'user',
          content: userMessage
        }
      ],
      temperature: 0.2,
      max_tokens: 500
    };

    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    console.log(`[LLMService] ${isGroq ? 'Groq' : 'x.ai'} HTTP Status: ${res.status}`);

    if (!res.ok) {
      const errText = await res.text().catch(() => '');
      console.warn(`[LLMService] Provider Returned Status ${res.status}: ${errText.substring(0, 150)}`);
      return null;
    }

    const data = await res.json();
    const replyText = data.choices?.[0]?.message?.content;

    if (replyText && replyText.trim().length > 0) {
      console.log(`[LLMService] Successfully received response (${replyText.trim().length} chars)`);

      let parsedJson = null;
      try {
        const cleanJsonText = replyText.trim().replace(/^```json\s*/i, '').replace(/```$/i, '').trim();
        parsedJson = JSON.parse(cleanJsonText);
      } catch (_) {}

      let reply = parsedJson?.reply || replyText.trim();
      let actions = parsedJson?.actions || [];

      // STRICT SANITIZATION: If LLM output a markdown table or multiple list items,
      // override with the single nearest service relative to Saswad center!
      if (reply.includes('|') || reply.includes('----') || (reply.match(/\n/g) || []).length > 4) {
        console.log('[LLMService] Sanitizing table/list response to single nearest service');
        const userLoc = context.user_location || { latitude: 18.3411, longitude: 74.0305, name: 'सासवड मध्यवर्ती केंद्र' };

        let filterCat = 'water';
        const msgLower = (userMessage || '').toLowerCase();
        if (msgLower.includes('medical') || msgLower.includes('वैद्यकीय') || msgLower.includes('दवाखाना')) filterCat = 'medical';
        else if (msgLower.includes('food') || msgLower.includes('अन्नछत्र') || msgLower.includes('जेवण')) filterCat = 'food';
        else if (msgLower.includes('toilet') || msgLower.includes('स्वच्छता') || msgLower.includes('टॉयलेट')) filterCat = 'toilet';
        else if (msgLower.includes('shelter') || msgLower.includes('विश्राम') || msgLower.includes('मुक्काम')) filterCat = 'shelter';

        const services = context.services || [];
        const matched = services.filter(s => (s.category || '').toLowerCase() === filterCat);
        const nearest = matched.length > 0 ? matched[0] : (services.length > 0 ? services[0] : null);

        if (nearest) {
          reply = `राम कृष्ण हरी! 🚩 सासवड मध्यवर्ती केंद्रापासून (Saswad Center) सर्वात जवळील सुविधा:\n\n📍 "${nearest.name}"\n• अंतर: ${nearest.dist_from_saswad_km} किमी (${nearest.address})\n• स्थिती: ${nearest.availability_status || 'Available'}\n\nथेट नेव्हिगेशन सुरू करण्यासाठी खालील बटणावर क्लिक करा.`;
          actions = [
            {
              type: 'directions',
              id: nearest.id,
              label: `🧭 Start Navigation (${nearest.name})`,
              targetRoute: `/map?lat=${nearest.latitude}&lng=${nearest.longitude}&title=${encodeURIComponent(nearest.name)}`,
              latitude: nearest.latitude,
              longitude: nearest.longitude,
              title: nearest.name
            }
          ];
        }
      }

      return {
        reply,
        actions,
        model: model,
        provider: isGroq ? 'groq' : 'grok'
      };
    }
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      console.warn('[LLMService] Request timed out');
      const error = new Error('LLM API timed out');
      error.statusCode = 504;
      throw error;
    }
    console.warn(`[LLMService] Request Exception [${err.name}]: ${err.message}`);
  }

  return null;
}
