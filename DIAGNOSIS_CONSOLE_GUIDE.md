# Dashboard "N/A" Issue - Complete Diagnosis Guide

## Problem Summary
Admin dashboard shows 6 organizations (Organisasi 1X, 1A, 1B, 1C, 1D, 1E) with card titles displaying correctly, but all detail fields show "N/A" despite data being saved in the database.

## Root Cause Analysis

Given that:
- ✅ Organizations appear in the list (meaning `SELECT` works)
- ✅ Organization names show in titles (meaning `nama_organisasi` field works)  
- ❌ But ALL other fields show "N/A" (meaning those fields are NULL/missing)

**Hypothesis**: The other fields (`nama_pemilik`, `email_organisasi`, `no_telpon_organisasi`) are either:
1. Not being saved (NULL in database)
2. Not returned by the query (RLS blocking or field selection issue)
3. Being saved as empty strings (form collection issue)

## To Diagnose - Run These Commands

### Terminal Option 1: Using Flutter DevTools (Easiest)

```powershell
cd "d:\Kuliah\Semester 5\TekBer\FP\BersatuBantu"
flutter run
```

When the app opens:
1. **Wait for startup console to print diagnostics** (look for `[TEST 1]`, `[TEST 2]`, etc.)
2. **Navigate to Admin Dashboard**
3. **Open DevTools in your browser** (flutter run will show URL)
4. **Go to Logging tab** and search for:
   - `[TEST]` - startup diagnostics
   - `[AdminDashboard]` - dashboard rendering logs

### Terminal Option 2: Using VSCode Debug Console

1. Open `lib/fitur/auth/login/admin_dashboard_screen.dart`
2. Click **Run** → **Run with Debug** or press `F5`
3. VSCode will open a Debug Console at the bottom
4. Navigate to admin dashboard in the app
5. Look for the logs in the **Debug Console** tab

## What to Look For In Console Output

### Section 1: Database Query Test (Startup)
```
========== DATABASE QUERY TEST START ==========

[TEST 1] Querying organization_request table...
[TEST 1] Total records: X

[TEST 2] Querying pending records (status=pending)...
[TEST 2] Pending records count: 6

[TEST 3] Detailed analysis of first PENDING record:
[TEST 3] >>>>>> FULL RECORD JSON <<<<<<
{...json content...}

[TEST 3] Field-by-field breakdown:
[TEST 3]   "nama_organisasi": "Organisasi 1X" (type: String, isNull: false, isEmpty: false)
[TEST 3]   "nama_pemilik": ??? (THIS IS WHAT WE'RE LOOKING FOR)
[TEST 3]   "email_organisasi": ??? (THIS IS WHAT WE'RE LOOKING FOR)
[TEST 3]   "no_telpon_organisasi": ??? (THIS IS WHAT WE'RE LOOKING FOR)

[TEST 3] Expected fields check:
[TEST 3]   nama_pemilik exists: true/false ⬅️ CRITICAL
[TEST 3]   email_organisasi exists: true/false ⬅️ CRITICAL
[TEST 3]   no_telpon_organisasi exists: true/false ⬅️ CRITICAL
```

### Section 2: Dashboard Rendering (When viewing dashboard)
```
[AdminDashboard] ========== CARD 0 ==========
[AdminDashboard] All keys in record: [...]
[AdminDashboard] Full record: {...}
[AdminDashboard] nama_organisasi=Organisasi 1X
[AdminDashboard] nama_pemilik=??? (Shows this value or null)
[AdminDashboard] email_organisasi=??? (Shows this value or null)
[AdminDashboard] no_telpon_organisasi=??? (Shows this value or null)
```

## Diagnosis Decision Tree

### IF you see in console:
```
[TEST 3]   "nama_pemilik": "Abdul Aziz" (type: String, isNull: false)
[TEST 3]   "email_organisasi": "abdul@email.com" (type: String, isNull: false)
```
→ **DATA IS IN DATABASE** ✅
→ Problem is somewhere else (probably field name mismatch or RLS)

### ELSE IF you see:
```
[TEST 3]   "nama_pemilik": "NULL" (type: Null, isNull: true)
[TEST 3]   "email_organisasi": "NULL" (type: Null, isNull: true)
```
→ **DATA NOT SAVED** ❌  
→ Problem is in verification_provider insert logic
→ Form fields were probably empty

### ELSE IF you see:
```
[TEST 3]   nama_pemilik exists: false
[TEST 3]   email_organisasi exists: false
```
→ **FIELDS MISSING FROM RESPONSE** ❌
→ RLS policy blocking or Supabase configuration issue

### ELSE IF you see:
```
[TEST 3]   "nama_pemilik": "" (type: String, isNull: false, isEmpty: true)
[TEST 3]   "email_organisasi": "" (type: String, isNull: false, isEmpty: true)
```
→ **FIELDS SAVED AS EMPTY** ⚠️
→ Form data collection issue (fields not filled out)

## Files Modified for Debugging

1. **lib/main.dart**
   - Added import for test_dashboard_debug
   - Added `await testDashboardQuery();` after Supabase init (line 33)

2. **lib/test_dashboard_debug.dart** (NEW)
   - Contains `testDashboardQuery()` function
   - Runs on app startup
   - Logs all database details to console

3. **lib/fitur/auth/login/admin_dashboard_screen.dart**
   - Enhanced ListView.builder (lines 354-360) with detailed logging
   - Logs when building each card with all field values

## Expected Output Example (If working correctly)

```
========== DATABASE QUERY TEST START ==========

[TEST 1] Querying organization_request table...
[TEST 1] Total records: 12

[TEST 2] Querying pending records (status=pending)...
[TEST 2] Pending records count: 6

[TEST 3] Detailed analysis of first PENDING record:
[TEST 3] >>>>>> FULL RECORD JSON <<<<<<
{request_id: 1, nama_organisasi: Organisasi 1X, nama_pemilik: Abdul Aziz, email_organisasi: org1x@email.com, no_telpon_organisasi: +62121231313, password_organisasi: $2b$..., status: pending, ...}

[TEST 3] Field-by-field breakdown:
[TEST 3]   "request_id": "1" (type: int, isNull: false)
[TEST 3]   "nama_organisasi": "Organisasi 1X" (type: String, isNull: false, isEmpty: false)
[TEST 3]   "nama_pemilik": "Abdul Aziz" (type: String, isNull: false, isEmpty: false)
[TEST 3]   "email_organisasi": "org1x@email.com" (type: String, isNull: false, isEmpty: false)
[TEST 3]   "no_telpon_organisasi": "+62121231313" (type: String, isNull: false, isEmpty: false)
[TEST 3]   "password_organisasi": "$2b$12$..." (type: String, isNull: false, isEmpty: false)
[TEST 3]   "status": "pending" (type: String, isNull: false, isEmpty: false)

========== DATABASE QUERY TEST COMPLETE ==========
```

## Next Steps

1. **Run the app** using `flutter run`
2. **Take screenshot of console output** (especially TEST 3 section)
3. **Share the console output** with me
4. Based on what I see, I'll identify the exact issue and implement the fix

## Important Notes

- The startup test runs BEFORE you navigate to dashboard (that's why it's in main.dart)
- The dashboard test runs EVERY TIME the dashboard renders (so check logs when viewing dashboard)
- Both are essential - startup test shows raw database data, dashboard test shows what the UI sees
- Console logs will scroll fast, but all output should be captured if you open DevTools

## Quick Reference: Console Search Terms
- Look for: `[TEST` - Database query results
- Look for: `[AdminDashboard]` - Dashboard rendering
- Look for: `exists: false` - Missing fields (RLS issue)
- Look for: `isNull: true` - NULL values (data not saved)
- Look for: `isEmpty: true` - Empty strings (form empty)
