import { Router } from 'express';
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
router.post('/', createNgo);
router.patch('/:id', updateNgo);
router.get('/:id/images', getNgoImages);
router.post('/:id/images', addNgoImage);
router.delete('/:id/images/:imageId', deleteNgoImage);

export default router;
