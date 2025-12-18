/* Minimal Express server to create Midtrans payment-links
   - Configure MIDTRANS_SERVER_KEY in .env
   - POST /create-midtrans-transaction with JSON: { order_id, gross_amount, payment_method, customer:{first_name,email}, item_details }
   - Returns: { redirect_url, raw } where redirect_url is the Midtrans payment link URL
*/

import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import fetch from 'node-fetch';

dotenv.config();
const app = express();
app.use(express.json());

// CORS setup (allow local dev origins by default)
const allowed = (process.env.CORS_ALLOWED_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean);
if (allowed.length) {
    app.use(cors({ origin: allowed }));
} else {
    app.use(cors());
}

const MIDTRANS_SERVER_KEY = process.env.MIDTRANS_SERVER_KEY;
if (!MIDTRANS_SERVER_KEY) {
    console.warn('Warning: MIDTRANS_SERVER_KEY not set. The server will respond with 500 for create requests.');
}

app.post('/create-midtrans-transaction', async (req, res) => {
    if (!MIDTRANS_SERVER_KEY) return res.status(500).json({ error: 'MIDTRANS_SERVER_KEY not configured' });

    const { order_id, gross_amount, payment_method, customer, item_details } = req.body;

    try {
        // Build a minimal body for Midtrans Payment Links API.
        // Adjust fields according to Midtrans docs for full production usage.
        const body = {
            external_id: order_id || `don-${Date.now()}`,
            amount: gross_amount || 0,
            description: item_details && item_details[0] && item_details[0].name ? `Donasi: ${item_details[0].name}` : 'Donasi',
            // optional: help Midtrans show customer info
            customer_name: customer?.first_name || undefined,
            customer_email: customer?.email || undefined,
            // you may include enabled_payments or other options here
        };

        const endpoint = 'https://api.sandbox.midtrans.com/v2/payment-links';
        const auth = 'Basic ' + Buffer.from(MIDTRANS_SERVER_KEY + ':').toString('base64');

        const resp = await fetch(endpoint, {
            method: 'POST',
            body: JSON.stringify(body),
            headers: {
                'Content-Type': 'application/json',
                'Authorization': auth,
            },
        });

        const data = await resp.json();

        if (!resp.ok) {
            return res.status(resp.status).json({ error: 'Midtrans error', details: data });
        }

        // Try to find common URL fields in Midtrans response
        const redirectUrl = data.url || data.payment_link_url || data.redirect_url || data.payment_url || data.invoice_url || null;

        return res.json({ redirect_url: redirectUrl, raw: data });
    } catch (err) {
        console.error('Error creating Midtrans payment link:', err);
        return res.status(500).json({ error: err?.toString() || 'unknown error' });
    }
});

// Webhook endpoint for Midtrans to notify payment updates (e.g., settlement).
// Configure the webhook URL in Midtrans dashboard to point to: /midtrans-webhook
// If you set SUPABASE_URL and SUPABASE_SERVICE_KEY in .env, this endpoint will try to update
// `donation_transactions.status` where `midtrans_order_id` matches the Midtrans id received.
app.post('/midtrans-webhook', async (req, res) => {
    const payload = req.body;
    console.log('Midtrans webhook received:', JSON.stringify(payload));

    // Try to detect common identifiers and status fields
    const midtransId = payload.id || payload.order_id || payload.external_id || (payload.payment_link && payload.payment_link.id) || null;
    const status = payload.transaction_status || payload.status || payload.payment_status || payload.status_code || null;

    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

    if (SUPABASE_URL && SUPABASE_SERVICE_KEY && midtransId && status) {
        try {
            // Fetch matching transaction(s)
            const selectEndpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/donation_transactions?midtrans_order_id=eq.${encodeURIComponent(midtransId)}&select=id,amount,campaign_id,status`;
            const selectResp = await fetch(selectEndpoint, {
                method: 'GET',
                headers: {
                    'apikey': SUPABASE_SERVICE_KEY,
                    'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                },
            });
            const txRows = await selectResp.json();
            console.log('Found transactions for midtrans id:', txRows);

            // Determine if this is a settlement-like status
            const settledStatuses = ['settlement', 'paid', 'capture', 'completed'];
            const isSettled = settledStatuses.includes(String(status).toLowerCase());

            if (Array.isArray(txRows) && txRows.length > 0) {
                for (const tx of txRows) {
                    try {
                        // Idempotency: only apply if not already settled
                        if (String(tx.status).toLowerCase() === 'settlement') {
                            console.log('Transaction already settled, skipping increment:', tx.id);
                            continue;
                        }

                        // If webhook indicates settlement, update transaction and increment campaign collected amount
                        if (isSettled) {
                            // Update transaction status to settlement
                            const updateTxEndpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/donation_transactions?id=eq.${encodeURIComponent(tx.id)}`;
                            await fetch(updateTxEndpoint, {
                                method: 'PATCH',
                                headers: {
                                    'apikey': SUPABASE_SERVICE_KEY,
                                    'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                                    'Content-Type': 'application/json',
                                    'Prefer': 'return=representation'
                                },
                                body: JSON.stringify({ status: 'settlement', updated_at: new Date().toISOString() })
                            });

                            // Increment campaign collected_amount (read-modify-write)
                            if (tx.campaign_id) {
                                const campEndpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/donation_campaigns?id=eq.${encodeURIComponent(tx.campaign_id)}&select=collected_amount`;
                                const campResp = await fetch(campEndpoint, {
                                    method: 'GET',
                                    headers: {
                                        'apikey': SUPABASE_SERVICE_KEY,
                                        'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                                    },
                                });
                                const campData = await campResp.json();
                                const current = (Array.isArray(campData) && campData[0] && campData[0].collected_amount) ? Number(campData[0].collected_amount) : 0;
                                const newTotal = current + (Number(tx.amount) || 0);

                                // Update campaign
                                const updateCampEndpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/donation_campaigns?id=eq.${encodeURIComponent(tx.campaign_id)}`;
                                await fetch(updateCampEndpoint, {
                                    method: 'PATCH',
                                    headers: {
                                        'apikey': SUPABASE_SERVICE_KEY,
                                        'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                                        'Content-Type': 'application/json',
                                        'Prefer': 'return=representation'
                                    },
                                    body: JSON.stringify({ collected_amount: newTotal })
                                });

                                console.log(`Incremented campaign ${tx.campaign_id} by ${tx.amount}. New total: ${newTotal}`);
                            }
                        } else {
                            // Not a settlement-type status; still update transaction status field
                            const updateTxEndpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/donation_transactions?id=eq.${encodeURIComponent(tx.id)}`;
                            await fetch(updateTxEndpoint, {
                                method: 'PATCH',
                                headers: {
                                    'apikey': SUPABASE_SERVICE_KEY,
                                    'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                                    'Content-Type': 'application/json',
                                    'Prefer': 'return=representation'
                                },
                                body: JSON.stringify({ status: status })
                            });
                        }
                    } catch (err) {
                        console.error('Error handling tx row:', tx, err);
                    }
                }
            } else {
                console.log('No matching donation_transactions found for midtrans id:', midtransId);
            }
        } catch (err) {
            console.error('Error updating Supabase from webhook:', err);
        }
    } else {
        console.log('Supabase update skipped (missing SUPABASE_URL/SERVICE_KEY or missing midtransId/status)');
    }

    // Return 200 quickly — Midtrans expects a 2xx response.
    return res.status(200).json({ ok: true });
});

// Admin helper: create or upsert a profile using the Supabase service role key.
// Secured by an ADMIN_PROFILE_KEY env var which must be provided in the
// `x-admin-key` header. This endpoint is useful as a fallback when client
// registration attempts fail due to race conditions or missing DB triggers.
app.post('/admin/create-profile', async (req, res) => {
    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;
    const ADMIN_PROFILE_KEY = process.env.ADMIN_PROFILE_KEY;

    if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
        return res.status(500).json({ error: 'Supabase service not configured on server' });
    }

    const adminKey = req.header('x-admin-key');
    if (!ADMIN_PROFILE_KEY || adminKey !== ADMIN_PROFILE_KEY) {
        return res.status(401).json({ error: 'Unauthorized' });
    }

    const { id, full_name, email } = req.body || {};
    if (!id || !email) return res.status(400).json({ error: 'Missing required fields: id, email' });

    try {
        const endpoint = `${SUPABASE_URL.replace(/\/$/, '')}/rest/v1/profiles`;
        const body = [{ id, full_name: full_name || null, email }];

        const resp = await fetch(endpoint + '?prefer=return=representation', {
            method: 'POST',
            headers: {
                'apikey': SUPABASE_SERVICE_KEY,
                'Authorization': 'Bearer ' + SUPABASE_SERVICE_KEY,
                'Content-Type': 'application/json',
                'Prefer': 'resolution=merge-duplicates'
            },
            body: JSON.stringify(body),
        });

        const data = await resp.json();
        if (!resp.ok) {
            console.error('Create-profile failed:', resp.status, data);
            return res.status(resp.status).json({ error: 'Supabase request failed', details: data });
        }

        return res.json({ ok: true, inserted: data });
    } catch (err) {
        console.error('Error in /admin/create-profile:', err);
        return res.status(500).json({ error: err?.toString() || 'unknown error' });
    }
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Midtrans sample server listening on http://localhost:${port}`);
});
