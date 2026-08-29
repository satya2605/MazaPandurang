import { Router } from 'express';
import {
  getServices,
  getServiceById,
  submitServiceReport,
  getNearestServices,
} from '../controllers/services.controller.js';
import { uploadServiceImage } from '../controllers/storage.controller.js';
import { uploadSingleImage } from '../middleware/uploadMiddleware.js';

const router = Router();

router.get('/', getServices);
router.get('/nearest', getNearestServices);
router.get('/:id', getServiceById);
router.post('/:serviceId/reports', submitServiceReport);
router.post('/:serviceId/images', uploadSingleImage, uploadServiceImage);

export default router;
