import { createClient } from "@supabase/supabase-js";

// You should put these in your .env file
// VITE_SUPABASE_URL=...
// VITE_SUPABASE_ANON_KEY=...

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "YOUR_SUPABASE_URL";
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "YOUR_SUPABASE_ANON_KEY";

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
