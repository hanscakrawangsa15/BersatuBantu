# 🔍 Quick Debugging Steps

## Step 1: Run the App
```powershell
cd "d:\Kuliah\Semester 5\TekBer\FP\BersatuBantu"
flutter run
```

## Step 2: Check Console Startup Output

When the app starts (before you navigate anywhere), look in the console/debug output for this section. It will print automatically:

```
========== DATABASE QUERY TEST START ==========
[TEST 2] Querying pending records (status=pending)...
[TEST 2] Pending records count: 6

[TEST 3] Expected fields check:
[TEST 3]   request_id exists: true/false
[TEST 3]   nama_organisasi exists: true/false  ← Should be TRUE
[TEST 3]   nama_pemilik exists: true/false     ← This is what matters
[TEST 3]   email_organisasi exists: true/false ← This is what matters
[TEST 3]   no_telpon_organisasi exists: true/false ← This is what matters
```

## Step 3: Take a Screenshot of Console

Share with me what you see for those four `exists:` lines.

## Case 1: If all say `exists: true`
→ Problem is NOT in database
→ Problem is in how Flutter displays the data
→ Likely a field access issue (probably not, code looks correct)

## Case 2: If some say `exists: false`
→ Problem IS in database or RLS policies
→ Those fields either aren't saved or can't be read
→ Need to check Supabase configuration

## Case 3: If you see `NULL` or empty values
→ Problem IS in data entry or form collection
→ Fields were empty when form was submitted
→ Need to verify form input logic

---

**That's all you need to do!** Once you share the console output, I can pinpoint exactly what's wrong and implement the fix.
