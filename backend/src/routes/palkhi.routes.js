import { Router } from 'express';
import { getPalkhiTracking } from '../controllers/palkhi.controller.js';

const router = Router();

router.get('/', getPalkhiTracking);

export default router;
