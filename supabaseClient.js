// Fill these in from Supabase: Project Settings -> API
const SUPABASE_URL = 'https://mxlgtvesbdtbzlwodpkm.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14bGd0dmVzYmR0Ynpsd29kcGttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ2MDQ1NTEsImV4cCI6MjEwMDE4MDU1MX0.VT3krJX7Mcb3AqZTcKaI-lMlbSiS1fERN8IB-H6_rns';

// The UMD build (loaded before this file) exposes a global `window.supabase`
// with `createClient`. Use a distinct local name to avoid a TDZ collision.
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Expose the client for classic (non-module) scripts.
window.supabase = supabaseClient;
