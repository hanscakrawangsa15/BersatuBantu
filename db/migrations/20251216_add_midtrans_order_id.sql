-- Add midtrans_order_id column to donation_transactions for mapping Midtrans payment links
ALTER TABLE public.donation_transactions
  ADD COLUMN IF NOT EXISTS midtrans_order_id text;

CREATE INDEX IF NOT EXISTS idx_donation_transactions_midtrans_order_id ON public.donation_transactions (midtrans_order_id);

-- Run with:
-- supabase db query < 20251216_add_midtrans_order_id.sql
