import { Router } from 'express';
import { authenticateJwt } from '../middleware/auth.js';
import { handleTilakChat } from '../controllers/tilak.controller.js';

const router = Router();

// POST /api/ai/tilak/chat requires Supabase JWT Auth
router.post('/chat', authenticateJwt, handleTilakChat);

export default router;
