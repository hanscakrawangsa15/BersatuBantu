# Midtrans Sample Server

This is a minimal Express server showing how to create Midtrans payment links (sandbox) using the **Server Key**. Use it only for testing or as a starting point for a secure backend.

Quick start:

1. Copy `.env.example` to `.env` and set `MIDTRANS_SERVER_KEY`.
   - Optional: set `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` to enable automatic updating of `donation_transactions` from Midtrans webhooks.
2. npm install
3. npm start
4. POST to `http://localhost:3000/create-midtrans-transaction` with JSON:

```json
{
  "order_id": "don-1234-1600000000000",
  "gross_amount": 500000,
  "payment_method": "OVO",
  "customer": { "first_name": "Hans", "email": "hans@example.com" },
  "item_details": [ { "id": "1", "name": "Donasi", "price": 500000, "quantity": 1 } ]
}
```

Response example:

```json
{
  "redirect_url": "https://app.sandbox.midtrans.com/payment-links/....",
  "raw": { /* entire Midtrans response */ }
}
```

Notes:
- Do not store Midtrans Server Key in the client app. Keep it on a secure server.
- You should implement proper validation, logging, retries, and webhook handling in production.

Admin helper endpoint
---------------------
This server includes a helper endpoint to create/upsert a `profiles` row using the Supabase service role key:

- POST `/admin/create-profile` with JSON: `{ id, full_name, email }` and header `x-admin-key: <ADMIN_PROFILE_KEY>`
- Configure `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` and `ADMIN_PROFILE_KEY` in `.env` before enabling this endpoint in production.

Use this endpoint only as a controlled fallback (for example, when DB trigger didn't create the profile during signup) and keep `ADMIN_PROFILE_KEY` secret.
