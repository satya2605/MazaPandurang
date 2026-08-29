import { Router } from 'express';
import { authenticateJwt } from '../middleware/auth.js';
import { getPalkhiTracking, updatePalkhiLocation } from '../controllers/palkhi.controller.js';

const router = Router();

router.get('/', getPalkhiTracking);
router.patch('/:id/location', authenticateJwt, updatePalkhiLocation);

export default router;
