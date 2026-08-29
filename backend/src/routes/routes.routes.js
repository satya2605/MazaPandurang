import { Router } from 'express';
import { getApplicationRoutes } from '../controllers/routes.controller.js';

const router = Router();

router.get('/', getApplicationRoutes);

export default router;
