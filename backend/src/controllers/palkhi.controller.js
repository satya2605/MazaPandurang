import { getSupabaseClient } from '../db/supabase.js';

export const publishedStateMap = new Map();
export const inMemoryPalkhis = new Map();
export const inMemoryHalts = [];

async function logAdminAction(client, adminId, action, targetType, targetId, details) {
  try {
    await client.from('admin_audit_logs').insert({
      admin_id: adminId,
      action: action,
      target_type: targetType,
      target_id: String(targetId),
      details: typeof details === 'object' ? JSON.stringify(details) : details,
    });
  } catch (e) {
    console.error('Audit log creation error:', e);
  }
}

// -----------------------------------------------------------------------------
// PUBLIC ENDPOINT: GET /api/palkhi
// Returns published & active Palkhis with nested multi-day halt schedule
// -----------------------------------------------------------------------------
export async function getPalkhiTracking(req, res, next) {
  try {
    const client = getSupabaseClient();

    let palkhiList = [];
    try {
      let query = client
        .from('palkhi_tracking')
        .select('*')
        .order('updated_at', { ascending: false });

      const isAdmin = req.user && req.user.role === 'admin';
      if (!isAdmin) {
        query = query.or('is_published.eq.true,is_published.is.null');
      }

      const { data, error } = await query;
      if (!error && data && data.length > 0) {
        palkhiList = data;
      }
    } catch (e) {
      console.warn('palkhi_tracking query fallback:', e.message);
    }

    // Include in-memory created Palkhis if present
    for (const [id, item] of inMemoryPalkhis.entries()) {
      if (!palkhiList.some((p) => p.id === id)) {
        palkhiList.push(item);
      }
    }

    // Fallback demo Palkhi if list is empty
    if (palkhiList.length === 0) {
      palkhiList = [
        {
          id: 'PALKHI-DEMO-001',
          name: 'Sant Dnyaneshwar Maharaj Palkhi',
          saint: 'Sant Dnyaneshwar Maharaj',
          description: 'Official Palkhi procession of Sant Dnyaneshwar Maharaj from Alandi to Pandharpur',
          start_point: 'Alandi',
          destination: 'Pandharpur',
          current_stage: 'Saswad Stay (सासवड मुक्काम)',
          next_stop: 'Jejuri (जेजुरी)',
          latitude: 18.3411,
          longitude: 74.0305,
          is_published: true,
          status: 'ACTIVE',
          updated_at: new Date().toISOString(),
        },
      ];
    }

    const isAdmin = req.user && req.user.role === 'admin';

    // Filter using publishedStateMap override if present
    palkhiList = palkhiList.filter((item) => {
      if (publishedStateMap.has(item.id)) {
        return publishedStateMap.get(item.id) === true;
      }
      return isAdmin || (item.is_published !== false && item.is_published !== 'false');
    });

    // Fetch all halts from palkhi_halts table
    let allHalts = [...inMemoryHalts];
    try {
      const { data: halts } = await client
        .from('palkhi_halts')
        .select('*')
        .order('day_number', { ascending: true });
      if (halts && halts.length > 0) {
        for (const h of halts) {
          if (!allHalts.some((existing) => existing.id === h.id)) {
            allHalts.push(h);
          }
        }
      }
    } catch (e) {
      console.warn('palkhi_halts query fallback:', e.message);
    }

    // Map output to canonical contract (concealing assigned_operator_id from public response)
    const mappedList = palkhiList.map((item) => {
      const haltsForItem = allHalts
        .filter((h) => String(h.palkhi_id) === String(item.id))
        .sort((a, b) => a.day_number - b.day_number)
        .map((h) => ({
          id: h.id,
          palkhi_id: h.palkhi_id,
          day_number: parseInt(h.day_number, 10),
          halt_date: h.halt_date,
          location_name: h.location_name,
          approx_latitude: h.approx_latitude ? parseFloat(h.approx_latitude) : null,
          approx_longitude: h.approx_longitude ? parseFloat(h.approx_longitude) : null,
          next_destination: h.next_destination || null,
          expected_arrival: h.expected_arrival || null,
          expected_departure: h.expected_departure || null,
        }));

      return {
        id: item.id,
        name: item.name,
        saint: item.saint || 'Sant Dnyaneshwar Maharaj',
        description: item.description || '',
        start_point: item.start_point || 'Alandi',
        destination: item.destination || 'Pandharpur',
        status: item.status || 'ACTIVE',
        is_published: item.is_published !== false && item.is_published !== 'false',
        current_location: {
          latitude: parseFloat(item.latitude || 18.3411),
          longitude: parseFloat(item.longitude || 74.0305),
          current_stage: item.current_stage || 'Alandi',
          next_stop: item.next_stop || 'Pune',
          last_updated: item.updated_at || new Date().toISOString(),
        },
        // Backward-compatible top-level coordinates
        currentStage: item.current_stage || 'Alandi',
        nextStop: item.next_stop || 'Pune',
        latitude: parseFloat(item.latitude || 18.3411),
        longitude: parseFloat(item.longitude || 74.0305),
        lastUpdated: item.updated_at || new Date().toISOString(),
        halts: haltsForItem,
      };
    });

    if (req.query.single === 'true' && mappedList.length > 0) {
      return res.json(mappedList[0]);
    }

    return res.json(mappedList);
  } catch (err) {
    next(err);
  }
}

// -----------------------------------------------------------------------------
// OPERATOR / ADMIN LOCATION UPDATE: PATCH /api/palkhi/:id/location
// -----------------------------------------------------------------------------
export async function updatePalkhiLocation(req, res, next) {
  try {
    const { id } = req.params;
    const { latitude, longitude, location_name, stage, current_stage, next_stop } = req.body;
    const client = getSupabaseClient();

    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    let palkhi = null;
    try {
      const { data: dbData } = await client
        .from('palkhi_tracking')
        .select('*')
        .eq('id', id)
        .single();
      palkhi = dbData;
    } catch (_) {}

    if (!palkhi && inMemoryPalkhis.has(id)) {
      palkhi = inMemoryPalkhis.get(id);
    }

    if (!palkhi && (id === 'PALKHI-DEMO-001' || id === '00000000-0000-0000-0000-000000000100')) {
      palkhi = {
        id: id,
        name: 'Sant Dnyaneshwar Maharaj Palkhi',
        saint: 'Sant Dnyaneshwar Maharaj',
        current_stage: 'Alandi',
        next_stop: 'Pune',
        latitude: 18.6772,
        longitude: 73.8967,
        assigned_operator_id: '00000000-0000-0000-0000-000000000002',
      };
    }

    if (!palkhi) {
      return res.status(404).json({ error: 'Palkhi not found' });
    }

    const isAssignedOperator = (req.user.role === 'palkhi_operator' || req.user.role === 'dindi_leader') && 
      (palkhi.assigned_operator_id === req.user.id || palkhi.last_updated_by === req.user.id);
    const isAdmin = req.user.role === 'admin';

    if (!isAdmin && !isAssignedOperator) {
      return res.status(403).json({
        error: {
          code: 'FORBIDDEN',
          message: 'You are not authorized to update live location for this Palkhi.',
        },
      });
    }

    const parsedLat = latitude !== undefined ? parseFloat(latitude) : parseFloat(palkhi.latitude);
    const parsedLng = longitude !== undefined ? parseFloat(longitude) : parseFloat(palkhi.longitude);

    if (isNaN(parsedLat) || isNaN(parsedLng) || parsedLat < -90 || parsedLat > 90 || parsedLng < -180 || parsedLng > 180) {
      return res.status(400).json({ error: 'Invalid latitude or longitude coordinates' });
    }

    const updates = {
      ...palkhi,
      latitude: parsedLat,
      longitude: parsedLng,
      current_stage: current_stage || location_name || stage || palkhi.current_stage,
      next_stop: next_stop || palkhi.next_stop,
      last_updated_by: req.user.id,
      updated_at: new Date().toISOString(),
    };

    try {
      await client
        .from('palkhi_tracking')
        .update({
          latitude: parsedLat,
          longitude: parsedLng,
          current_stage: updates.current_stage,
          next_stop: updates.next_stop,
          last_updated_by: req.user.id,
          updated_at: updates.updated_at,
        })
        .eq('id', id);
    } catch (_) {}

    inMemoryPalkhis.set(id, updates);

    res.json({
      message: 'Palkhi live location updated successfully.',
      palkhi: {
        id: updates.id,
        name: updates.name,
        currentStage: updates.current_stage,
        nextStop: updates.next_stop,
        latitude: parseFloat(updates.latitude),
        longitude: parseFloat(updates.longitude),
        lastUpdated: updates.updated_at,
      },
    });
  } catch (err) {
    next(err);
  }
}

// =============================================================================
// ADMIN REGISTRY ENDPOINTS
// =============================================================================

// GET /api/admin/palkhis — List all Palkhis including unpublished
export async function getAllPalkhisAdmin(req, res, next) {
  try {
    const client = getSupabaseClient();
    let palkhiList = [];
    try {
      const { data, error } = await client
        .from('palkhi_tracking')
        .select('*')
        .order('created_at', { ascending: false });
      if (!error && data) palkhiList = data;
    } catch (_) {}

    for (const [id, item] of inMemoryPalkhis.entries()) {
      if (!palkhiList.some((p) => p.id === id)) {
        palkhiList.push(item);
      }
    }

    if (palkhiList.length === 0) {
      palkhiList = [
        {
          id: 'PALKHI-DEMO-001',
          name: 'Sant Dnyaneshwar Maharaj Palkhi',
          saint: 'Sant Dnyaneshwar Maharaj',
          description: 'Official Palkhi procession of Sant Dnyaneshwar Maharaj',
          start_point: 'Alandi',
          destination: 'Pandharpur',
          status: 'ACTIVE',
          is_published: true,
          assigned_operator_id: null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      ];
    }

    let allHalts = [...inMemoryHalts];
    try {
      const { data: halts } = await client
        .from('palkhi_halts')
        .select('*')
        .order('day_number', { ascending: true });
      if (halts && halts.length > 0) {
        for (const h of halts) {
          if (!allHalts.some((existing) => existing.id === h.id)) {
            allHalts.push(h);
          }
        }
      }
    } catch (_) {}

    const mapped = palkhiList.map((item) => ({
      ...item,
      is_published: publishedStateMap.has(item.id)
        ? publishedStateMap.get(item.id)
        : item.is_published !== false && item.is_published !== 'false',
      halts: allHalts
        .filter((h) => String(h.palkhi_id) === String(item.id))
        .sort((a, b) => a.day_number - b.day_number),
    }));

    res.json(mapped);
  } catch (err) {
    next(err);
  }
}

// GET /api/admin/palkhis/:id — Details of single Palkhi
export async function getPalkhiByIdAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    let item = null;
    try {
      const { data } = await client.from('palkhi_tracking').select('*').eq('id', id).single();
      item = data;
    } catch (_) {}

    if (!item && inMemoryPalkhis.has(id)) {
      item = inMemoryPalkhis.get(id);
    }

    if (!item) {
      return res.status(404).json({ error: 'Palkhi entity not found' });
    }

    let allHalts = [...inMemoryHalts];
    try {
      const { data: halts } = await client.from('palkhi_halts').select('*').eq('palkhi_id', id).order('day_number', { ascending: true });
      if (halts) allHalts = halts;
    } catch (_) {}

    res.json({
      ...item,
      is_published: publishedStateMap.has(item.id) ? publishedStateMap.get(item.id) : item.is_published !== false,
      halts: allHalts.filter((h) => String(h.palkhi_id) === String(id)).sort((a, b) => a.day_number - b.day_number),
    });
  } catch (err) {
    next(err);
  }
}

// POST /api/admin/palkhis — Create a new Palkhi in registry
export async function createPalkhiAdmin(req, res, next) {
  try {
    const { name, saint, description, start_point, destination, status, is_published, assigned_operator_id } = req.body;
    const client = getSupabaseClient();

    if (!name || name.trim() === '') {
      return res.status(400).json({ error: 'Palkhi name is required' });
    }

    const newId = `PALKHI-${Date.now()}`;
    const newRecord = {
      id: newId,
      name: name.trim(),
      saint: saint ? saint.trim() : 'Sant Dnyaneshwar Maharaj',
      description: description ? description.trim() : '',
      start_point: start_point ? start_point.trim() : 'Alandi',
      destination: destination ? destination.trim() : 'Pandharpur',
      status: status || 'ACTIVE',
      is_published: is_published !== false,
      assigned_operator_id: assigned_operator_id || null,
      current_stage: start_point ? start_point.trim() : 'Alandi',
      next_stop: destination ? destination.trim() : 'Pandharpur',
      latitude: 18.6772,
      longitude: 73.8967,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    let data = newRecord;
    try {
      const { data: dbData, error } = await client
        .from('palkhi_tracking')
        .insert(newRecord)
        .select()
        .single();
      if (!error && dbData) data = dbData;
    } catch (e) {
      console.warn('palkhi_tracking db insert fallback:', e.message);
    }

    inMemoryPalkhis.set(data.id, data);
    publishedStateMap.set(data.id, data.is_published);
    await logAdminAction(client, req.user.id, 'CREATE_PALKHI', 'palkhi_tracking', data.id, { name: data.name });

    res.status(201).json({ message: 'Palkhi created successfully', palkhi: data });
  } catch (err) {
    next(err);
  }
}

// PUT /api/admin/palkhis/:id — Update Palkhi metadata
export async function updatePalkhiAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const { name, saint, description, start_point, destination, status, is_published, assigned_operator_id } = req.body;
    const client = getSupabaseClient();

    let existing = inMemoryPalkhis.get(id) || {};
    const updates = {
      ...existing,
      id,
      updated_at: new Date().toISOString(),
    };
    if (name !== undefined) updates.name = name;
    if (saint !== undefined) updates.saint = saint;
    if (description !== undefined) updates.description = description;
    if (start_point !== undefined) updates.start_point = start_point;
    if (destination !== undefined) updates.destination = destination;
    if (status !== undefined) updates.status = status;
    if (is_published !== undefined) {
      updates.is_published = is_published;
      publishedStateMap.set(id, is_published);
    }
    if (assigned_operator_id !== undefined) updates.assigned_operator_id = assigned_operator_id;

    try {
      await client
        .from('palkhi_tracking')
        .update(updates)
        .eq('id', id);
    } catch (_) {}

    inMemoryPalkhis.set(id, updates);
    await logAdminAction(client, req.user.id, 'UPDATE_PALKHI', 'palkhi_tracking', id, updates);

    res.json({ message: 'Palkhi updated successfully', palkhi: updates });
  } catch (err) {
    next(err);
  }
}

// PATCH /api/admin/palkhis/:id/publish
export async function publishPalkhiAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    publishedStateMap.set(id, true);
    if (inMemoryPalkhis.has(id)) {
      inMemoryPalkhis.get(id).is_published = true;
    }
    try {
      await client.from('palkhi_tracking').update({ is_published: true }).eq('id', id);
    } catch (_) {}

    await logAdminAction(client, req.user.id, 'PUBLISH_PALKHI', 'palkhi_tracking', id, { is_published: true });

    res.json({ message: 'Palkhi published successfully', id, is_published: true });
  } catch (err) {
    next(err);
  }
}

// PATCH /api/admin/palkhis/:id/unpublish
export async function unpublishPalkhiAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    publishedStateMap.set(id, false);
    if (inMemoryPalkhis.has(id)) {
      inMemoryPalkhis.get(id).is_published = false;
    }
    try {
      await client.from('palkhi_tracking').update({ is_published: false }).eq('id', id);
    } catch (_) {}

    await logAdminAction(client, req.user.id, 'UNPUBLISH_PALKHI', 'palkhi_tracking', id, { is_published: false });

    res.json({ message: 'Palkhi unpublished successfully', id, is_published: false });
  } catch (err) {
    next(err);
  }
}

// DELETE /api/admin/palkhis/:id
export async function deletePalkhiAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const client = getSupabaseClient();

    inMemoryPalkhis.delete(id);
    publishedStateMap.delete(id);
    try {
      await client.from('palkhi_tracking').delete().eq('id', id);
    } catch (_) {}

    await logAdminAction(client, req.user.id, 'DELETE_PALKHI', 'palkhi_tracking', id, { id });

    res.json({ message: 'Palkhi entity deleted successfully', id });
  } catch (err) {
    next(err);
  }
}

// =============================================================================
// ADMIN MULTI-DAY HALT PLANNER ENDPOINTS
// =============================================================================

// POST /api/admin/palkhis/:id/halts — Add a planned halt
export async function addPalkhiHaltAdmin(req, res, next) {
  try {
    const { id } = req.params;
    const { day_number, halt_date, location_name, approx_latitude, approx_longitude, next_destination, expected_arrival, expected_departure } = req.body;
    const client = getSupabaseClient();

    const dayNum = parseInt(day_number, 10);
    if (isNaN(dayNum) || dayNum <= 0) {
      return res.status(400).json({ error: 'day_number must be a positive integer' });
    }
    if (!halt_date) {
      return res.status(400).json({ error: 'halt_date is required' });
    }
    if (!location_name || location_name.trim() === '') {
      return res.status(400).json({ error: 'location_name is required' });
    }

    const lat = approx_latitude !== undefined && approx_latitude !== null ? parseFloat(approx_latitude) : null;
    const lng = approx_longitude !== undefined && approx_longitude !== null ? parseFloat(approx_longitude) : null;

    if (lat !== null && (isNaN(lat) || lat < -90 || lat > 90)) {
      return res.status(400).json({ error: 'Invalid approx_latitude' });
    }
    if (lng !== null && (isNaN(lng) || lng < -180 || lng > 180)) {
      return res.status(400).json({ error: 'Invalid approx_longitude' });
    }

    const haltRecord = {
      id: `HALT-${Date.now()}`,
      palkhi_id: id,
      day_number: dayNum,
      halt_date: halt_date,
      location_name: location_name.trim(),
      approx_latitude: lat,
      approx_longitude: lng,
      next_destination: next_destination ? next_destination.trim() : null,
      expected_arrival: expected_arrival ? expected_arrival.trim() : null,
      expected_departure: expected_departure ? expected_departure.trim() : null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

    let data = haltRecord;
    try {
      const { data: dbData, error } = await client
        .from('palkhi_halts')
        .insert(haltRecord)
        .select()
        .single();
      if (!error && dbData) data = dbData;
    } catch (e) {
      console.warn('palkhi_halts db insert fallback:', e.message);
    }

    inMemoryHalts.push(data);
    await logAdminAction(client, req.user.id, 'CREATE_PALKHI_HALT', 'palkhi_halts', data.id, { palkhi_id: id, day_number: dayNum, location_name });

    res.status(201).json({ message: 'Palkhi halt created successfully', halt: data });
  } catch (err) {
    next(err);
  }
}

// PUT /api/admin/palkhi-halts/:haltId — Update a planned halt
export async function updatePalkhiHaltAdmin(req, res, next) {
  try {
    const { haltId } = req.params;
    const { day_number, halt_date, location_name, approx_latitude, approx_longitude, next_destination, expected_arrival, expected_departure } = req.body;
    const client = getSupabaseClient();

    const updates = { updated_at: new Date().toISOString() };
    if (day_number !== undefined) updates.day_number = parseInt(day_number, 10);
    if (halt_date !== undefined) updates.halt_date = halt_date;
    if (location_name !== undefined) updates.location_name = location_name.trim();
    if (approx_latitude !== undefined) updates.approx_latitude = approx_latitude !== null ? parseFloat(approx_latitude) : null;
    if (approx_longitude !== undefined) updates.approx_longitude = approx_longitude !== null ? parseFloat(approx_longitude) : null;
    if (next_destination !== undefined) updates.next_destination = next_destination;
    if (expected_arrival !== undefined) updates.expected_arrival = expected_arrival;
    if (expected_departure !== undefined) updates.expected_departure = expected_departure;

    let data = { id: haltId, ...updates };
    try {
      const { data: dbData, error } = await client
        .from('palkhi_halts')
        .update(updates)
        .eq('id', haltId)
        .select()
        .single();
      if (!error && dbData) data = dbData;
    } catch (_) {}

    const idx = inMemoryHalts.findIndex((h) => h.id === haltId);
    if (idx !== -1) {
      inMemoryHalts[idx] = { ...inMemoryHalts[idx], ...updates };
    }

    await logAdminAction(client, req.user.id, 'UPDATE_PALKHI_HALT', 'palkhi_halts', haltId, updates);

    res.json({ message: 'Palkhi halt updated successfully', halt: data });
  } catch (err) {
    next(err);
  }
}

// DELETE /api/admin/palkhi-halts/:haltId — Delete a planned halt
export async function deletePalkhiHaltAdmin(req, res, next) {
  try {
    const { haltId } = req.params;
    const client = getSupabaseClient();

    const idx = inMemoryHalts.findIndex((h) => h.id === haltId);
    if (idx !== -1) {
      inMemoryHalts.splice(idx, 1);
    }

    try {
      await client.from('palkhi_halts').delete().eq('id', haltId);
    } catch (_) {}

    await logAdminAction(client, req.user.id, 'DELETE_PALKHI_HALT', 'palkhi_halts', haltId, { haltId });

    res.json({ message: 'Palkhi halt deleted successfully', haltId });
  } catch (err) {
    next(err);
  }
}
