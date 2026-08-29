import { Router } from 'express';
import {
  getAllTrafficAlerts,
  createTrafficAlert,
  updateTrafficAlert,
} from '../controllers/trafficAlerts.controller.js';

const router = Router();

router.get('/', getAllTrafficAlerts);
router.post('/', createTrafficAlert);
router.patch('/:id', updateTrafficAlert);

export default router;
