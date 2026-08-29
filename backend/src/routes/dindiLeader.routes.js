import { Router } from 'express';
import { authenticateJwt } from '../middleware/auth.js';
import { applyDindiLeader } from '../controllers/dindiLeader.controller.js';

const router = Router();

router.post('/apply', authenticateJwt, applyDindiLeader);

export default router;
