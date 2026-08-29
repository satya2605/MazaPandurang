import { Router } from 'express';
import { updateDindiMembership } from '../controllers/dindis.controller.js';

const router = Router();

router.patch('/:id', updateDindiMembership);

export default router;
