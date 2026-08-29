import { processTilakChat } from '../services/ai/tilak.service.js';

/**
 * Controller for POST /api/ai/tilak/chat
 * Handles pilgrim query with optional location context.
 */
export async function handleTilakChat(req, res, next) {
  try {
    const { message, context } = req.body;
    const userId = req.user?.id;

    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Message string is required'
      });
    }

    const userLocation = {
      latitude: context?.latitude || null,
      longitude: context?.longitude || null,
    };

    const result = await processTilakChat({
      message: message.trim(),
      userLocation,
      userId,
    });

    return res.json(result);
  } catch (err) {
    next(err);
  }
}
