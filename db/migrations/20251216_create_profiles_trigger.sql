-- Create a trigger in the database to automatically create a profiles row
-- when a new auth user is created. This avoids race conditions between
-- Supabase Auth user creation and client attempts to insert into profiles.

-- Note: Run this using Supabase SQL editor or CLI with a service role (admin) user.

DO $$
BEGIN
  -- Only create function if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'handle_new_auth_user') THEN
    CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
    RETURNS trigger AS $$
    BEGIN
      -- Insert into public.profiles if not exists
      INSERT INTO public.profiles (id, full_name, email, role, created_at)
      VALUES (NEW.id, NULL, NEW.email, NULL, now())
      ON CONFLICT (id) DO NOTHING;
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
  END IF;
END$$;

-- Drop existing trigger if exists then create it on auth.users
DROP TRIGGER IF EXISTS trg_handle_new_auth_user ON auth.users;
CREATE TRIGGER trg_handle_new_auth_user
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();

-- Run with:
-- supabase db query < 20251216_create_profiles_trigger.sql
