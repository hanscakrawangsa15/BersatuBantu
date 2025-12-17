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
