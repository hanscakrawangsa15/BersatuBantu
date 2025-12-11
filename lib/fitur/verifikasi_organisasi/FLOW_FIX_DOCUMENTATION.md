# Flow Verifikasi Organisasi - Fixed Version

## 🔧 Masalah yang Diperbaiki

**Masalah sebelumnya:** Ketika user klik "Organisasi", malah masuk ke LoginScreen (tampilan login personal).

**Penyebab:** 
1. Role Selection Screen tidak membedakan routing untuk "Organisasi" (volunteer) dan "Personal" (user)
2. Login Screen selalu route ke LoadingScreen untuk semua role termasuk 'volunteer'
3. Tidak ada direct flow ke OrganizationVerificationFlow setelah login/role selection

**Solusi:** 
1. Update RoleSelectionScreen untuk route ke OrganizationVerificationFlow ketika user pilih "Organisasi"
2. Update LoginScreen untuk route ke OrganizationVerificationFlow ketika role adalah 'volunteer'
3. Add proper handling untuk pre-login dan post-login scenarios

## 📊 Flow Diagram (Fixed)

```
┌─────────────────────┐
│  Splash Screen      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Role Selection      │ (Kenalkan dirimu, Pahlawan!)
│ • Personal          │
│ • Organisasi    ◄─── USER CLICKS "ORGANISASI"
│ • Admin             │
└──────┬──────────────┘
       │
       ├─ USER NOT LOGIN (userId == null)
       │  ├─ ROUTE: LoginScreen(selectedRole: 'volunteer')
       │  └─ After Login ─┐
       │                  ▼
       │         Check role in DB
       │         role == 'volunteer'?
       │                  │
       │                  ├─ YES ─┐
       │                  │        ▼
       │                  │   OrganizationVerificationFlow
       │                  │   (Owner Data → Org Data → Upload → Verifying → Success)
       │                  │
       │                  └─ NO (null/empty) ─┐
       │                                       ▼
       │                          RoleSelectionScreen again
       │
       │
       └─ USER ALREADY LOGIN (userId != null)
          ├─ STEP 1: Save role='volunteer' to DB
          ├─ STEP 2: Check if role is 'volunteer'
          │
          └─ YES (role == 'volunteer')
             ├─ Show Snackbar: "Berhasil memilih sebagai Organisasi"
             └─ ROUTE: OrganizationVerificationFlow
                └─ Owner Data Screen
                   └─ Organization Data Screen
                      └─ Documents Upload Screen
                         └─ Verifying Screen
                            └─ Success Screen
                               └─ Navigate to /home
```

## 🔄 Sequence Diagram

### Scenario 1: User belum login, klik "Organisasi"

```
User clicks "Organisasi" button
    │
    ├─ Check userId from RoleSelectionScreen
    │
    ├─ userId == null (not logged in)
    │
    └─ Navigate to LoginScreen(selectedRole: 'volunteer')
           │
           ├─ User enter email & password
           │
           ├─ Supabase signInWithPassword() success
           │
           ├─ Get profile from DB
           │
           ├─ If profile exists & role == 'volunteer'
           │
           └─ Navigate to OrganizationVerificationFlow ✓
```

### Scenario 2: User sudah login di role selection

```
User clicks "Organisasi" button
    │
    ├─ Check userId from RoleSelectionScreen
    │
    ├─ userId != null (already logged in)
    │
    ├─ Update profiles.role = 'volunteer'
    │
    ├─ Check role == 'volunteer'?
    │
    ├─ YES
    │
    └─ Navigate to OrganizationVerificationFlow ✓
        (Show snackbar: "Berhasil memilih sebagai Organisasi")
```

### Scenario 3: User re-login dengan role yang berbeda

```
User dalam OrganizationVerificationFlow
    │
    ├─ User logout
    │
    ├─ User login dengan account lain
    │
    ├─ Role selection screen muncul
    │
    ├─ User klik "Organisasi"
    │
    └─ Navigate to OrganizationVerificationFlow ✓
       (Flow fresh mulai dari Owner Data)
```

## 📝 Code Changes Summary

### 1. **login_screen.dart**
Added import:
```dart
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/verification_flow.dart';
```

Updated routing logic (line ~143):
```dart
} else if (userRole == 'volunteer') {
  // Organisasi - langsung ke verification flow
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => const OrganizationVerificationFlow(),
    ),
  );
}
```

### 2. **role_selection_screen.dart**
Updated the else branch (line ~71):
```dart
} else if (role == 'volunteer') {
  // Organisasi - langsung ke verification flow
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Berhasil memilih sebagai Organisasi'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => 
        const OrganizationVerificationFlow(),
      // ... transition builder
    ),
  );
}
```

## ✅ Testing Checklist

### Test 1: User not logged in
- [ ] Open app → Role Selection Screen
- [ ] Click "Organisasi"
- [ ] Redirect to LoginScreen
- [ ] Login successfully
- [ ] Should see OrganizationVerificationFlow (Owner Data Step)
- [ ] Not LoadingScreen!

### Test 2: User already logged in
- [ ] Already logged in user → Role Selection Screen
- [ ] Click "Organisasi"
- [ ] Should see snackbar "Berhasil memilih sebagai Organisasi"
- [ ] Should see OrganizationVerificationFlow immediately
- [ ] Can go through all steps

### Test 3: Role change
- [ ] User logged in with role='user'
- [ ] Go to Role Selection → Click "Organisasi"
- [ ] Role updated to 'volunteer' in DB
- [ ] Redirect to OrganizationVerificationFlow
- [ ] Continue verification

### Test 4: Back navigation
- [ ] In OrganizationVerificationFlow
- [ ] Click back at Owner Data step
- [ ] Should go back to previous screen (or close)
- [ ] Not crash

## 🐛 Edge Cases Handled

1. **User login but profile doesn't exist** → Create new profile → Route to role selection
2. **User login with empty role** → Show role selection again
3. **User change role** → Update DB and route accordingly
4. **User already has 'volunteer' role** → Direct to OrganizationVerificationFlow
5. **Network error during login** → Show error snackbar

## 🎯 Key Files Modified

1. `lib/fitur/auth/login/login_screen.dart`
   - Added import for OrganizationVerificationFlow
   - Updated routing logic for 'volunteer' role

2. `lib/fitur/pilihrole/role_selection_screen.dart`
   - Updated routing logic for 'volunteer' role
   - Added snackbar feedback

## 📚 Related Files

- `lib/fitur/verifikasi_organisasi/screens/verification_flow.dart` - Main flow
- `lib/fitur/verifikasi_organisasi/providers/verification_provider.dart` - State management
- `lib/fitur/verifikasi_organisasi/screens/owner_data_screen.dart` - Step 1
- `lib/fitur/verifikasi_organisasi/screens/organization_data_screen.dart` - Step 2
- `lib/fitur/verifikasi_organisasi/screens/documents_upload_screen.dart` - Step 3
- `lib/fitur/verifikasi_organisasi/screens/verifying_screen.dart` - Step 4
- `lib/fitur/verifikasi_organisasi/screens/success_screen.dart` - Step 5

---

**Status:** ✅ Fixed & Ready
**Last Updated:** December 9, 2025
