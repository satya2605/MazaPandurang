import { Router } from 'express';
import { requireAdminRole } from '../middleware/adminAuth.js';
import {
  getAdminDashboard,
  getAdminNgos,
  getAdminNgoById,
  approveNgo,
  rejectNgo,
  getNgoDocumentUrl,
  getAdminServices,
  approveService,
  rejectService,
  publishService,
  unpublishService,
  getAdminDindis,
  approveDindi,
  rejectDindi,
  suspendDindi,
  getAdminLostPersons,
  approveLostPerson,
  rejectLostPerson,
  closeLostPerson,
  getAdminServiceReports,
  updateAdminServiceReport,
  getAdminUsers,
  updateUserStatus,
  getAdminAuditLogs,
  getAdminDindiLeaders,
  getAdminDindiLeaderById,
  approveDindiLeader,
  rejectDindiLeader,
  suspendDindiLeader,
  getAdminPoliceOfficers,
  getAdminPoliceOfficerById,
  approvePoliceOfficer,
  rejectPoliceOfficer,
  suspendPoliceOfficer,
} from '../controllers/admin.controller.js';
import {
  getAllPalkhisAdmin,
  getPalkhiByIdAdmin,
  createPalkhiAdmin,
  updatePalkhiAdmin,
  publishPalkhiAdmin,
  unpublishPalkhiAdmin,
  deletePalkhiAdmin,
  addPalkhiHaltAdmin,
  updatePalkhiHaltAdmin,
  deletePalkhiHaltAdmin,
} from '../controllers/palkhi.controller.js';

const router = Router();

// Apply requireAdminRole to all /api/admin/* endpoints
router.use(requireAdminRole);

// Dashboard & Audit Logs
router.get('/dashboard', getAdminDashboard);
router.get('/audit-logs', getAdminAuditLogs);

// Palkhi Moderation & Registry
router.get('/palkhis', getAllPalkhisAdmin);
router.get('/palkhis/:id', getPalkhiByIdAdmin);
router.post('/palkhis', createPalkhiAdmin);
router.put('/palkhis/:id', updatePalkhiAdmin);
router.patch('/palkhis/:id/publish', publishPalkhiAdmin);
router.patch('/palkhis/:id/unpublish', unpublishPalkhiAdmin);
router.delete('/palkhis/:id', deletePalkhiAdmin);

// Multi-Day Planned Halt Management
router.post('/palkhis/:id/halts', addPalkhiHaltAdmin);
router.put('/palkhi-halts/:haltId', updatePalkhiHaltAdmin);
router.delete('/palkhi-halts/:haltId', deletePalkhiHaltAdmin);

// NGO Moderation
router.get('/ngos', getAdminNgos);
router.get('/ngos/:id', getAdminNgoById);
router.patch('/ngos/:id/approve', approveNgo);
router.patch('/ngos/:id/reject', rejectNgo);
router.get('/ngos/:id/documents/:documentId/url', getNgoDocumentUrl);

// Service Moderation & 2-Gate Publication
router.get('/services', getAdminServices);
router.patch('/services/:id/approve', approveService);
router.patch('/services/:id/reject', rejectService);
router.patch('/services/:id/publish', publishService);
router.patch('/services/:id/unpublish', unpublishService);

// Dindi Moderation
router.get('/dindis', getAdminDindis);
router.patch('/dindis/:id/approve', approveDindi);
router.patch('/dindis/:id/reject', rejectDindi);
router.patch('/dindis/:id/suspend', suspendDindi);

// Lost Person Moderation
router.get('/lost-persons', getAdminLostPersons);
router.patch('/lost-persons/:id/approve', approveLostPerson);
router.patch('/lost-persons/:id/reject', rejectLostPerson);
router.patch('/lost-persons/:id/close', closeLostPerson);

// Service Reports Moderation
router.get('/service-reports', getAdminServiceReports);
router.patch('/service-reports/:id', updateAdminServiceReport);

// Dindi Leader Moderation & Approval
router.get('/dindi-leaders', getAdminDindiLeaders);
router.get('/dindi-leaders/:id', getAdminDindiLeaderById);
router.patch('/dindi-leaders/:id/approve', approveDindiLeader);
router.patch('/dindi-leaders/:id/reject', rejectDindiLeader);
router.patch('/dindi-leaders/:id/suspend', suspendDindiLeader);

// Police Officer Moderation & Approval
router.get('/police-officers', getAdminPoliceOfficers);
router.get('/police-officers/:id', getAdminPoliceOfficerById);
router.patch('/police-officers/:id/approve', approvePoliceOfficer);
router.patch('/police-officers/:id/reject', rejectPoliceOfficer);
router.patch('/police-officers/:id/suspend', suspendPoliceOfficer);

// User Governance
router.get('/users', getAdminUsers);
router.patch('/users/:id/status', updateUserStatus);

export default router;
