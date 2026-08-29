import { Router } from 'express';
import {
  getAllDindis,
  getDindiById,
  createDindi,
  updateDindi,
  getDindiMembers,
  joinDindi,
} from '../controllers/dindis.controller.js';

const router = Router();

router.get('/', getAllDindis);
router.get('/:id', getDindiById);
router.post('/', createDindi);
router.patch('/:id', updateDindi);
router.get('/:id/members', getDindiMembers);
router.post('/:id/join', joinDindi);

export default router;
