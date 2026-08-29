import { Router } from 'express';
import { updateDindiMembership } from '../controllers/dindis.controller.js';
import { authenticateJwt } from '../middleware/auth.js';

const router = Router();

router.patch('/:id', authenticateJwt, updateDindiMembership);

export default router;
