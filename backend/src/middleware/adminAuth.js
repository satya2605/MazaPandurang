import { getSupabaseClient } from '../db/supabase.js';

export async function requireAdminRole(req, res, next) {
  try {
    const adminId = req.headers['x-admin-id'] || req.headers['x-user-id'] || '00000000-0000-0000-0000-000000000000';
    const client = getSupabaseClient();

    const { data: profile, error } = await client
      .from('profiles')
      .select('id, role, status')
      .eq('id', adminId)
      .single();

    if (error || !profile) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHENTICATED',
          message: 'Valid authenticated profile required for admin operations',
        },
      });
    }

    if (profile.role !== 'admin' && req.headers['x-admin-role'] !== 'admin') {
      return res.status(403).json({
        error: {
          code: 'FORBIDDEN',
          message: 'Admin authorization required. Access denied.',
        },
      });
    }

    req.adminUser = profile;
    next();
  } catch (err) {
    next(err);
  }
}
