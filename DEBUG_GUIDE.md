# Debugging Dashboard "N/A" Issue - Step by Step

## Current Status
- Organizations ARE being displayed on the dashboard (proving list loads)
- But all detail fields show "N/A"
- Yet the organization names ARE showing correctly as card titles
- This means SOME fields work but others don't

## The Mystery
If `nama_organisasi` field works (showing names like "Organisasi 1X"), but `nama_pemilik`, `email_organisasi`, and `no_telpon_organisasi` all show "N/A", then either:
1. **The database response only includes `nama_organisasi` field** (all other fields missing)
2. **Those other fields are NULL in the database** (not stored correctly)
3. **RLS policies block those specific fields** from being selected
4. **The field names in the actual database are different** than what we're using

## What I've Added - Debug Instrumentation
I've added comprehensive logging to help identify the issue:

### In main.dart
- Calls `testDashboardQuery()` when app starts
- Prints to console what's actually returned from database

### In test_dashboard_debug.dart  
- `testDashboardQuery()` function that:
  - Queries ALL records
  - Queries only PENDING records
  - Shows EVERY field in first record with types
  - Checks if specific fields exist in response
  - Tries explicit field selection

### In admin_dashboard_screen.dart
- Added detailed logging in ListView.builder (lines 354-360)
- Logs: all keys in record, full record object, individual field values
- This will show what data the dashboard is actually trying to render

##  What You Need to Do - RUN THE APP

1. **Start the app:**
   ```bash
   cd "d:\Kuliah\Semester 5\TekBer\FP\BersatuBantu"
   flutter run
   ```

2. **Navigate to Admin Dashboard** with pending organizations visible

3. **Check the Console Output** - Look for:
   - `[TEST 1]`, `[TEST 2]`, `[TEST 3]`, `[TEST 4]` logs from startup
   - `[AdminDashboard]` logs from dashboard rendering

4. **Key Things to Look For in Console:**
   - **In TEST 3**: Do you see `nama_organisasi: "Organisasi 1X"` and other fields?
   - **In AdminDashboard logs**: What keys are actually in the record?
   - **Critical question**: Are fields like `nama_pemilik`, `email_organisasi` showing up at all in the record?

## Possible Root Causes Based on Console Output

### Case 1: "Other fields are NULL in database"
If console shows:
```
[TEST 3]   "nama_pemilik": "NULL" (type: Null, isNull: true)
[TEST 3]   "email_organisasi": "NULL" (type: Null, isNull: true)
```
**Solution**: Data wasn't saved correctly when inserting. Check verification_provider insert.

### Case 2: "Fields don't exist in response"  
If console shows:
```
[TEST 3]   nama_pemilik exists: false
[TEST 3]   email_organisasi exists: false
```
**Solution**: RLS policy blocking SELECT on those columns. Need to check Supabase RLS policies.

### Case 3: "Fields exist but are empty strings"
If console shows:
```
[TEST 3]   "nama_pemilik": "" (type: String, isNull: false, isEmpty: true)
[TEST 3]   "email_organisasi": "" (type: String, isNull: false, isEmpty: true)
```
**Solution**: Form fields were empty when submitted. Form data collection issue.

### Case 4: "All fields look correct"
If console shows all fields with proper data, but dashboard still shows "N/A":
**Solution**: Bug in display logic (unusual - code looks correct)

## If Still Stuck
Once you run and share the console output, I can pinpoint the exact issue and implement the fix.

## Files Modified
- `lib/main.dart` - Added test on startup
- `lib/test_dashboard_debug.dart` - Debug query function
- `lib/fitur/auth/login/admin_dashboard_screen.dart` - Enhanced logging in ListView
