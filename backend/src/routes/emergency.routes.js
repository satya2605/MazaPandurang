import { Router } from 'express';
import {
  getAllEmergencies,
  createEmergency,
  updateEmergency,
} from '../controllers/emergency.controller.js';

const router = Router();

router.get('/', getAllEmergencies);
router.post('/', createEmergency);
router.patch('/:id', updateEmergency);

export default router;
