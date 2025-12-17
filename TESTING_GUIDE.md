# Testing Guide: Admin Dashboard & Organization Approval Flow

## Prerequisites
- App is compiled and running
- Supabase is connected
- Database has `organization_request` table with correct schema

## Test Scenario: Complete Registration & Approval Flow

### Step 1: Organization Registration (Mobile App)
1. Open app → Role Selection → Select "Organisasi"
2. Fill form:
   - **Step 0 (Owner Info)**:
     - Nama Pemilik: "Budi Santoso"
     - Email Pemilik: "budi@example.com"
     - No. Telepon Pemilik: "081234567890"
   
   - **Step 1 (Organization Info)**:
     - Nama Organisasi: "Yayasan Maju Bersama"
     - Email Organisasi: "info@mayajursama.org"
     - No. Telepon Organisasi: "0213334455"
     - Password: "SecurePass123!"
   
   - **Step 2 (Document Upload)**:
     - Akta Pendirian: Upload file (will get URL)
     - NPWP: Upload file (will get URL)
     - Surat Keterangan: Upload file (will get URL)
     - Click "Selanjutnya"
   
   - **Step 3 (Waiting Verification)**:
     - See "Mohon tunggu persetujuan admin"
     - Status should poll every 3 seconds

3. **Expected Result**:
   - ✅ Form data saved to `organization_request` table
   - ✅ All 3 documents uploaded to storage
   - ✅ Status = "pending"
   - ✅ "Waiting Verification" screen displays

### Step 2: Admin Dashboard - View Pending Requests
1. Go to Admin Dashboard (hardcoded username/password)
2. You should see list of pending organizations

**Expected Data Display**:
- ✅ Nama Organisasi: "Yayasan Maju Bersama" (NOT "N/A")
- ✅ Nama Pemilik: "Budi Santoso" (NOT "N/A")
- ✅ Email: "info@mayajursama.org" (NOT "N/A")
- ✅ Telepon: "0213334455" (NOT "N/A")

### Step 3: Admin Dashboard - View Details
1. Click "Details" button on the organization card
2. Dialog should show:

**Expected Detail Fields**:
- ✅ Nama Hukum: "Yayasan Maju Bersama"
- ✅ Nama Pemilik: "Budi Santoso"
- ✅ Email Organisasi: "info@mayajursama.org"
- ✅ Email Pemilik: "budi@example.com"
- ✅ No. Telepon Pemilik: "081234567890"
- ✅ No. Telepon Organisasi: "0213334455"
- ✅ Status: "pending"
- ✅ Dokumen yang Diupload: (3 document links)

### Step 4: Admin Dashboard - Reject (Test First)
1. Click "Tolak" (Reject) button
2. **Expected**: Confirmation dialog appears
   ```
   Title: "Konfirmasi Penolakan"
   Message: "Apakah Anda yakin ingin menolak organisasi ini?"
   Buttons: "Batal" | "Ya, Tolak"
   ```

3. Click "Ya, Tolak"
4. **Expected Results**:
   - ✅ Organization disappears from list
   - ✅ Green SnackBar: "Organisasi berhasil ditolak"
   - ✅ In database: status = "reject"
   - ✅ Organization waiting screen shows rejection message

### Step 5: Register New Organization (For Approval Test)
1. Repeat Step 1 with different email:
   - Email Pemilik: "admin@organisasi.com"
   - Email Organisasi: "contact@organisasi.com"
   - Nama Organisasi: "Organisasi Test Approval"

### Step 6: Admin Dashboard - Accept
1. Click "Terima" (Accept) button on new organization
2. **Expected**: Confirmation dialog appears
   ```
   Title: "Konfirmasi Persetujuan"
   Message: "Apakah Anda yakin ingin menerima organisasi ini?"
   Buttons: "Batal" | "Ya, Terima"
   ```

3. Click "Ya, Terima"
4. **Expected Results**:
   - ✅ Organization disappears from list
   - ✅ Green SnackBar: "Organisasi berhasil disetujui"
   - ✅ In database: status = "approve"

### Step 7: Verify Organization Auto-Redirect
1. Check the organization's mobile app waiting verification screen
2. Should automatically detect approval and show progress
3. **Expected Results**:
   - ✅ Within 3 seconds: Auto-redirects to OrganizationLoginScreen
   - ✅ Organization can now login with:
     - Email: "contact@organisasi.com"
     - Password: "SecurePass123!"
   - ✅ After login: Accesses organization dashboard

## Verification Checklist

### Data Display
- [ ] Admin dashboard shows real organization data (not N/A)
- [ ] Details dialog shows all 6 fields + documents
- [ ] Document URLs are displayed correctly

### Reject Functionality
- [ ] Clicking "Tolak" shows confirmation dialog
- [ ] Dialog has correct message and buttons
- [ ] Clicking "Ya, Tolak" updates status in database
- [ ] Organization removed from list after rejection
- [ ] Rejection message appears on organization screen

### Accept Functionality
- [ ] Clicking "Terima" shows confirmation dialog
- [ ] Dialog has correct message and buttons
- [ ] Clicking "Ya, Terima" updates status in database
- [ ] Organization removed from list after approval
- [ ] Organization can login after approval

### Auto-Redirect
- [ ] Waiting screen polls for status change
- [ ] Auto-redirects to login within 3-5 seconds of approval
- [ ] Organization dashboard loads after login

## Database Verification

### Check Records
```sql
-- View all pending requests
SELECT request_id, nama_organisasi, email_organisasi, status
FROM organization_request 
WHERE status = 'pending'
ORDER BY tanggal_request DESC;

-- View rejected requests
SELECT request_id, nama_organisasi, status
FROM organization_request 
WHERE status = 'reject'
ORDER BY tanggal_request DESC;

-- View approved requests
SELECT request_id, nama_organisasi, status
FROM organization_request 
WHERE status = 'approve'
ORDER BY tanggal_request DESC;

-- View specific organization
SELECT * FROM organization_request 
WHERE email_organisasi = 'info@mayajursama.org';
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Still seeing "N/A" | Field names wrong | Check DEBUGGING_HANG_ISSUE.md for field mapping |
| Dialog doesn't appear | Button callback wrong | Verify using `_showApproveConfirmation()` |
| List doesn't refresh | `setState()` not called | Add `_refreshList()` after database update |
| Status not updating | Wrong field type | Ensure `request_id` is int, status is string |
| Auto-redirect not working | Polling interval too long | Check `_startStatusCheck()` frequency |
| Can't login after approval | Password not hashed | Verify BCrypt hashing in registration |

## Console Output Expected

### When Approving:
```
[AdminDashboard] ========== FETCH PENDING VERIFICATIONS ==========
[AdminDashboard] Query response length: 1
[AdminDashboard] ========== FETCH COMPLETE ==========
```

### When Polling (Organization):
```
[Waiting] Status: pending
[Waiting] Status: pending
[Waiting] Status: approve  ← Auto-redirect happens here
```

## Next Steps After Verification

1. ✅ Fix field display (N/A → real data)
2. ✅ Add confirmation dialogs
3. ✅ Test reject functionality
4. ✅ Test accept functionality
5. ✅ Test auto-redirect on approval
6. Future: Add email notifications, activity log, bulk operations

