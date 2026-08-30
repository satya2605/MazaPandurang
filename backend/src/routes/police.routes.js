import { Router } from 'express';
import { getPoliceUnits, registerPoliceProfile, getPoliceProfile } from '../controllers/police.controller.js';
import { authenticateJwt } from '../middleware/auth.js';

const router = Router();

router.get('/units', getPoliceUnits);
router.post('/register', authenticateJwt, registerPoliceProfile);
router.post('/apply', authenticateJwt, registerPoliceProfile);
router.get('/profile', authenticateJwt, getPoliceProfile);
router.get('/profile/:id', getPoliceProfile);

export default router;
