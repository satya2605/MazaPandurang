import { Router } from 'express';
import { getBhaktiContent } from '../controllers/bhakti.controller.js';

const router = Router();

router.get('/', getBhaktiContent);

export default router;
