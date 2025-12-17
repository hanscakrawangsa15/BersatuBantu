-- Migration: Add location_name, latitude, longitude and keep them in sync
BEGIN;

-- 1) Add columns if they don't exist
ALTER TABLE public.donation_campaigns
  ADD COLUMN IF NOT EXISTS location_name text;

ALTER TABLE public.donation_campaigns
  ADD COLUMN IF NOT EXISTS latitude double precision;

ALTER TABLE public.donation_campaigns
  ADD COLUMN IF NOT EXISTS longitude double precision;

-- 2) Copy existing `location` text into `location_name` for compatibility
UPDATE public.donation_campaigns
SET location_name = location
WHERE location_name IS NULL AND location IS NOT NULL;

-- 3) Try to parse latitude/longitude values from existing `location_name` if they follow the format
--    "Lat: <lat>, Lng: <lng>" (case-sensitive 'Lat' and 'Lng')
UPDATE public.donation_campaigns
SET
  latitude = (regexp_matches(location_name, 'Lat:\s*(-?[0-9]+(?:\\.[0-9]+)?)\s*,\s*Lng:\s*(-?[0-9]+(?:\\.[0-9]+)?)'))[1]::double precision,
  longitude = (regexp_matches(location_name, 'Lat:\s*(-?[0-9]+(?:\\.[0-9]+)?)\s*,\s*Lng:\s*(-?[0-9]+(?:\\.[0-9]+)?)'))[2]::double precision
WHERE location_name ~ 'Lat:';

-- 4) Create a trigger function that keeps `location_name` and (`latitude`, `longitude`) in sync.
--    Behavior:
--      - If lat/lng are provided, they will set/override `location_name` to "Lat: <lat>, Lng: <lng>" if `location_name` is empty
--      - Otherwise, if `location_name` is provided and contains coordinates in the above format, parse them into lat/lng
--    This runs BEFORE INSERT OR UPDATE so values are consistent on write.

CREATE OR REPLACE FUNCTION public.sync_location_columns()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  matches text[];
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- If lat/lng provided, prefer them and format `location_name` if empty
    IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
      IF NEW.location_name IS NULL OR NEW.location_name = '' THEN
        NEW.location_name := format('Lat: %s, Lng: %s', NEW.latitude::text, NEW.longitude::text);
      END IF;
    ELSIF NEW.location_name IS NOT NULL THEN
      -- try to parse coordinates from the textual location_name
      matches := regexp_matches(NEW.location_name, 'Lat:\s*(-?[0-9]+(?:\\.[0-9]+)?)\s*,\s*Lng:\s*(-?[0-9]+(?:\\.[0-9]+)?)');
      IF array_length(matches, 1) = 2 THEN
        NEW.latitude := matches[1]::double precision;
        NEW.longitude := matches[2]::double precision;
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

-- 5) Create trigger
DROP TRIGGER IF EXISTS trg_sync_location ON public.donation_campaigns;
CREATE TRIGGER trg_sync_location
BEFORE INSERT OR UPDATE ON public.donation_campaigns
FOR EACH ROW EXECUTE FUNCTION public.sync_location_columns();

COMMIT;
