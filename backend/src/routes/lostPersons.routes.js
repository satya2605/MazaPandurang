import { Router } from 'express';
import {
  getApprovedLostPersons,
  createLostPersonReport,
  updateLostPersonReport,
  createSighting,
  getSightings,
  getSignedPhotoUrl,
} from '../controllers/lostPersons.controller.js';

const router = Router();

router.get('/', getApprovedLostPersons);
router.post('/', createLostPersonReport);
router.patch('/:id', updateLostPersonReport);
router.post('/:id/sightings', createSighting);
router.get('/:id/sightings', getSightings);
router.get('/:id/photo-url', getSignedPhotoUrl);

export default router;
