import { Router } from 'express';
import { createEmergencyRequest } from '../controllers/emergency.controller.js';

const router = Router();

router.post('/', createEmergencyRequest);

export default router;
