import { getSupabaseClient } from '../db/supabase.js';
import { config } from '../config/env.js';

async function recordAuditLog(adminId, action, targetType, targetId, reason = null) {
  try {
    const client = getSupabaseClient();
    await client.from('admin_audit_logs').insert({
      admin_id: adminId || '00000000-0000-0000-0000-000000000000',
      action,
      target_type: targetType,
      target_id: targetId,
      reason,
    });
  } catch (err) {
    console.error('Failed to log admin audit action:', err.message);
  }
}

// 1. DASHBOARD COUNTS
export async function getAdminDashboard(req, res, next) {
  try {
    const client = getSupabaseClient();

    const [
      { count: pendingNgos },
      { count: pendingServices },
      { count: pendingDindis },
      { count: pendingDindiLeaders },
      { count: pendingLostPersons },
      { count: openServiceReports },
      { count: activeEmergencies },
      { count: activeTrafficAlerts },
    ] = await Promise.all([
      client.from('ngos').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      client.from('services').select('*', { count: 'exact', head: true }).eq('is_verified', false),
      client.from('dindis').select('*', { count: 'exact', head: true }).eq('status', 'Pending'),
      client.from('profiles').select('*', { count: 'exact', head: true }).eq('role', 'dindi_leader').eq('status', 'pending'),
      client.from('lost_person_reports').select('*', { count: 'exact', head: true }).eq('is_approved_by_admin', false),
      client.from('service_reports').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      client.from('emergency_requests').select('*', { count: 'exact', head: true }).neq('status', 'resolved'),
      client.from('traffic_alerts').select('*', { count: 'exact', head: true }).eq('status', 'ACTIVE'),
    ]);

    res.json({
      pending_ngos: pendingNgos || 0,
      pending_services: pendingServices || 0,
      pending_dindis: pendingDindis || 0,
      pending_dindi_leaders: pendingDindiLeaders || 0,
      pending_lost_person_reports: pendingLostPersons || 0,
      open_service_reports: openServiceReports || 0,
      active_emergencies: activeEmergencies || 0,
      active_traffic_alerts: activeTrafficAlerts || 0,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
}

// 2. NGO MODERATION
export async function getAdminNgos(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('ngos').select('*, ngo_images(id, image_url, caption)');
    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getAdminNgoById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('ngos')
      .select('*, ngo_images(*), profiles:user_id(display_name, email, phone)')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return res.status(404).json({ error: 'NGO not found' });
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function approveNgo(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('ngos')
      .update({ status: 'approved', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'APPROVE_NGO', 'ngo', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function rejectNgo(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('ngos')
      .update({ status: 'rejected', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'REJECT_NGO', 'ngo', id, reason || 'Registration details unverified');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function getNgoDocumentUrl(req, res, next) {
  try {
    const { id, documentId } = req.params;
    const client = getSupabaseClient();

    const storagePath = `ngo-documents/${id}/${documentId}`;
    const { data: signedData, error: signedErr } = await client.storage
      .from(config.storageBuckets.documents || 'documents')
      .createSignedUrl(storagePath, 3600);

    if (signedErr) throw signedErr;
    res.json({ signedUrl: signedData.signedUrl });
  } catch (err) {
    next(err);
  }
}

// 3. SERVICE MODERATION & 2-GATE PUBLICATION
export async function getAdminServices(req, res, next) {
  try {
    const { status, category, provider_id } = req.query;
    const client = getSupabaseClient();

    let query = client.from('services').select('*, service_images(id, storage_path)');
    if (category) query = query.ilike('category', category);
    if (provider_id) query = query.eq('provider_id', provider_id);
    if (status === 'pending') query = query.eq('is_verified', false);
    if (status === 'approved') query = query.eq('is_verified', true);

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function approveService(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('services')
      .update({ is_verified: true, updated_at: new Date().toISOString() })
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'APPROVE_SERVICE', 'service', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function rejectService(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('services')
      .update({ is_verified: false, is_active: false, updated_at: new Date().toISOString() })
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'REJECT_SERVICE', 'service', id, reason || 'Service unverified');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function publishService(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('services')
      .update({ is_active: true, updated_at: new Date().toISOString() })
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'PUBLISH_SERVICE', 'service', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function unpublishService(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('services')
      .update({ is_active: false, updated_at: new Date().toISOString() })
      .or(`id.eq.${id},service_id.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'UNPUBLISH_SERVICE', 'service', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

// 4. DINDI MODERATION
export async function getAdminDindis(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('dindis').select('*, profiles:leader_id(display_name, phone)');
    if (status) query = query.eq('status', status);

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function approveDindi(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('dindis')
      .update({ status: 'Active', updated_at: new Date().toISOString() })
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'APPROVE_DINDI', 'dindi', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function suspendDindi(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('dindis')
      .update({ status: 'Suspended', updated_at: new Date().toISOString() })
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'SUSPEND_DINDI', 'dindi', id, reason || 'Suspended by admin');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

// 5. LOST PERSON MODERATION
export async function getAdminLostPersons(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('lost_person_reports').select('*, lost_person_images(id, storage_path)');
    if (status === 'pending') query = query.eq('is_approved_by_admin', false);
    if (status === 'approved') query = query.eq('is_approved_by_admin', true);

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function approveLostPerson(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .update({ is_approved_by_admin: true, status: 'missing' })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'APPROVE_LOST_PERSON', 'lost_person', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function rejectLostPerson(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .update({ is_approved_by_admin: false, status: 'closed' })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'REJECT_LOST_PERSON', 'lost_person', id, reason || 'Report unverified');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

// 6. USER GOVERNANCE
export async function getAdminUsers(req, res, next) {
  try {
    const { role, status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('profiles').select('*');
    if (role) query = query.eq('role', role);
    if (status) query = query.eq('status', status);

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function updateUserStatus(req, res, next) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.adminUser?.id, 'UPDATE_USER_STATUS', 'profile', id, `Status updated to ${status}`);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

// 7. AUDIT LOGS
export async function getAdminAuditLogs(req, res, next) {
  try {
    const client = getSupabaseClient();
    const { data, error } = await client
      .from('admin_audit_logs')
      .select('*, profiles:admin_id(display_name, email)')
      .order('created_at', { ascending: false })
      .limit(50);

    if (error) {
      console.warn('Admin audit logs query fallback:', error.message);
      return res.json([]);
    }
    res.json(data || []);
  } catch (err) {
    res.json([]);
  }
}

// 8. DINDI LEADER MODERATION
export async function getAdminDindiLeaders(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('profiles').select('*, dindis(id, name, dindi_number, status)').eq('role', 'dindi_leader');
    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getAdminDindiLeaderById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .select('*, dindis(*)')
      .eq('id', id)
      .eq('role', 'dindi_leader')
      .single();

    if (error) {
      if (error.code === 'PGRST116') return res.status(404).json({ error: 'Dindi Leader profile not found' });
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function approveDindiLeader(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .update({ status: 'active', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    await recordAuditLog(req.user?.id || req.adminUser?.id, 'APPROVE_DINDI_LEADER', 'profile', id);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function rejectDindiLeader(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .update({ status: 'rejected', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.user?.id || req.adminUser?.id, 'REJECT_DINDI_LEADER', 'profile', id, reason || 'Dindi leader application rejected');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function suspendDindiLeader(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('profiles')
      .update({ status: 'suspended', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    // Also suspend Dindis led by this leader
    await client.from('dindis').update({ status: 'Suspended' }).eq('leader_id', id);

    await recordAuditLog(req.user?.id || req.adminUser?.id, 'SUSPEND_DINDI_LEADER', 'profile', id, reason || 'Dindi leader suspended');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function rejectDindi(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('dindis')
      .update({ status: 'Rejected', updated_at: new Date().toISOString() })
      .or(`id.eq.${id},dindi_number.eq.${id}`)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.user?.id || req.adminUser?.id, 'REJECT_DINDI', 'dindi', id, reason || 'Dindi registration rejected');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function closeLostPerson(req, res, next) {
  try {
    const { id } = req.params;
    const { reason } = req.body;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('lost_person_reports')
      .update({ status: 'found', updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.user?.id || req.adminUser?.id, 'CLOSE_LOST_PERSON', 'lost_person', id, reason || 'Person found and case closed');
    res.json(data);
  } catch (err) {
    next(err);
  }
}

export async function getAdminServiceReports(req, res, next) {
  try {
    const { status } = req.query;
    const client = getSupabaseClient();

    let query = client.from('service_reports').select('*, services(name, category), profiles:reporter_id(display_name, email)');
    if (status) query = query.eq('status', status);

    const { data, error } = await query;
    if (error) {
      console.warn('Admin service reports query fallback:', error.message);
      return res.json([]);
    }
    res.json(data || []);
  } catch (err) {
    res.json([]);
  }
}

export async function updateAdminServiceReport(req, res, next) {
  try {
    const { id } = req.params;
    const { status, admin_notes } = req.body;
    const client = getSupabaseClient();

    const updates = { updated_at: new Date().toISOString() };
    if (status) updates.status = status;
    if (admin_notes !== undefined) updates.admin_notes = admin_notes;

    const { data, error } = await client
      .from('service_reports')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    await recordAuditLog(req.user?.id || req.adminUser?.id, 'UPDATE_SERVICE_REPORT', 'service_report', id, `Status set to ${status || 'updated'}`);
    res.json(data);
  } catch (err) {
    next(err);
  }
}

// 9. PALKHI REGISTRY MODERATION
export async function getAdminPalkhis(req, res, next) {
  try {
    const client = getSupabaseClient();
    const { data, error } = await client
      .from('palkhi_tracking')
      .select('*')
      .order('updated_at', { ascending: false });

    if (error) throw error;
    res.json(data || []);
  } catch (err) {
    next(err);
  }
}

export async function getAdminPalkhiById(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('palkhi_tracking')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return res.status(404).json({ error: 'Palkhi entity not found' });
      throw error;
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
}

import { publishedStateMap } from './palkhi.controller.js';

export async function createPalkhi(req, res, next) {
  try {
    const {
      name,
      saint,
      description,
      start_point,
      destination,
      current_stage,
      next_stop,
      latitude,
      longitude,
      assigned_operator_id,
    } = req.body;

    const client = getSupabaseClient();
    const payload = {
      name: name || 'Sant Dnyaneshwar Maharaj Palkhi',
      current_stage: current_stage || 'Alandi Departure',
      next_stop: next_stop || 'Pune Stay',
      latitude: latitude !== undefined ? parseFloat(latitude) : 18.6772,
      longitude: longitude !== undefined ? parseFloat(longitude) : 73.8967,
      updated_at: new Date().toISOString(),
    };

    if (assigned_operator_id) {
      payload.last_updated_by = assigned_operator_id;
    }

    const { data, error } = await client
      .from('palkhi_tracking')
      .insert(payload)
      .select()
      .single();

    if (error) throw error;

    publishedStateMap.set(data.id, false); // Default: Unpublished

    const response = {
      ...data,
      saint: saint || 'Sant Dnyaneshwar Maharaj',
      start_point: start_point || 'Alandi',
      destination: destination || 'Pandharpur',
      status: 'ACTIVE',
      is_published: false,
      assigned_operator_id: assigned_operator_id || data.last_updated_by || null,
    };

    await recordAuditLog(req.user?.id || req.adminUser?.id, 'CREATE_PALKHI', 'PALKHI', data.id);
    res.status(201).json(response);
  } catch (err) {
    next(err);
  }
}

export async function updatePalkhi(req, res, next) {
  try {
    const { id } = req.params;
    const body = req.body;
    const client = getSupabaseClient();

    const updates = {
      updated_at: new Date().toISOString(),
    };
    if (body.name !== undefined) updates.name = body.name;
    if (body.current_stage !== undefined) updates.current_stage = body.current_stage;
    if (body.next_stop !== undefined) updates.next_stop = body.next_stop;
    if (body.latitude !== undefined) updates.latitude = parseFloat(body.latitude);
    if (body.longitude !== undefined) updates.longitude = parseFloat(body.longitude);
    if (body.assigned_operator_id !== undefined) updates.last_updated_by = body.assigned_operator_id;

    const { data, error } = await client
      .from('palkhi_tracking')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;

    if (body.is_published !== undefined) {
      publishedStateMap.set(id, body.is_published === true);
    }

    const response = {
      ...data,
      is_published: body.is_published !== undefined ? body.is_published : (publishedStateMap.get(id) ?? true),
      assigned_operator_id: body.assigned_operator_id !== undefined ? body.assigned_operator_id : (data.assigned_operator_id || data.last_updated_by),
    };

    const action = body.assigned_operator_id !== undefined 
      ? (body.assigned_operator_id ? 'ASSIGN_PALKHI_OPERATOR' : 'REMOVE_PALKHI_OPERATOR') 
      : 'UPDATE_PALKHI';

    await recordAuditLog(req.user?.id || req.adminUser?.id, action, 'PALKHI', id);
    res.json(response);
  } catch (err) {
    next(err);
  }
}

export async function publishPalkhi(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('palkhi_tracking')
      .select('*')
      .eq('id', id)
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({ error: 'Palkhi entity not found' });
    }

    publishedStateMap.set(id, true);

    try {
      await client.from('palkhi_tracking').update({ is_published: true }).eq('id', id);
    } catch (_) {}

    await recordAuditLog(req.user?.id || req.adminUser?.id, 'PUBLISH_PALKHI', 'PALKHI', id);
    res.json({ ...(data || {}), id, is_published: true });
  } catch (err) {
    next(err);
  }
}

export async function unpublishPalkhi(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { data, error } = await client
      .from('palkhi_tracking')
      .select('*')
      .eq('id', id)
      .single();

    if (error && error.code === 'PGRST116') {
      return res.status(404).json({ error: 'Palkhi entity not found' });
    }

    publishedStateMap.set(id, false);

    try {
      await client.from('palkhi_tracking').update({ is_published: false }).eq('id', id);
    } catch (_) {}

    await recordAuditLog(req.user?.id || req.adminUser?.id, 'UNPUBLISH_PALKHI', 'PALKHI', id);
    res.json({ ...(data || {}), id, is_published: false });
  } catch (err) {
    next(err);
  }
}

export async function deletePalkhi(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    const { error } = await client
      .from('palkhi_tracking')
      .delete()
      .eq('id', id);

    if (error) throw error;
    await recordAuditLog(req.user?.id || req.adminUser?.id, 'DELETE_PALKHI', 'PALKHI', id);
    res.json({ message: 'Palkhi entity deleted successfully', id });
  } catch (err) {
    next(err);
  }
}



