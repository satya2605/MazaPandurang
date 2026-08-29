import { Router } from 'express';
import { authenticateJwt, requireRole } from '../middleware/auth.js';
import {
  getAllEmergencies,
  createEmergency,
  updateEmergency,
} from '../controllers/emergency.controller.js';

const router = Router();

router.get('/', authenticateJwt, getAllEmergencies);
router.post('/', authenticateJwt, createEmergency);
router.patch('/:id', authenticateJwt, requireRole(['police_authority', 'admin']), updateEmergency);

export default router;
