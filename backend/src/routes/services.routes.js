import { Router } from 'express';
import {
  getAllServices,
  getServiceById,
  createService,
  updateService,
  getServiceImages,
  getNearestServices,
} from '../controllers/services.controller.js';

const router = Router();

router.get('/', getAllServices);
router.get('/nearest', getNearestServices);
router.get('/:id', getServiceById);
router.post('/', createService);
router.patch('/:id', updateService);
router.get('/:id/images', getServiceImages);

export default router;
