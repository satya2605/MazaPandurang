import { Router } from 'express';
import { getCityPlaces } from '../controllers/cityPlaces.controller.js';

const router = Router();

router.get('/', getCityPlaces);

export default router;
