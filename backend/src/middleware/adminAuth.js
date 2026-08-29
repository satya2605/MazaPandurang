import { authenticateJwt, requireRole } from './auth.js';

export const requireAdminRole = [
  authenticateJwt,
  requireRole('admin'),
];
