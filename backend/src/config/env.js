import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env from backend directory or workspace root
dotenv.config({ path: path.resolve(__dirname, '../../.env') });
dotenv.config({ path: path.resolve(__dirname, '../../../backend/.env') });
dotenv.config({ path: path.resolve(process.cwd(), 'backend/.env') });
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

export const config = {
  port: process.env.PORT || 3000,
  supabaseUrl: process.env.SUPABASE_URL || '',
  supabaseAnonKey: process.env.SUPABASE_ANON_KEY || '',
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  storageBuckets: {
    lostPerson: process.env.SUPABASE_STORAGE_LOST_PERSON_BUCKET || 'lost-person-images',
    services: process.env.SUPABASE_STORAGE_SERVICE_BUCKET || 'service-images',
    profiles: process.env.SUPABASE_STORAGE_PROFILE_BUCKET || 'profile-images',
    publicUrlPrefix: process.env.SUPABASE_STORAGE_BUCKET_URL || '',
  },
};

export function validateEnv() {
  const missing = [];
  if (!config.supabaseUrl) missing.push('SUPABASE_URL');
  if (!config.supabaseServiceRoleKey) missing.push('SUPABASE_SERVICE_ROLE_KEY');

  if (missing.length > 0) {
    console.warn(`\n[WARNING] Missing environment variables: ${missing.join(', ')}`);
    console.warn('Please create backend/.env file from backend/.env.example template.\n');
  }
}
