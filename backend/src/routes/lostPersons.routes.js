import { Router } from 'express';
import {
  createLostPersonReport,
  getApprovedLostPersons,
  getLostPersonById,
  createSighting,
} from '../controllers/lostPersons.controller.js';
import { uploadLostPersonImage } from '../controllers/storage.controller.js';
import { uploadSingleImage } from '../middleware/uploadMiddleware.js';

const router = Router();

router.post('/', createLostPersonReport);
router.get('/', getApprovedLostPersons);
router.get('/:id', getLostPersonById);
router.post('/:id/sightings', createSighting);
router.post('/:id/images', uploadSingleImage, uploadLostPersonImage);

export default router;
