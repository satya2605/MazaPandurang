import { Router } from 'express';
import {
  createServiceReport,
  getServiceReports,
  updateServiceReport,
} from '../controllers/serviceReports.controller.js';

const router = Router();

router.post('/', createServiceReport);
router.get('/', getServiceReports);
router.patch('/:id', updateServiceReport);

export default router;
