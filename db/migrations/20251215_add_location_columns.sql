-- Add latitude, longitude, and location_name to donation_campaigns
ALTER TABLE public.donation_campaigns
  ADD COLUMN IF NOT EXISTS latitude double precision,
  ADD COLUMN IF NOT EXISTS longitude double precision,
  ADD COLUMN IF NOT EXISTS location_name text;

-- If you are using Supabase, run this SQL in the SQL editor or via the CLI:
-- supabase db query < 20251215_add_location_columns.sql
