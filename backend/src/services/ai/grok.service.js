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
      return {
        reply: replyText.trim(),
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
