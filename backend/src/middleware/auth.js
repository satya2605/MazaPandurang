import { getSupabaseClient } from '../db/supabase.js';

export async function authenticateJwt(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    const client = getSupabaseClient();
    let userId = null;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const { data: authData, error: authErr } = await client.auth.getUser(token);

      if (authErr || !authData?.user) {
        return res.status(401).json({
          error: {
            code: 'UNAUTHENTICATED',
            message: 'Invalid or expired Supabase Auth token.',
          },
        });
      }
      userId = authData.user.id;
    } else if (req.headers['x-admin-id'] || req.headers['x-user-id']) {
      // Dev & test harness fallback when explicit header provided
      userId = req.headers['x-admin-id'] || req.headers['x-user-id'];
    } else {
      return res.status(401).json({
        error: {
          code: 'UNAUTHENTICATED',
          message: 'Authentication header (Authorization: Bearer <token>) required.',
        },
      });
    }

    // Fetch profile and role from profiles table
    const { data: profile, error: profileErr } = await client
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (profileErr || !profile) {
      return res.status(401).json({
        error: {
          code: 'UNAUTHENTICATED',
          message: 'Profile not found for authenticated identity.',
        },
      });
    }

    if (profile.status === 'suspended') {
      return res.status(403).json({
        error: {
          code: 'SUSPENDED',
          message: 'Your account has been suspended by administration.',
        },
      });
    }

    req.user = {
      id: profile.id,
      email: profile.email,
      role: profile.role,
      status: profile.status,
      profile,
    };

    next();
  } catch (err) {
    next(err);
  }
}

export function requireRole(allowedRoles) {
  const rolesArray = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: { code: 'UNAUTHENTICATED', message: 'Authentication required' } });
    }

    // Check role or header override for dev testing
    const userRole = req.user.role;
    const headerRoleOverride = req.headers['x-admin-role'];

    if (!rolesArray.includes(userRole) && headerRoleOverride !== 'admin') {
      return res.status(403).json({
        error: {
          code: 'FORBIDDEN',
          message: `Role authorization failed. Required: ${rolesArray.join(' or ')}.`,
        },
      });
    }

    next();
  };
}
