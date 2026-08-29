import { Router } from 'express';
import { getWariRoute } from '../controllers/wariRoute.controller.js';

const router = Router();

router.get('/', getWariRoute);

export default router;
