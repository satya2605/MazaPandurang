import { Router } from 'express';
import {
  getAllDindis,
  getDindis,
  getDindiById,
  createDindi,
  updateDindi,
  updateDindiLocation,
  addDindiHalt,
  updateDindiHalt,
  deleteDindiHalt,
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

// Authenticated Write & Operational Endpoints
router.post('/', authenticateJwt, createDindi);
router.patch('/:id', authenticateJwt, updateDindi);
router.put('/:id', authenticateJwt, updateDindi);
router.patch('/:id/location', authenticateJwt, updateDindiLocation);

// Multi-Day Planned Halt Planner Endpoints
router.post('/:id/halts', authenticateJwt, addDindiHalt);
router.put('/halts/:haltId', authenticateJwt, updateDindiHalt);
router.patch('/halts/:haltId', authenticateJwt, updateDindiHalt);
router.delete('/halts/:haltId', authenticateJwt, deleteDindiHalt);

// Pilgrim Membership Endpoints
router.post('/:id/join', authenticateJwt, joinDindi);
router.patch('/memberships/:id', authenticateJwt, updateDindiMembership);

export default router;
