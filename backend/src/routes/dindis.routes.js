import { Router } from 'express';
import {
  getAllDindis,
  getDindiById,
  createDindi,
  updateDindi,
  getDindiMembers,
  joinDindi,
} from '../controllers/dindis.controller.js';

import { authenticateJwt } from '../middleware/auth.js';

const router = Router();

router.get('/', getAllDindis);
router.get('/:id', getDindiById);
router.post('/', authenticateJwt, createDindi);
router.patch('/:id', authenticateJwt, updateDindi);
router.get('/:id/members', getDindiMembers);
router.post('/:id/join', authenticateJwt, joinDindi);

export default router;
