import { Router } from 'express';
import { authenticateJwt } from '../middleware/auth.js';
import {
  getAllNgos,
  getNgoById,
  createNgo,
  updateNgo,
  getNgoImages,
  addNgoImage,
  deleteNgoImage,
} from '../controllers/ngos.controller.js';

const router = Router();

router.get('/', getAllNgos);
router.get('/:id', getNgoById);
router.post('/', authenticateJwt, createNgo);
router.patch('/:id', authenticateJwt, updateNgo);
router.get('/:id/images', getNgoImages);
router.post('/:id/images', authenticateJwt, addNgoImage);
router.delete('/:id/images/:imageId', authenticateJwt, deleteNgoImage);

export default router;
