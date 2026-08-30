import { Router } from 'express';
import multer from 'multer';
import { authenticateJwt } from '../middleware/auth.js';
import {
  handleAssistantChat,
  handleAssistantSTT,
  handleAssistantTTS,
  handleAssistantVoice
} from '../controllers/assistant.controller.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 } // 10MB limit
});

const router = Router();

// All assistant endpoints require Supabase JWT Authentication
router.post('/chat', authenticateJwt, handleAssistantChat);
router.post('/stt', authenticateJwt, upload.single('file'), handleAssistantSTT);
router.post('/tts', authenticateJwt, handleAssistantTTS);
router.post('/voice', authenticateJwt, upload.single('file'), handleAssistantVoice);

export default router;
