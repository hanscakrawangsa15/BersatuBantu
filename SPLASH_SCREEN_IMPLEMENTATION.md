# Splash Screen & Auth Flow Implementation

## 📱 Screens yang Telah Dibuat

### 1. **Splash Screen** ✅
**File:** `lib/features/splash/splash_screen.dart`

**Fitur:**
- Logo BersatuBantu dengan animasi fade-in & slide-up
- Gradient background (primary blue)
- Loading indicator
- Auto navigation setelah 3 detik
- Mengecek apakah user sudah pernah membuka app (SharedPreferences)

**Alur:**
1. Splash Screen muncul dengan animasi
2. Setelah 3 detik, check status onboarding
3. Jika belum pernah: → Welcome Screen
4. Jika sudah: → Login Screen

---

### 2. **Welcome Screen (Onboarding)** ✅
**File:** `lib/fitur/welcome/welcome_screen.dart`

**Fitur:**
- PageView dengan 3 slide onboarding
- Animasi smooth antar page
- Dots indicator (breadcrumbs)
- Skip button untuk lewat onboarding
- Tombol Lanjut, Kembali, dan Mulai Sekarang
- Menyimpan status ke SharedPreferences

**Konten 3 Slide:**
1. 🤝 Bersatu Membantu - Bergabung dengan komunitas
2. 💝 Donasi Mudah - Berikan bantuan dengan mudah
3. 🌟 Buat Perbedaan - Setiap kontribusi membuat perbedaan

---

### 3. **Login Screen** ✅
**File:** `lib/fitur/auth/login/login_screen.dart`

**Fitur:**
- Form dengan validasi real-time
- Email input dengan validasi format
- Password input dengan toggle visibility
- Form validation dengan error messages
- Loading state pada button
- Social login buttons (Google, Apple, Facebook)
- Link ke halaman register
- Link ke halaman forgot password

**Validasi:**
- Email: tidak boleh kosong + format valid
- Password: minimal 6 karakter

---

## 🎨 Design Integration

Semua screen menggunakan template system yang sudah dibuat:
- ✅ `AppColors` untuk warna konsisten
- ✅ `AppTextStyle` untuk typography
- ✅ `AppButton` untuk button styling
- ✅ `AppTextField` untuk input styling
- ✅ `FormLayout` untuk form structure
- ✅ `AppScaffold` untuk layout base
- ✅ Gradient backgrounds
- ✅ Animasi smooth

---

## 📂 File Structure

```
lib/
├── features/
│   └── splash/
│       └── splash_screen.dart          ✅ Splash screen
│
├── fitur/
│   ├── welcome/
│   │   └── welcome_screen.dart         ✅ Onboarding
│   └── auth/
│       └── login/
│           └── login_screen.dart       ✅ Login form
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_style.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app-button.dart
│       ├── app-text-field.dart
│       ├── form_layout.dart
│       └── app_scaffold.dart
│
└── main.dart                           ✅ Updated with routes
```

---

## 🔄 Navigation Flow

```
SplashScreen (3 detik)
    ↓
Cek SharedPreferences (has_seen_onboarding)
    ├─ Tidak ada (pertama kali) → WelcomeScreen
    │   ├─ Skip → LoginScreen
    │   ├─ Next/Lanjut (3 halaman) → LoginScreen
    │   └─ Mulai Sekarang → LoginScreen
    │
    └─ Ada (sudah pernah) → LoginScreen
        ├─ Login sukses → Home/Dashboard
        ├─ Lupa password → Forgot Password
        └─ Belum akun → Register
```

---

## 🛠️ Dependencies yang Digunakan

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2      # Untuk menyimpan onboarding status
  supabase_flutter: ^2.5.0        # Untuk authentication
```

---

## ⚙️ Configuration

### SharedPreferences Key
```dart
'has_seen_onboarding'  // boolean - sudah pernah buka app
```

### Animation Durations
```dart
SplashScreen: 1500ms (fade + slide)
Navigation delay: 3000ms
WelcomeScreen PageView: 500ms
```

---

## 🔐 Security Notes

1. **Password Field**: Menggunakan TextField dengan isPassword = true
2. **Email Validation**: Format email validated dengan regex
3. **Loading State**: Prevent multiple login attempts

---

## 📝 Implementasi Next Steps

### 1. Register Screen (Coming Soon)
Buat halaman registrasi dengan form similar ke login

### 2. Forgot Password Screen (Coming Soon)
Buat halaman untuk reset password

### 3. Home/Dashboard Screen (Coming Soon)
Buat halaman utama setelah login berhasil

### 4. Integrate Supabase Auth
Replace simulasi dengan actual Supabase authentication:

```dart
// Example:
Future<void> _handleLogin() async {
  try {
    await supabase.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    // Navigate to home
  } catch (e) {
    // Show error
  }
}
```

---

## 🎨 UI/UX Features

### Splash Screen
- ✅ Gradient background
- ✅ Smooth fade-in animation
- ✅ Logo dengan shadow
- ✅ Loading indicator
- ✅ Professional appearance

### Welcome Screen
- ✅ PageView swipeable
- ✅ Dots indicator
- ✅ Smooth transitions
- ✅ Skip button
- ✅ Clear call-to-action

### Login Screen
- ✅ Clean form layout
- ✅ Real-time validation
- ✅ Error messages
- ✅ Loading state
- ✅ Social login options
- ✅ Links to other pages

---

## 🧪 Testing Checklist

- [ ] Splash screen menampilkan dengan benar
- [ ] Animasi berjalan smooth
- [ ] Auto navigate ke welcome screen (first time)
- [ ] Auto navigate ke login screen (subsequent times)
- [ ] Welcome screen PageView working
- [ ] Skip button berfungsi
- [ ] Form validation working
- [ ] Email validation correct
- [ ] Password toggle working
- [ ] Loading state showing
- [ ] Social buttons clickable
- [ ] Links ke register/forgot password working
- [ ] Test di berbagai ukuran device

---

## 🚀 Customization

### Mengubah waktu splash
```dart
await Future.delayed(const Duration(seconds: 3)); // Ubah angka
```

### Mengubah isi welcome slides
```dart
_buildPage(
  icon: '🎯', // Ubah icon
  title: 'Judul Baru',
  description: 'Deskripsi baru',
)
```

### Mengubah warna gradient
```dart
decoration: BoxDecoration(
  gradient: AppColors.gradientSuccess, // Atau gradient lain
)
```

---

## 📄 File Reference

| File | Purpose | Lines |
|------|---------|-------|
| splash_screen.dart | Splash dengan animasi | 120+ |
| welcome_screen.dart | Onboarding slides | 200+ |
| login_screen.dart | Login form | 180+ |
| main.dart | App entry + routes | 35+ |

---

**Status:** ✅ Ready to Use
**Last Updated:** 27 November 2024
