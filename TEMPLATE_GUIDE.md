# BersatuBantu - Template & Design System

Dokumentasi lengkap untuk menggunakan template dan design system BersatuBantu dalam pengembangan fitur aplikasi mobile.

## 📋 Daftar Isi

- [Struktur Proyek](#struktur-proyek)
- [Color Palette](#color-palette)
- [Typography](#typography)
- [Komponen Dasar](#komponen-dasar)
- [Template Screen](#template-screen)
- [Panduan Penggunaan](#panduan-penggunaan)
- [Contoh Implementasi](#contoh-implementasi)

---

## 🏗️ Struktur Proyek

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart          # Palet warna konsisten
│   │   ├── app_text_style.dart      # Tipografi reusable
│   │   └── app_theme.dart           # Konfigurasi tema material
│   ├── widgets/
│   │   ├── app-button.dart          # Custom button component
│   │   ├── app-text-field.dart      # Custom text field component
│   │   ├── app_scaffold.dart        # Base scaffold untuk semua screen
│   │   ├── form_layout.dart         # Layout untuk form
│   │   ├── action_card.dart         # Card yang dapat diklik
│   │   ├── feature_card.dart        # Card untuk fitur/item
│   │   ├── app_dialog.dart          # Dialog & snackbar custom
│   │   ├── auth_screen_template.dart # Template auth screen
│   │   └── list_screen_template.dart # Template list/detail screen
│   └── app-route.dart
├── fitur/                           # Implementasi fitur per module
│   ├── auth/
│   ├── berikandonasi/
│   ├── postingkegiatandonasi/
│   └── welcome/
└── main.dart
```

---

## 🎨 Color Palette

### Primary Colors
```dart
AppColors.primaryBlue        // #5B6EFF - Warna utama
AppColors.primaryBlueDark    // #4A54D9 - Warna utama gelap
AppColors.primaryBlueLight   // #7B8EFF - Warna utama terang
```

### Secondary Colors
```dart
AppColors.accentGreen        // #10B981 - Aksen hijau
AppColors.accentRed          // #EF4444 - Aksen merah
AppColors.accentOrange       // #F97316 - Aksen oranye
AppColors.accentYellow       // #FCD34D - Aksen kuning
```

### Neutral Colors
```dart
AppColors.textPrimary        // #1F2937 - Teks utama
AppColors.textSecondary      // #6B7280 - Teks sekunder
AppColors.textTertiary       // #9CA3AF - Teks tersier
AppColors.textDisabled       // #D1D5DB - Teks disabled

AppColors.bgPrimary          // #FFFFFF - Background utama
AppColors.bgSecondary        // #F3F4F6 - Background sekunder
AppColors.bgTertiary         // #E5E7EB - Background tersier
AppColors.bgDark             // #111827 - Background gelap
```

### Status Colors
```dart
AppColors.successGreen       // #10B981 - Sukses
AppColors.warningYellow      // #FCD34D - Peringatan
AppColors.errorRed           // #EF4444 - Error
AppColors.infoBlue           // #3B82F6 - Informasi
```

### Gradients
```dart
AppColors.gradientPrimary    // Gradient dari primaryBlue ke primaryBlueDark
AppColors.gradientSuccess    // Gradient hijau
```

---

## 🔤 Typography

### Display Styles (untuk judul besar)
```dart
AppTextStyle.displayLarge    // 32px, bold, height 1.2
AppTextStyle.displayMedium   // 28px, bold, height 1.2
AppTextStyle.displaySmall    // 24px, bold, height 1.3
```

### Heading Styles
```dart
AppTextStyle.headingLarge    // 20px, w700
AppTextStyle.headingMedium   // 18px, w700
AppTextStyle.headingSmall    // 16px, w700
```

### Body Styles
```dart
AppTextStyle.bodyLarge       // 16px, w500
AppTextStyle.bodyMedium      // 14px, w500
AppTextStyle.bodySmall       // 12px, w500
```

### Label Styles
```dart
AppTextStyle.labelLarge      // 14px, w700, letter spacing 0.5
AppTextStyle.labelMedium     // 12px, w700, letter spacing 0.5
AppTextStyle.labelSmall      // 10px, w700, letter spacing 0.5
```

### Button Styles
```dart
AppTextStyle.buttonLarge     // 16px, w700
AppTextStyle.buttonMedium    // 14px, w700
AppTextStyle.buttonSmall     // 12px, w700
```

---

## 🧩 Komponen Dasar

### 1. AppButton
Button dengan berbagai varian dan state.

**Varian:**
- `ButtonVariant.primary` - Tombol utama (filled)
- `ButtonVariant.secondary` - Tombol sekunder
- `ButtonVariant.outline` - Tombol dengan border
- `ButtonVariant.text` - Tombol text saja
- `ButtonVariant.danger` - Tombol berbahaya (hapus, logout, dll)

**Ukuran:**
- `ButtonSize.small` - 12px, padding 12x8
- `ButtonSize.medium` - 14px, padding 16x12 (default)
- `ButtonSize.large` - 16px, padding 24x16

**Contoh Penggunaan:**
```dart
AppButton(
  label: 'Simpan',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
  isLoading: false,
  isDisabled: false,
)
```

### 2. AppTextField
Input text dengan validasi dan styling konsisten.

**Fitur:**
- Custom label dan hint
- Validasi error
- Password visibility toggle
- Prefix dan suffix icons
- Read-only mode
- Multi-line support

**Contoh Penggunaan:**
```dart
AppTextField(
  label: 'Email',
  hint: 'Masukkan email Anda',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  isRequired: true,
  prefixIcon: const Icon(Icons.email_outlined),
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email tidak boleh kosong';
    return null;
  },
)
```

### 3. ActionCard
Card dengan efek tap dan interaktif.

**Contoh Penggunaan:**
```dart
ActionCard(
  onTap: () {},
  child: Row(
    children: [
      Icon(Icons.star),
      SizedBox(width: 12),
      Text('Item'),
    ],
  ),
)
```

### 4. ListItemCard
List item dengan title, subtitle, leading, dan trailing widget.

**Contoh Penggunaan:**
```dart
ListItemCard(
  title: 'Judul Item',
  subtitle: 'Deskripsi singkat',
  leading: Icon(Icons.person),
  trailing: Icon(Icons.arrow_forward),
  onTap: () {},
)
```

### 5. FeatureCard
Card untuk menampilkan fitur/item dengan gambar dan aksi.

**Contoh Penggunaan:**
```dart
FeatureCard(
  title: 'Donasi Kami',
  description: 'Kirimkan bantuan untuk yang membutuhkan',
  imageProvider: AssetImage('assets/images/donation.png'),
  topRightBadge: AppBadge(label: 'Featured'),
  actionButtons: [
    AppButton(
      label: 'Lihat',
      onPressed: () {},
      size: ButtonSize.small,
    ),
  ],
  onTap: () {},
)
```

### 6. AppBadge
Badge untuk menampilkan status/kategori.

**Contoh Penggunaan:**
```dart
AppBadge(
  label: 'Status',
  backgroundColor: AppColors.accentGreen,
  textColor: AppColors.bgPrimary,
)
```

### 7. AppDialog
Dialog custom yang konsisten.

**Contoh Penggunaan:**
```dart
showDialog(
  context: context,
  builder: (context) => AppDialog(
    title: 'Konfirmasi',
    content: Text('Apakah Anda yakin?'),
    actions: [
      AppButton(
        label: 'Batal',
        onPressed: () => Navigator.pop(context),
        variant: ButtonVariant.secondary,
      ),
      AppButton(
        label: 'Yakin',
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ),
)
```

### 8. AppSnackBar
Snackbar/toast custom dengan berbagai tipe.

**Tipe:**
- `SnackBarType.success` - Hijau
- `SnackBarType.error` - Merah
- `SnackBarType.warning` - Kuning
- `SnackBarType.info` - Biru

**Contoh Penggunaan:**
```dart
AppSnackBar.show(
  context,
  message: 'Berhasil disimpan!',
  type: SnackBarType.success,
  duration: const Duration(seconds: 3),
)
```

---

## 📱 Template Screen

### 1. AuthScreenTemplate
Template untuk screen login/register.

**Fitur:**
- Form layout yang rapi
- Social login buttons
- Link ke halaman lain
- Loading state handling

**Lokasi:** `lib/core/widgets/auth_screen_template.dart`

### 2. ListScreenTemplate
Template untuk screen list/grid fitur.

**Fitur:**
- Search bar
- Grid/list view
- Feature cards
- Pull to refresh ready

**Lokasi:** `lib/core/widgets/list_screen_template.dart`

### 3. DetailScreenTemplate
Template untuk screen detail item.

**Fitur:**
- Hero image section
- Badge dan status
- Detail rows
- Action buttons

**Lokasi:** `lib/core/widgets/list_screen_template.dart`

---

## 📖 Panduan Penggunaan

### Step 1: Import Dependencies
```dart
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/app-text-field.dart';
// import widget lain sesuai kebutuhan
```

### Step 2: Gunakan AppScaffold sebagai Base
```dart
class MyFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Judul Screen',
      bodyPadding: const EdgeInsets.all(16),
      body: // content di sini
    );
  }
}
```

### Step 3: Gunakan Components untuk Build UI
```dart
Column(
  children: [
    Text('Heading', style: AppTextStyle.headingLarge),
    const SizedBox(height: 16),
    AppTextField(
      label: 'Input',
      hint: 'Placeholder',
    ),
    const SizedBox(height: 16),
    SizedBox(
      width: double.infinity,
      child: AppButton(
        label: 'Submit',
        onPressed: () {},
      ),
    ),
  ],
)
```

---

## 💡 Contoh Implementasi

### Contoh 1: Simple Form Screen
```dart
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/form_layout.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/app-text-field.dart';

class DonationFormScreen extends StatefulWidget {
  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Berikan Donasi',
      bodyPadding: const EdgeInsets.all(16),
      body: FormLayout(
        subtitle: 'Bantuan Anda sangat berarti',
        fields: [
          AppTextField(
            label: 'Jumlah Donasi',
            hint: 'Rp 0',
            controller: _amountController,
            keyboardType: TextInputType.number,
            isRequired: true,
            prefixIcon: Text('Rp'),
          ),
          AppTextField(
            label: 'Pesan (Opsional)',
            hint: 'Tulis pesan Anda',
            controller: _messageController,
            maxLines: 3,
            minLines: 3,
          ),
        ],
        submitButton: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: _isLoading ? 'Memproses...' : 'Donasi Sekarang',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            size: ButtonSize.large,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Implementasi submit logic
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
```

### Contoh 2: List View dengan Cards
```dart
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/feature_card.dart';

class ActivityListScreen extends StatelessWidget {
  final activities = [
    {
      'title': 'Donasi Untuk Gempa',
      'description': '2,344 orang telah berkontribusi',
      'category': 'Disaster Relief',
    },
    // ... more items
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Aktivitas Terbaru',
      bodyPadding: const EdgeInsets.all(16),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final item = activities[index];
          return FeatureCard(
            title: item['title']!,
            description: item['description']!,
            onTap: () {
              // Navigate to detail
            },
          );
        },
      ),
    );
  }
}
```

---

## 🎯 Best Practices

1. **Konsistensi Warna**: Selalu gunakan `AppColors` untuk warna, jangan hardcode color
2. **Konsistensi Tipografi**: Gunakan `AppTextStyle` untuk semua text styling
3. **Component Reuse**: Gunakan component yang sudah ada daripada membuat baru
4. **Responsive Design**: Gunakan `MediaQuery` dan `LayoutBuilder` untuk responsive UI
5. **Error Handling**: Selalu tampilkan error message menggunakan `AppSnackBar`
6. **Loading State**: Gunakan `isLoading` property di button untuk menunjukkan loading
7. **Padding Konsisten**: Gunakan padding 16px untuk content area, 12px untuk spacing antar element
8. **Border Radius**: Gunakan 10-12px untuk button/input, 12-16px untuk card

---

## 📝 Changelog

### v1.0.0 (Initial Release)
- ✅ Color palette lengkap
- ✅ Typography system
- ✅ Base components (Button, TextField, etc)
- ✅ Layout components (Scaffold, FormLayout, Cards)
- ✅ Screen templates (Auth, List, Detail)
- ✅ Dialog dan Snackbar custom

---

## ❓ FAQ

**Q: Bagaimana cara menambah warna baru?**
A: Tambahkan ke `AppColors` class dan konsultasikan dengan design team terlebih dahulu.

**Q: Bisa ganti font?**
A: Font bisa diganti di `pubspec.yaml` dengan package `google_fonts`, tapi tetap ikuti ukuran dan weight dari `AppTextStyle`.

**Q: Bagaimana untuk dark mode?**
A: Template sudah menyediakan dark theme skeleton di `app_theme.dart`, tinggal disesuaikan lebih lanjut.

---

## 📞 Kontribusi & Support

Jika ada pertanyaan atau ingin menambah komponen baru, hubungi tech lead team.

---

**Last Updated:** 27 November 2024
**Version:** 1.0.0
