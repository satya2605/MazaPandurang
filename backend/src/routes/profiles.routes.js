import { Router } from 'express';
import { getProfileById, updateProfile } from '../controllers/profiles.controller.js';

const router = Router();

router.get('/:id', getProfileById);
router.patch('/:id', updateProfile);

export default router;
