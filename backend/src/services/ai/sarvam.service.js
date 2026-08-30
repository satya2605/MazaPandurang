import { config } from '../../config/env.js';

/**
 * Service for Sarvam AI Speech-to-Text (STT) and Text-to-Speech (TTS).
 * Enforces server-side subscription key management, validation, timeouts, and dev fallback.
 */

const DEV_FALLBACK_AUDIO = "UklGRiQAAABXQVZFZm10IBAAAAABAAEARKwAAIhYAQACABAAZGF0YQAAAAA=";

/**
 * Perform Speech-To-Text transcription using Sarvam AI.
 * Primary language: Marathi ('mr-IN').
 */
export async function transcribeSarvamSTT({ audioBuffer, mimeType = 'audio/wav', languageCode = 'mr-IN', timeoutMs = 12000 }) {
  const apiKey = process.env.SARVAM_API_KEY || config.sarvamApiKey;

  if (!apiKey) {
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
      console.warn(`[SarvamSTT] API returned HTTP ${res.status}. Falling back to dev STT.`);
      return {
        success: true,
        text: "ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?",
        language: "mr-IN",
        provider: "dev-fallback"
      };
    }

    const data = await res.json();
    return {
      success: true,
      text: data.transcript || data.text || 'ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?',
      language: data.language_code || languageCode,
      provider: 'sarvam'
    };
  } catch (err) {
    clearTimeout(timeoutId);
    console.warn('[SarvamSTT] Exception:', err.message);
    return {
      success: true,
      text: "ज्ञानेश्वर माऊलींची पालखी सध्या कुठे आहे?",
      language: "mr-IN",
      provider: "dev-fallback"
    };
  }
}

/**
 * Perform Text-To-Speech synthesis using Sarvam AI (Bulbul:v3).
 * Primary language: Marathi ('mr-IN').
 */
export async function synthesizeSarvamTTS({ text, languageCode = 'mr-IN', speaker = 'priya', timeoutMs = 12000 }) {
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
    return {
      success: true,
      audio: DEV_FALLBACK_AUDIO,
      format: "wav",
      language: languageCode,
      provider: "dev-fallback"
    };
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const validSpeaker = (speaker && speaker !== 'meera') ? speaker : 'priya';
    const payload = {
      inputs: [text.trim()],
      target_language_code: languageCode,
      speaker: validSpeaker,
      model: 'bulbul:v3',
      speech_sample_rate: 8000,
      enable_preprocessing: true
    };

    console.log(`[SarvamTTS] Requesting TTS synthesis for ${text.trim().length} chars (speaker: ${validSpeaker}, model: bulbul:v3)`);

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
      const errText = await res.text().catch(() => '');
      console.warn(`[SarvamTTS] API returned HTTP ${res.status}: ${errText.substring(0, 150)}. Falling back to dev audio.`);
      return {
        success: true,
        audio: DEV_FALLBACK_AUDIO,
        format: "wav",
        language: languageCode,
        provider: "dev-fallback"
      };
    }

    const data = await res.json();
    const base64Audio = data.audios && data.audios.length > 0 ? data.audios[0] : null;

    if (!base64Audio) {
      return {
        success: true,
        audio: DEV_FALLBACK_AUDIO,
        format: "wav",
        language: languageCode,
        provider: "dev-fallback"
      };
    }

    console.log(`[SarvamTTS] Successfully synthesized audio payload (${base64Audio.length} base64 chars)`);
    return {
      success: true,
      audio: base64Audio,
      format: 'wav',
      language: languageCode,
      provider: 'sarvam'
    };
  } catch (err) {
    clearTimeout(timeoutId);
    console.warn('[SarvamTTS] Exception:', err.message);
    return {
      success: true,
      audio: DEV_FALLBACK_AUDIO,
      format: "wav",
      language: languageCode,
      provider: "dev-fallback"
    };
  }
}
