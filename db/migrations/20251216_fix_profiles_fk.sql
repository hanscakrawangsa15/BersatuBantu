-- Fix profiles foreign key to reference auth.users(id)
-- Some projects mistakenly reference a `users` table; ensure the FK points at auth.users

ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users (id) ON DELETE CASCADE;

-- Run with:
-- supabase db query < 20251216_fix_profiles_fk.sql
