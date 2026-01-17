import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    throw new Error('Missing Supabase URL or Service Key in environment variables');
}

// CAUTION: This client uses the Service Role Key, which bypasses RLS.
// Use it only for admin tasks or when you explicitly need to bypass policies.
// For user-context operations, pass the user's JWT forward or strictly validate inputs.
export const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
