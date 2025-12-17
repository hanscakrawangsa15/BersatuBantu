# Midtrans Integration (Client + Server)

⚠️ Short summary: For security, **do not** use Midtrans Server Key in the mobile app. Create a small backend endpoint that calls Midtrans (using the **Server Key**) to create a transaction and returns the payment URL (or redirect token) to the app. The mobile app will call this endpoint and open the returned payment URL.

## What to add to `.env`

- MIDTRANS_CREATE_TRANSACTION_URL=https://your-backend.example.com/create-midtrans-transaction  # Should point to *your* backend endpoint that creates transactions (DO NOT point to a static Midtrans payment-link if you want the link to be generated based on the donor's entered amount)
- (optional) MIDTRANS_CLIENT_KEY=YOUR_CLIENT_KEY  # only if you plan to use client-side Snap JS in webview

## Client-side (already implemented)

We added client logic in `lib/fitur/berikandonasi/berikandonasi.dart`:
- Calls your backend endpoint `MIDTRANS_CREATE_TRANSACTION_URL` (POST JSON) with: `order_id`, `gross_amount`, `payment_method`, `customer`, `item_details`.
- On success, backend must return JSON containing a `redirect_url` (or `payment_url`) to open in browser/webview.
- The client then inserts a `donation_transactions` row with status `pending` and **does not** update the campaign `collected_amount`. The client stores `midtrans_order_id` (payment link id) so your webhook can map notifications to the row. Final update should be performed only after Midtrans confirms settlement via webhook.

## Example backend (Node.js + Express)

This repo includes a minimal example server at `server/` (copy `.env.example` to `.env`, set `MIDTRANS_SERVER_KEY`, then `npm install` and `npm start`). Use `process.env.MIDTRANS_SERVER_KEY` securely. This example creates a Midtrans Payment Link and returns a `redirect_url` to the client.

This is a minimal example (use `process.env.MIDTRANS_SERVER_KEY` securely):

```js
const express = require('express');
const fetch = require('node-fetch');
const app = express();
app.use(express.json());

app.post('/create-midtrans-transaction', async (req, res) => {
  const serverKey = process.env.MIDTRANS_SERVER_KEY;
  if (!serverKey) return res.status(500).json({ error: 'Server key not configured' });

  const { order_id, gross_amount, payment_method, customer, item_details } = req.body;

  // Map payment_method if you want, e.g. 'OVO' -> 'ovo', 'GoPay' -> 'gopay', 'ShopeePay' -> 'shopeepay'
  // Choose the correct Midtrans API shape for the payment type.
  const body = {
    payment_type: payment_method.toLowerCase(), // you might need to override this
    transaction_details: { order_id, gross_amount },
    customer_details: customer,
    item_details,
  };

  try {
    const resp = await fetch('https://api.sandbox.midtrans.com/v2/charge', {
      method: 'POST',
      headers: {
        Authorization: 'Basic ' + Buffer.from(serverKey + ':').toString('base64'),
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await resp.json();

    // Depending on payment type, Midtrans returns different properties.
    // For web redirect flows you may get `redirect_url` or similar in response.
    // Forward the useful data to the mobile client.
    return res.json(data);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'failed to contact Midtrans' });
  }
});

app.listen(3000);
```

Notes:
- Use Midtrans Sandbox while testing.
- Use the correct endpoint (`/v2/charge` vs `/v2/transactions`) and `payment_type` payload according to the Midtrans API for the specific payment method.
- Implement a secure webhook endpoint that Midtrans will call to notify settlement/charged events. The webhook should update: `donation_transactions.status` to `settlement` and increment `donation_campaigns.collected_amount` accordingly.

Server sample notes:
- This repo's sample server exposes `/midtrans-webhook` and will attempt to update the corresponding `donation_transactions` row when `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` are set in the server `.env` (it matches by `midtrans_order_id`).
- Configure the Webhook URL in Midtrans dashboard to point to `https://<your-server>/midtrans-webhook` (or the public URL of your deployed server). Validate the webhook signature in production for security.

## Next steps / checklist

- ✅ Add `MIDTRANS_CREATE_TRANSACTION_URL` to `.env`.
- ✅ Deploy a secure backend endpoint that uses the **Server Key** to create Midtrans transactions and handles webhooks.
- ✅ Use Midtrans dashboard to configure webhooks and testing.
- ✅ Consider using Midtrans native SDKs for better mobile UX (optional).

If you want, I can:
- Create a sample serverless function (Edge function or small express app) in this repo with webhook handling and migration to add a `midtrans_order_id` field to `donation_transactions`.
- Integrate an in-app WebView flow instead of opening an external browser.

Let me know which next step you'd like me to implement. ✅