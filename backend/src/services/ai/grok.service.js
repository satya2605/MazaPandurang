import { config } from '../../config/env.js';

/**
 * Service for Grok API (x.ai) LLM completions.
 * Enforces server-side key management, timeout, and fallback handling.
 */
export async function sendGrokChatCompletion({ systemPrompt, userMessage, context, timeoutMs = 10000 }) {
  const apiKey = process.env.GROK_API_KEY || config.grokApiKey;
  const model = process.env.GROK_MODEL || 'grok-beta';

  // Fallback to local dev engine if no Grok API key is configured
  if (!apiKey) {
    return null;
  }

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
      max_tokens: 600
    };

    const res = await fetch('https://api.x.ai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      console.warn(`[GrokService] API Returned Status ${res.status}`);
      return null;
    }

    const data = await res.json();
    const replyText = data.choices?.[0]?.message?.content;

    if (replyText) {
      return {
        reply: replyText.trim(),
        model: model,
        provider: 'grok'
      };
    }
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      console.warn('[GrokService] Grok API request timed out');
      const error = new Error('Grok API timed out');
      error.statusCode = 504;
      throw error;
    }
    console.warn('[GrokService] Error calling Grok API:', err.message);
  }

  return null;
}
