import { Router } from 'express';
import { getDindis, getDindiById } from '../controllers/dindis.controller.js';

const router = Router();

router.get('/', getDindis);
router.get('/:id', getDindiById);

export default router;
