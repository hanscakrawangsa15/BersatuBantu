# Admin Dashboard: Troubleshooting Guide

## Current Issue: Dashboard Showing "N/A" for All Organization Data

Your screenshot shows:
- **Organisasi 1X** (should be from `nama_organisasi`)
- **Abdul A** (should be from `nama_pemilik`)
- **1x@gmail.com** (should be from `email_organisasi`)
- **+62121231313** (should be from `no_telpon_organisasi`)

But currently showing **"N/A"** for all fields.

---

## Root Cause Analysis Checklist

### ✅ Step 1: Verify Database Schema
The table name and fields are:
```
Table: organization_request
Fields:
- request_id (SERIAL, PRIMARY KEY)
- nama_organisasi (VARCHAR, NOT NULL)
- nama_pemilik (VARCHAR, NOT NULL)
- email_organisasi (VARCHAR, NOT NULL, UNIQUE)
- email_pemilik (VARCHAR, NOT NULL)
- password_organisasi (VARCHAR, NOT NULL)
- no_telpon_pemilik (VARCHAR)
- no_telpon_organisasi (VARCHAR)
- akta_berkas (VARCHAR)
- npwp_berkas (VARCHAR)
- other_berkas (VARCHAR)
- status (ENUM: pending, approve, reject)
- tanggal_request (TIMESTAMP)
```

**Action**: Go to Supabase console → Table Editor → organization_request → Verify field names

### ✅ Step 2: Check if Data Exists
```sql
-- Run in Supabase SQL Editor
SELECT * FROM organization_request 
ORDER BY tanggal_request DESC 
LIMIT 5;

-- Check specific pending records
SELECT * FROM organization_request 
WHERE status = 'pending' 
LIMIT 5;
```

**Expected**: You should see rows with actual data

### ✅ Step 3: Verify Admin Can Read Data (RLS Check)
```sql
-- In Supabase SQL Editor with admin role
SELECT nama_organisasi, nama_pemilik, email_organisasi, no_telpon_organisasi 
FROM organization_request 
WHERE status = 'pending' 
LIMIT 1;
```

**Expected**: Should return data, not permission denied error

### ✅ Step 4: Run Diagnostic Tests

#### Test 4a: Simple Diagnostic
Add this to your main.dart temporarily:
```dart
import 'package:bersatubantu/services/diagnostic_org_request.dart';

void main() async {
  // ... existing initialization ...
  
  // Run diagnostic after app init
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await testOrganizationRequestTable();
  });
}
```

Then check **Flutter Console** for output like:
```
[Test 1] ✅ Total records: 3
[Test 1] First record: {request_id: 1, nama_organisasi: 'Organisasi 1X', ...}
[Test 2] ✅ Pending records: 3
[Test 3] nama_organisasi: Organisasi 1X
```

#### Test 4b: Use Diagnostic Screen
1. Add route to diagnostic screen in your routing
2. Navigate to it
3. Click "Run Diagnostic"
4. Check output for what data is actually returned

### ✅ Step 5: Check Admin Dashboard Code

The code should match this pattern:
```dart
// Correct field access in _buildVerificationCard
Text(verification['nama_organisasi'] ?? 'N/A'),      // ✅ Correct
Text(verification['nama_pemilik'] ?? 'N/A'),         // ✅ Correct
Text(verification['email_organisasi'] ?? 'N/A'),     // ✅ Correct
Text(verification['no_telpon_organisasi'] ?? 'N/A'), // ✅ Correct
```

NOT:
```dart
// ❌ Wrong field names
Text(verification['org_legal_name'] ?? 'N/A'),
Text(verification['owner_name'] ?? 'N/A'),
Text(verification['email'] ?? 'N/A'),
Text(verification['phone'] ?? 'N/A'),
```

**Action**: Verify all field names in admin_dashboard_screen.dart line 395-420

---

## Diagnostic Script Output Interpretation

### Example Good Output:
```
========== DIAGNOSTIC: ORGANIZATION_REQUEST TABLE ==========

[Test 1] ✅ Total records: 3
[Test 1] First record: {
  request_id: 1,
  nama_organisasi: Organisasi 1X,
  nama_pemilik: Abdul A,
  email_organisasi: 1x@gmail.com,
  ...
}

[Test 2] ✅ Pending records: 3

[Test 3] Checking field values in first record...
[Test 3] nama_organisasi: Organisasi 1X
[Test 3] nama_pemilik: Abdul A
[Test 3] email_organisasi: 1x@gmail.com
[Test 3] no_telpon_organisasi: +62121231313
```

✅ **What this means**: Database has data, fields are correct

### Example Bad Output #1: Empty Table
```
[Test 1] ✅ Total records: 0
[Test 1] ⚠️ No records found
```

❌ **What this means**: No data in organization_request table yet. Register an organization first.

### Example Bad Output #2: RLS Blocking
```
[Test 4] ❌ RLS is blocking: PostgrestException(message: 'new row violates row-level security policy')
```

❌ **What this means**: Row-Level Security policies are preventing admin from reading. Check Supabase RLS settings.

### Example Bad Output #3: Null Values
```
[Test 3] nama_organisasi: null
[Test 3] nama_pemilik: null
[Test 3] email_organisasi: null
```

❌ **What this means**: Data exists but fields are null. Check verification_provider to ensure it's saving correct field names.

---

## Common Issues & Solutions

| Issue | Cause | Fix |
|-------|-------|-----|
| **"N/A" displayed** | Database query returns null/empty values | Run diagnostic to check what's returned |
| **Empty list** | No pending records in table | Register a new organization first |
| **Permission error** | RLS policy blocking admin access | Check RLS policies in Supabase |
| **Wrong field names** | Code accessing wrong fields | Verify field names match schema |
| **Null values** | Data not being saved correctly | Check verification_provider insert logic |

---

## Step-by-Step Troubleshooting

### 1. First Verify Data Exists
```bash
# In Supabase SQL Editor
SELECT COUNT(*) FROM organization_request;
```
Expected: `count: 3` (or whatever you registered)

### 2. Check Field Values
```bash
SELECT nama_organisasi, email_organisasi FROM organization_request LIMIT 1;
```
Expected: Actual organization name and email

### 3. Check Admin Query
```bash
SELECT * FROM organization_request WHERE status = 'pending' LIMIT 1;
```
Expected: Full record with all data

### 4. Run Console Diagnostic
Add logging and check Flutter console output

### 5. Verify Code Field Names
Open admin_dashboard_screen.dart and search for these patterns:
- `verification['nama_organisasi']` ✅ Correct
- `verification['org_legal_name']` ❌ Wrong
- `verification['owner_name']` ❌ Wrong

### 6. Check Compilation
```bash
dart analyze lib/fitur/auth/login/admin_dashboard_screen.dart
```
Should have no errors (only info/warnings)

---

## Debug Logging Added to Code

The admin_dashboard_screen.dart now logs:
```
[AdminDashboard] ========== FETCH PENDING VERIFICATIONS ==========
[AdminDashboard] Query response length: 3
[AdminDashboard] ========== RECORD 0 ==========
[AdminDashboard] All fields: {request_id: 1, nama_organisasi: ...}
[AdminDashboard] nama_organisasi: Organisasi 1X
[AdminDashboard] Building card 0: nama_organisasi=Organisasi 1X
```

**Where to see logs**:
- Android Studio: logcat
- VS Code: Debug Console
- Flutter CLI: Terminal output

---

## Next Steps

1. **Run the diagnostic** from the code to identify exact issue
2. **Check database directly** via Supabase SQL Editor
3. **Verify RLS policies** allow admin to read organization_request
4. **Ensure field names** match exactly in code
5. **Verify data insertion** is using correct table and fields

## Files to Reference

- Database Schema: `CHANGES_SUMMARY.md`
- Diagnostic Tool: `lib/services/diagnostic_org_request.dart`
- Diagnostic Screen: `lib/fitur/verifikasi_organisasi/screens/diagnostic_screen.dart`
- Admin Dashboard: `lib/fitur/auth/login/admin_dashboard_screen.dart` (lines 395-420)

