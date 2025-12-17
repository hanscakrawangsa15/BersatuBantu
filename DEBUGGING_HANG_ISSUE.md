# Debugging: App Hangs When Clicking "Selanjutnya" After Document Upload

## Problem Summary
User uploads 3 documents (all show green checkmarks) then clicks "Selanjutnya" button. Button shows "Mengirim..." but app freezes/hangs without completing or showing error message.

## Root Causes Fixed

### 1. **Missing Error Feedback** ✅
**Problem**: No error message shown to user if `submitVerification()` fails
**Solution**: Added try-catch with SnackBar to display errors

**File**: [documents_upload_screen.dart](documents_upload_screen.dart#L141-L173)
- Added error handling for failed submissions
- Display `lastMessage` from provider in red SnackBar
- Show exception message if unexpected error occurs

### 2. **No Timeout on Database Insert** ✅
**Problem**: If database doesn't respond, app hangs indefinitely
**Solution**: Added 30-second timeout to Supabase insert operation

**File**: [verification_provider.dart](verification_provider.dart#L161-L170)
- Wrapped `.insert()` with `.timeout(Duration(seconds: 30))`
- Throws `TimeoutException` if no response after 30s
- Caught by exception handler, sets error message for user

### 3. **isLoading Not Reset in All Paths** ✅
**Problem**: `isLoading` flag could stay true if exception occurs
**Solution**: Ensured `isLoading = false` in all exception handlers

**File**: [verification_provider.dart](verification_provider.dart#L173-L224)
- PostgrestException handler resets `isLoading`
- TimeoutException handler resets `isLoading`
- Generic exception handler resets `isLoading`
- All paths call `notifyListeners()` to update UI

### 4. **Removed Anonymous User Check** ✅
**Problem**: Hard requirement for `userId` prevented anonymous registration
**Solution**: Removed user ID requirement, made `profil_pemilik_id` optional

**File**: [verification_provider.dart](verification_provider.dart#L95-L130)
- Allows `userId == null` (anonymous registration)
- Only includes `profil_pemilik_id` in insert if user is authenticated
- All required fields still populated

## What Gets Logged Now

When user clicks "Selanjutnya", console will show:

```
[Verification] ========== START SUBMIT VERIFICATION ==========
[Verification] Akta URL: <file_url>
[Verification] NPWP URL: <file_url>
[Verification] Other URL: <file_url>
[Verification] Hashing password...
[Verification] ✅ Password hashed successfully
[Verification] ========== INSERTING TO ORGANIZATION_REQUEST ==========
[Verification] Data to insert: {nama_organisasi: Org Name, nama_pemilik: Owner Name, ...}
[Verification] Insert payload: {nama_organisasi: Org Name, ...}
[Verification] Starting insert with 30s timeout...
[Verification] Insert response: [{'request_id': 123}]
[Verification] Request ID stored: 123
[Verification] ========== SUBMIT VERIFICATION SUCCESS ==========
```

Or if error:

```
[Verification] ❌ PostgrestException: Permission denied
[Verification] Error code: 42501
[Verification] 🔒 RLS POLICY BLOCKING INSERT
```

Or if timeout:

```
[Verification] Starting insert with 30s timeout...
[Verification] ❌ INSERT TIMEOUT after 30 seconds
```

## User Feedback

### On Success:
- Button shows "Mengirim..." while loading
- Transitions to Step 3 (verification polling)

### On Error:
- Red SnackBar appears with error message:
  - "Email organisasi sudah terdaftar." (email duplicate)
  - "Data tidak lengkap. Pastikan semua field diisi." (missing field)
  - "Akses ditolak. Hubungi admin untuk permission." (RLS policy issue)
  - "Koneksi timeout. Pastikan internet stabil dan coba lagi." (timeout)
  - Or other error message

## Testing Instructions

1. **Fill all form fields** (Steps 0-1):
   - Owner name, email, phone
   - Organization name, email, phone, password

2. **Upload documents** (Step 2):
   - Akta Pendirian (green checkmark)
   - NPWP (green checkmark)
   - Surat Domisili (green checkmark)

3. **Click "Selanjutnya"**:
   - Watch console for logs
   - Should either:
     - Progress to Step 3 (polling)
     - Show error message at bottom of screen

4. **Check database**:
   - If successful, new row in `organization_request` table
   - Status should be 'pending'
   - Email should match submitted email

## Files Modified

1. [lib/fitur/verifikasi_organisasi/providers/verification_provider.dart](lib/fitur/verifikasi_organisasi/providers/verification_provider.dart)
   - Added `dart:async` import
   - Removed postgrest import (redundant)
   - Added timeout to insert operation
   - Fixed exception handlers to reset `isLoading`
   - Removed hard userId requirement

2. [lib/fitur/verifikasi_organisasi/screens/documents_upload_screen.dart](lib/fitur/verifikasi_organisasi/screens/documents_upload_screen.dart)
   - Added error handling with SnackBar
   - Display `lastMessage` on failure
   - Display exception on unexpected error

## Next Steps

1. Run app in debug mode
2. Navigate to organization registration
3. Fill all fields
4. Upload documents
5. Click "Selanjutnya"
6. Monitor console for logs
7. Check error messages or database insertion

## Database Verification

After successful submission, check Supabase:

```sql
-- Check if record was inserted
SELECT * FROM organization_request 
WHERE email_organisasi = 'your-test@email.com';

-- Check most recent records
SELECT request_id, nama_organisasi, email_organisasi, status, tanggal_request
FROM organization_request 
ORDER BY tanggal_request DESC 
LIMIT 10;

-- Check for permission errors (RLS)
-- Try inserting directly in SQL Editor to test RLS policies
INSERT INTO organization_request (
  nama_organisasi, nama_pemilik, email_organisasi, 
  email_pemilik, password_organisasi, 
  akta_berkas, npwp_berkas, other_berkas, 
  status
) VALUES (
  'Test Org', 'Test Owner', 'test@example.com',
  'owner@example.com', 'hashed_password_here',
  'akta_url', 'npwp_url', 'other_url',
  'pending'
);
```

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| App freezes, no error | Insert timeout or hang | Now shows "Koneksi timeout" error |
| "Email sudah terdaftar" | UNIQUE constraint violation | Try different email |
| "Akses ditolak" | RLS policy blocking insert | Check Supabase RLS policies |
| "Data tidak lengkap" | NULL constraint violation | Verify all fields filled |
| No row inserted | Previous 3 issues | Check console logs and error message |

