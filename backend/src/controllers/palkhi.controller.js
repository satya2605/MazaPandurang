import { getSupabaseClient } from '../db/supabase.js';

export const publishedStateMap = new Map();

export async function getPalkhiTracking(req, res, next) {
  try {
    const client = getSupabaseClient();

    let query = client
      .from('palkhi_tracking')
      .select('*')
      .order('updated_at', { ascending: false });

    if (!req.user || req.user.role !== 'admin') {
      query = query.eq('is_published', true);
    }

    let { data, error } = await query;

    if (error || !data || data.length === 0) {
      const { data: allData } = await client.from('palkhi_tracking').select('*').order('updated_at', { ascending: false });
      data = (allData || []).filter((item) => {
        if (publishedStateMap.has(item.id)) {
          return publishedStateMap.get(item.id) === true;
        }
        return item.is_published !== false && item.is_published !== 'false';
      });
    } else {
      data = data.filter((item) => {
        if (publishedStateMap.has(item.id)) {
          return publishedStateMap.get(item.id) === true;
        }
        return true;
      });
    }

    if (!data || data.length === 0) {
      return res.json({
        id: 'PALKHI-DEMO-001',
        name: 'Sant Dnyaneshwar Maharaj Palkhi',
        saint: 'Sant Dnyaneshwar Maharaj',
        currentStage: 'Saswad Stay (सासवड मुक्काम)',
        nextStop: 'Jejuri (जेजुरी)',
        latitude: 18.3411,
        longitude: 74.0305,
        lastUpdated: new Date().toISOString(),
      });
    }

    // Map list or single item matching backward-compatible contract without exposing operator identity
    const mappedList = data.map((item) => ({
      id: item.id,
      name: item.name,
      saint: item.saint || 'Sant Dnyaneshwar Maharaj',
      currentStage: item.current_stage,
      nextStop: item.next_stop,
      latitude: parseFloat(item.latitude),
      longitude: parseFloat(item.longitude),
      lastUpdated: item.updated_at,
    }));

    if (req.query.single === 'true' || mappedList.length === 1) {
      return res.json(mappedList[0]);
    }

    return res.json(mappedList);
  } catch (err) {
    next(err);
  }
}

export async function updatePalkhiLocation(req, res, next) {
  try {
    const { id } = req.params;
    const { latitude, longitude, location_name, stage, current_stage, next_stop } = req.body;
    const client = getSupabaseClient();

    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Fetch target Palkhi
    const { data: palkhi, error: fetchErr } = await client
      .from('palkhi_tracking')
      .select('*')
      .eq('id', id)
      .single();

    if (fetchErr || !palkhi) {
      return res.status(404).json({ error: 'Palkhi not found' });
    }

    // Server-side authorization check: Must be Admin OR assigned location operator for this exact Palkhi
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

    // Validate coordinates if provided
    const parsedLat = latitude !== undefined ? parseFloat(latitude) : parseFloat(palkhi.latitude);
    const parsedLng = longitude !== undefined ? parseFloat(longitude) : parseFloat(palkhi.longitude);

    if (isNaN(parsedLat) || isNaN(parsedLng) || parsedLat < -90 || parsedLat > 90 || parsedLng < -180 || parsedLng > 180) {
      return res.status(400).json({ error: 'Invalid latitude or longitude coordinates' });
    }

    const updates = {
      latitude: parsedLat,
      longitude: parsedLng,
      current_stage: current_stage || location_name || stage || palkhi.current_stage,
      next_stop: next_stop || palkhi.next_stop,
      last_updated_by: req.user.id,
      updated_at: new Date().toISOString(),
    };

    const { data: updatedPalkhi, error: updateErr } = await client
      .from('palkhi_tracking')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    if (updateErr) throw updateErr;

    res.json({
      message: 'Palkhi live location updated successfully.',
      palkhi: {
        id: updatedPalkhi.id,
        name: updatedPalkhi.name,
        currentStage: updatedPalkhi.current_stage,
        nextStop: updatedPalkhi.next_stop,
        latitude: parseFloat(updatedPalkhi.latitude),
        longitude: parseFloat(updatedPalkhi.longitude),
        lastUpdated: updatedPalkhi.updated_at,
      },
    });
  } catch (err) {
    next(err);
  }
}
