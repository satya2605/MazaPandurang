import { Router } from 'express';
import { getPoliceUnits } from '../controllers/police.controller.js';

const router = Router();

router.get('/units', getPoliceUnits);

export default router;
