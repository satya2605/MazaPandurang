import { Router } from 'express';
import {
  getAllNgos,
  getNgoById,
  createNgo,
  updateNgo,
  getNgoImages,
} from '../controllers/ngos.controller.js';

const router = Router();

router.get('/', getAllNgos);
router.get('/:id', getNgoById);
router.post('/', createNgo);
router.patch('/:id', updateNgo);
router.get('/:id/images', getNgoImages);

export default router;
