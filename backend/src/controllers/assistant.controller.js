import { buildTrustedAssistantContext, SYSTEM_PROMPT } from '../services/ai/assistant.context.js';
import { sendGrokChatCompletion } from '../services/ai/grok.service.js';
import { transcribeSarvamSTT, synthesizeSarvamTTS } from '../services/ai/sarvam.service.js';
import { DevAIProvider } from '../services/ai/aiProvider.js';

/**
 * Controller for POST /api/assistant/chat
 * Authenticated text assistant endpoint.
 */
export async function handleAssistantChat(req, res, next) {
  try {
    const { message, context: userContext } = req.body;
    const userId = req.user?.id;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'Message string parameter is required' }
      });
    }

    if (message.length > 2000) {
      return res.status(400).json({
        success: false,
        error: { message: 'Message length exceeds maximum limit of 2000 characters' }
      });
    }

    // Build trusted platform context directly from Supabase DB
    const trustedContext = await buildTrustedAssistantContext({
      userId,
      userLocation: userContext || {}
    });

    // 1. Attempt Grok API completion
    let grokRes = null;
    try {
      grokRes = await sendGrokChatCompletion({
        systemPrompt: SYSTEM_PROMPT,
        userMessage: message.trim(),
        context: trustedContext
      });
    } catch (err) {
      if (err.statusCode) {
        return res.status(err.statusCode).json({
          success: false,
          error: { message: err.message }
        });
      }
    }

    if (grokRes && grokRes.reply) {
      return res.json({
        success: true,
        message: grokRes.reply,
        language: 'mr',
        provider: 'grok',
        sources: ['palkhi', 'services', 'wari_route']
      });
    }

    // 2. Fallback to local dev engine if Grok API key is unconfigured or unavailable
    const devProvider = new DevAIProvider();
    const devRes = await devProvider.generateResponse({
      systemPrompt: SYSTEM_PROMPT,
      message: message.trim(),
      context: trustedContext,
      intent: 'general'
    });

    return res.json({
      success: true,
      message: devRes.reply,
      language: 'mr',
      provider: 'dev-fallback',
      sources: devRes.sources || ['palkhi']
    });
  } catch (err) {
    next(err);
  }
}

/**
 * Controller for POST /api/assistant/stt
 * Authenticated speech-to-text endpoint (Marathi primary).
 */
export async function handleAssistantSTT(req, res, next) {
  try {
    let audioBuffer = null;
    let mimeType = 'audio/wav';

    if (req.file && req.file.buffer) {
      audioBuffer = req.file.buffer;
      mimeType = req.file.mimetype || 'audio/wav';
    } else if (req.body && req.body.audio) {
      audioBuffer = Buffer.from(req.body.audio, 'base64');
      if (req.body.mimeType) mimeType = req.body.mimeType;
    }

    if (!audioBuffer || audioBuffer.length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'Audio file upload or base64 audio string is required' }
      });
    }

    if (audioBuffer.length > 10 * 1024 * 1024) {
      return res.status(400).json({
        success: false,
        error: { message: 'Audio payload size exceeds maximum limit of 10MB' }
      });
    }

    const languageCode = req.body?.languageCode || 'mr-IN';
    const result = await transcribeSarvamSTT({
      audioBuffer,
      mimeType,
      languageCode
    });

    return res.json(result);
  } catch (err) {
    if (err.statusCode) {
      return res.status(err.statusCode).json({
        success: false,
        error: { message: err.message }
      });
    }
    next(err);
  }
}

/**
 * Controller for POST /api/assistant/tts
 * Authenticated text-to-speech endpoint (Sarvam Bulbul Marathi).
 */
export async function handleAssistantTTS(req, res, next) {
  try {
    const { text, languageCode = 'mr-IN', speaker = 'meera' } = req.body || {};

    if (!text || typeof text !== 'string' || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'Text parameter is required for TTS' }
      });
    }

    if (text.length > 1000) {
      return res.status(400).json({
        success: false,
        error: { message: 'Text length exceeds maximum limit of 1000 characters' }
      });
    }

    const result = await synthesizeSarvamTTS({
      text: text.trim(),
      languageCode,
      speaker
    });

    return res.json(result);
  } catch (err) {
    if (err.statusCode) {
      return res.status(err.statusCode).json({
        success: false,
        error: { message: err.message }
      });
    }
    next(err);
  }
}

/**
 * Controller for POST /api/assistant/voice
 * One-shot voice assistant endpoint (STT ➔ Grok ➔ TTS).
 */
export async function handleAssistantVoice(req, res, next) {
  try {
    let audioBuffer = null;
    let mimeType = 'audio/wav';

    if (req.file && req.file.buffer) {
      audioBuffer = req.file.buffer;
      mimeType = req.file.mimetype || 'audio/wav';
    } else if (req.body && req.body.audio) {
      audioBuffer = Buffer.from(req.body.audio, 'base64');
      if (req.body.mimeType) mimeType = req.body.mimeType;
    }

    if (!audioBuffer || audioBuffer.length === 0) {
      return res.status(400).json({
        success: false,
        error: { message: 'Audio file upload or base64 audio string is required' }
      });
    }

    // 1. Transcribe STT via Sarvam AI
    const sttRes = await transcribeSarvamSTT({ audioBuffer, mimeType, languageCode: 'mr-IN' });
    const transcript = sttRes.text;

    // 2. Build trusted platform context
    const trustedContext = await buildTrustedAssistantContext({ userId: req.user?.id });

    // 3. Query LLM (Grok or Dev Fallback)
    let replyText = "राम कृष्ण हरी! 🚩 पालखी सध्या पुणे मार्गावर आहे.";
    const grokRes = await sendGrokChatCompletion({
      systemPrompt: SYSTEM_PROMPT,
      userMessage: transcript,
      context: trustedContext
    }).catch(() => null);

    if (grokRes && grokRes.reply) {
      replyText = grokRes.reply;
    } else {
      const devProvider = new DevAIProvider();
      const devRes = await devProvider.generateResponse({
        systemPrompt: SYSTEM_PROMPT,
        message: transcript,
        context: trustedContext,
        intent: 'general'
      });
      replyText = devRes.reply;
    }

    // 4. Synthesize TTS response via Sarvam AI
    const ttsRes = await synthesizeSarvamTTS({ text: replyText, languageCode: 'mr-IN' }).catch(() => null);

    return res.json({
      success: true,
      transcript: transcript,
      message: replyText,
      language: 'mr',
      audio: ttsRes?.audio || null,
      format: ttsRes?.format || 'wav'
    });
  } catch (err) {
    if (err.statusCode) {
      return res.status(err.statusCode).json({
        success: false,
        error: { message: err.message }
      });
    }
    next(err);
  }
}
