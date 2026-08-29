import { Router } from 'express';
import {
  getAllServices,
  getServiceById,
  createService,
  updateService,
  getServiceImages,
  addServiceImage,
  deleteServiceImage,
  getNearestServices,
} from '../controllers/services.controller.js';

const router = Router();

router.get('/', getAllServices);
router.get('/nearest', getNearestServices);
router.get('/:id', getServiceById);
router.post('/', createService);
router.patch('/:id', updateService);
router.get('/:id/images', getServiceImages);
router.post('/:id/images', addServiceImage);
router.delete('/:id/images/:imageId', deleteServiceImage);

export default router;
