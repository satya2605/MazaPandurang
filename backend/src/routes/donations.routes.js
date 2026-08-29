import { Router } from 'express';
import { getDonationsInfo } from '../controllers/donations.controller.js';

const router = Router();

router.get('/', getDonationsInfo);

export default router;
