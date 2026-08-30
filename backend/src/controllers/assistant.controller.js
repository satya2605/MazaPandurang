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
        error: { message: 'माहितीसाठी कृपया वैध प्रश्न टाका.' },
        message: 'माहितीसाठी कृपया वैध प्रश्न टाका.',
        reply: 'माहितीसाठी कृपया वैध प्रश्न टाका.',
        text: 'माहितीसाठी कृपया वैध प्रश्न टाका.'
      });
    }

    if (message.length > 2000) {
      return res.status(400).json({
        success: false,
        error: { message: 'प्रश्न खूप मोठा आहे. कृपया लहान रूपात विचारा.' },
        message: 'प्रश्न खूप मोठा आहे. कृपया लहान रूपात विचारा.',
        reply: 'प्रश्न खूप मोठा आहे. कृपया लहान रूपात विचारा.',
        text: 'प्रश्न खूप मोठा आहे. कृपया लहान रूपात विचारा.'
      });
    }

    // Default user location if omitted: Center of Saswad Wari Hub (18.3411, 74.0305)
    const effectiveLocation = {
      latitude: 18.3411,
      longitude: 74.0305,
      name: 'सासवड मध्यवर्ती केंद्र (Saswad Center)',
      ...(userContext || {})
    };

    // Build trusted platform context directly from Supabase DB
    const trustedContext = await buildTrustedAssistantContext({
      userId,
      userLocation: effectiveLocation
    });

    // 1. Attempt LLM API completion (Grok / Groq / OpenAI)
    let llmRes = null;
    try {
      llmRes = await sendGrokChatCompletion({
        systemPrompt: SYSTEM_PROMPT,
        userMessage: message.trim(),
        context: trustedContext
      });
    } catch (err) {
      if (err.statusCode) {
        return res.status(err.statusCode).json({
          success: false,
          error: { message: 'सध्या नेटवर्क वेळेत प्रतिसाद मिळाला नाही. कृपया पुन्हा प्रयत्न करा.' },
          message: 'सध्या नेटवर्क वेळेत प्रतिसाद मिळाला नाही. कृपया पुन्हा प्रयत्न करा.',
          reply: 'सध्या नेटवर्क वेळेत प्रतिसाद मिळाला नाही. कृपया पुन्हा प्रयत्न करा.',
          text: 'सध्या नेटवर्क वेळेत प्रतिसाद मिळाला नाही. कृपया पुन्हा प्रयत्न करा.'
        });
      }
    }

    if (llmRes && llmRes.reply && llmRes.reply.trim().length > 0) {
      const answer = llmRes.reply.trim();
      return res.json({
        success: true,
        message: answer,
        reply: answer,
        text: answer,
        language: 'mr',
        provider: llmRes.provider || 'llm',
        actions: llmRes.actions || [],
        sources: ['palkhi', 'services', 'wari_route']
      });
    }

    // 2. Fallback to grounded local dev engine if LLM API fails or is unconfigured
    console.log('[AssistantController] LLM API unconfigured or unreachable. Using grounded Dev engine.');
    const devProvider = new DevAIProvider();
    const devRes = await devProvider.generateResponse({
      systemPrompt: SYSTEM_PROMPT,
      message: message.trim(),
      context: trustedContext,
      intent: 'general'
    });

    const devAnswer = devRes?.reply || 'क्षमस्व, सध्या या प्रश्नाचे उत्तर उपलब्ध नाही.';

    return res.json({
      success: true,
      message: devAnswer,
      reply: devAnswer,
      text: devAnswer,
      language: 'mr',
      provider: 'dev-grounded',
      actions: devRes?.actions || [],
      sources: devRes?.sources || ['palkhi']
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
        error: { message: 'ध्वनी नोंदणी फाईल आवश्यक आहे.' }
      });
    }

    if (audioBuffer.length > 10 * 1024 * 1024) {
      return res.status(400).json({
        success: false,
        error: { message: 'ध्वनी फाईल आकार १०MB पेक्षा लहान असणे आवश्यक आहे.' }
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
        error: { message: 'वाचनासाठी मजकूर आवश्यक आहे.' }
      });
    }

    if (text.length > 1000) {
      return res.status(400).json({
        success: false,
        error: { message: 'मजकूर १००० अक्षरांपेक्षा लहान असणे आवश्यक आहे.' }
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
 * One-shot voice assistant endpoint (STT ➔ LLM ➔ TTS).
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
        error: { message: 'ध्वनी नोंदणी फाईल आवश्यक आहे.' }
      });
    }

    // 1. Transcribe STT via Sarvam AI
    const sttRes = await transcribeSarvamSTT({ audioBuffer, mimeType, languageCode: 'mr-IN' });
    const transcript = sttRes.text;

    // 2. Build trusted platform context
    const trustedContext = await buildTrustedAssistantContext({ userId: req.user?.id });

    // 3. Query LLM (Groq / Grok / Dev Fallback)
    let replyText = "पालखी सध्या पुणे मार्गावर आहे.";
    const llmRes = await sendGrokChatCompletion({
      systemPrompt: SYSTEM_PROMPT,
      userMessage: transcript,
      context: trustedContext
    }).catch(() => null);

    if (llmRes && llmRes.reply) {
      replyText = llmRes.reply;
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
      reply: replyText,
      text: replyText,
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
