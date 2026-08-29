import { Router } from 'express';
import {
  getAllDindis,
  getDindis,
  getDindiById,
  createDindi,
  updateDindi,
  getDindiMembers,
  joinDindi,
  updateDindiMembership,
} from '../controllers/dindis.controller.js';
import { authenticateJwt } from '../middleware/auth.js';

const router = Router();

// Public Read Endpoints
router.get('/', getAllDindis);
router.get('/:id', getDindiById);
router.get('/:id/members', getDindiMembers);

// Authenticated Write & Moderation Endpoints
router.post('/', authenticateJwt, createDindi);
router.patch('/:id', authenticateJwt, updateDindi);
router.put('/:id', authenticateJwt, updateDindi);
router.post('/:id/join', authenticateJwt, joinDindi);
router.patch('/memberships/:id', authenticateJwt, updateDindiMembership);

export default router;
