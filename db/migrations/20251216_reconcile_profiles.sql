-- Create reconcilation function to create profile rows for auth.users without profiles
-- Use this to fix up existing users that do not have a profile row yet.

CREATE OR REPLACE FUNCTION public.reconcile_profiles_create_missing() RETURNS void AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role, created_at)
  SELECT u.id, NULL, u.email, NULL, now()
  FROM auth.users u
  LEFT JOIN public.profiles p ON p.id = u.id
  WHERE p.id IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute to anon if you want to allow calling via PostgREST/RPC, or call with service role
-- GRANT EXECUTE ON FUNCTION public.reconcile_profiles_create_missing() TO anon;

-- Run with:
-- supabase db query < 20251216_reconcile_profiles.sql
