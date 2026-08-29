import { createClient } from '@supabase/supabase-js';
import ws from 'ws';
import { config } from '../config/env.js';

let supabaseClient = null;

export function getSupabaseClient() {
  if (!supabaseClient) {
    if (!config.supabaseUrl || !config.supabaseServiceRoleKey) {
      throw new Error(
        'Cannot initialize Supabase client: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY missing in backend/.env'
      );
    }

    supabaseClient = createClient(
      config.supabaseUrl,
      config.supabaseServiceRoleKey,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
        realtime: {
          transport: ws,
        },
      }
    );
  }
  return supabaseClient;
}

export async function checkDatabaseConnection() {
  try {
    const client = getSupabaseClient();
    const { error } = await client
      .from('services')
      .select('count', { count: 'exact', head: true });

    if (error && error.code !== 'PGRST116' && error.code !== '42P01') {
      return { connected: false, message: error.message };
    }
    return {
      connected: true,
      message: 'Supabase PostgreSQL connected successfully',
    };
  } catch (err) {
    return { connected: false, message: err.message };
  }
}
