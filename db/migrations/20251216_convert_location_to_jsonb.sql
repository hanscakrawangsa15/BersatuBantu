-- Migration: Convert `location` column to JSONB and populate with latitude/longitude
BEGIN;

-- If `location` column exists and is not jsonb, rename it to preserve raw values
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'donation_campaigns' AND column_name = 'location'
  ) THEN
    -- Only rename if type is not jsonb
    IF (SELECT data_type FROM information_schema.columns WHERE table_schema='public' AND table_name='donation_campaigns' AND column_name='location') <> 'json' THEN
      ALTER TABLE public.donation_campaigns RENAME COLUMN location TO location_old;
    END IF;
  END IF;
END$$;

-- Add new jsonb column `location` if missing
ALTER TABLE public.donation_campaigns
  ADD COLUMN IF NOT EXISTS location jsonb;

-- Populate `location` from latitude/longitude when available
UPDATE public.donation_campaigns
SET location = jsonb_build_object('lat', latitude, 'lng', longitude)
WHERE (latitude IS NOT NULL OR longitude IS NOT NULL) AND (location IS NULL OR location = 'null'::jsonb);

-- If we have an old `location_old` float8 column (single value), move it into lat
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='donation_campaigns' AND column_name='location_old') THEN
    -- Move non-null numeric values into lat
    UPDATE public.donation_campaigns
    SET location = jsonb_build_object('lat', location_old)
    WHERE location_old IS NOT NULL AND (location IS NULL OR location = 'null'::jsonb);
    -- Keep the old values for reference (optional)
    -- ALTER TABLE public.donation_campaigns DROP COLUMN location_old;
  END IF;
END$$;

COMMIT;
