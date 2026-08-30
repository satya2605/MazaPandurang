import { config } from '../../config/env.js';

/**
 * Service for Sarvam AI Speech-to-Text (STT) and Text-to-Speech (TTS).
 * Enforces server-side subscription key management, validation, and timeouts.
 */

/**
 * Perform Speech-To-Text transcription using Sarvam AI.
 * Primary language: Marathi ('mr-IN').
 */
export async function transcribeSarvamSTT({ audioBuffer, mimeType = 'audio/wav', languageCode = 'mr-IN', timeoutMs = 12000 }) {
  const apiKey = process.env.SARVAM_API_KEY || config.sarvamApiKey;

  if (!apiKey) {
    // Dev fallback response if no API key is provided
    return {
      success: true,
      text: "ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?",
      language: "mr-IN",
      provider: "dev-fallback"
    };
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const formData = new FormData();
    const blob = new Blob([audioBuffer], { type: mimeType });
    formData.append('file', blob, 'audio.wav');
    formData.append('language_code', languageCode);
    formData.append('model', 'saaras:v1');

    const res = await fetch('https://api.sarvam.ai/speech-to-text', {
      method: 'POST',
      headers: {
        'api-subscription-key': apiKey
      },
      body: formData,
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      console.warn(`[SarvamSTT] API returned HTTP ${res.status}`);
      const errText = await res.text();
      const err = new Error(`Sarvam STT failed with status ${res.status}: ${errText}`);
      err.statusCode = res.status >= 500 ? 502 : 400;
      throw err;
    }

    const data = await res.json();
    return {
      success: true,
      text: data.transcript || data.text || '',
      language: data.language_code || languageCode,
      provider: 'sarvam'
    };
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      const timeoutErr = new Error('Sarvam STT request timed out');
      timeoutErr.statusCode = 504;
      throw timeoutErr;
    }
    if (err.statusCode) throw err;
    console.warn('[SarvamSTT] Request error:', err.message);
    throw err;
  }
}

/**
 * Perform Text-To-Speech synthesis using Sarvam AI (Bulbul:v1).
 * Primary language: Marathi ('mr-IN').
 */
export async function synthesizeSarvamTTS({ text, languageCode = 'mr-IN', speaker = 'meera', timeoutMs = 12000 }) {
  const apiKey = process.env.SARVAM_API_KEY || config.sarvamApiKey;

  if (!text || typeof text !== 'string' || text.trim().length === 0) {
    const err = new Error('Text parameter is required for TTS');
    err.statusCode = 400;
    throw err;
  }

  if (text.length > 1000) {
    const err = new Error('TTS text length exceeds maximum limit of 1000 characters');
    err.statusCode = 400;
    throw err;
  }

  if (!apiKey) {
    // Dev fallback return base64 placeholder audio
    return {
      success: true,
      audio: "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=",
      format: "wav",
      language: languageCode,
      provider: "dev-fallback"
    };
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const payload = {
      inputs: [text.trim()],
      target_language_code: languageCode,
      speaker: speaker || 'meera',
      pitch: 0,
      pace: 1.05,
      loudness: 1.5,
      speech_sample_rate: 8000,
      enable_preprocessing: true,
      model: 'bulbul:v1'
    };

    const res = await fetch('https://api.sarvam.ai/text-to-speech', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'api-subscription-key': apiKey
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!res.ok) {
      console.warn(`[SarvamTTS] API returned HTTP ${res.status}`);
      const errText = await res.text();
      const err = new Error(`Sarvam TTS failed with status ${res.status}: ${errText}`);
      err.statusCode = res.status >= 500 ? 502 : 400;
      throw err;
    }

    const data = await res.json();
    const base64Audio = data.audios && data.audios.length > 0 ? data.audios[0] : null;

    if (!base64Audio) {
      const err = new Error('Sarvam TTS returned empty audio payload');
      err.statusCode = 502;
      throw err;
    }

    return {
      success: true,
      audio: base64Audio,
      format: 'wav',
      language: languageCode,
      provider: 'sarvam'
    };
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      const timeoutErr = new Error('Sarvam TTS request timed out');
      timeoutErr.statusCode = 504;
      throw timeoutErr;
    }
    if (err.statusCode) throw err;
    console.warn('[SarvamTTS] Request error:', err.message);
    throw err;
  }
}
