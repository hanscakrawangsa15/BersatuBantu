# BersatuBantu Template System - Developer Guide

## 📑 Struktur File yang Telah Dibuat

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart              ✅ Palet warna lengkap
│   │   ├── app_text_style.dart          ✅ Tipografi sistem
│   │   └── app_theme.dart               ✅ Konfigurasi material theme
│   │
│   └── widgets/
│       ├── app-button.dart              ✅ Custom button component
│       ├── app-text-field.dart          ✅ Custom text field component
│       ├── app_scaffold.dart            ✅ Base scaffold layout
│       ├── form_layout.dart             ✅ Form layout component
│       ├── action_card.dart             ✅ Clickable card + ListItemCard
│       ├── feature_card.dart            ✅ Feature card + Badge
│       ├── app_dialog.dart              ✅ Dialog + Snackbar
│       ├── auth_screen_template.dart    ✅ Auth screen template
│       └── list_screen_template.dart    ✅ List & detail templates
│
└── fitur/
    ├── auth/
    ├── berikandonasi/
    ├── postingkegiatandonasi/
    └── welcome/

root/
├── TEMPLATE_GUIDE.md                     ✅ Dokumentasi lengkap
├── TEMPLATE_QUICK_REFERENCE.md           ✅ Quick reference guide
└── IMPLEMENTATION_EXAMPLES.dart          ✅ Contoh implementasi
```

---

## ✨ Fitur Template yang Telah Dibuat

### 1. **Color System** (`app_colors.dart`)
- ✅ Primary colors (blue variants)
- ✅ Secondary/accent colors (green, red, orange, yellow)
- ✅ Neutral colors (text, background, borders)
- ✅ Status colors (success, warning, error, info)
- ✅ Gradient definitions
- ✅ Opacity helper functions

**Keunggulan:**
- Centralized color management
- Easy to maintain dan update
- Consistent dengan design system
- Support untuk light/dark mode

---

### 2. **Typography System** (`app_text_style.dart`)
- ✅ Display styles (3 ukuran)
- ✅ Heading styles (3 ukuran)
- ✅ Body styles (3 ukuran)
- ✅ Label styles (3 ukuran)
- ✅ Button text styles (3 ukuran)
- ✅ Caption styles

**Keunggulan:**
- Semantic text sizing
- Pre-configured font weights dan heights
- Easy to apply styling across app
- Consistent line heights

---

### 3. **AppButton Component**
- ✅ 5 variants: primary, secondary, outline, text, danger
- ✅ 3 sizes: small, medium, large
- ✅ Loading state dengan spinner
- ✅ Disabled state handling
- ✅ Icon support (leading/trailing)
- ✅ Tap animation (scale effect)
- ✅ Shadow for primary variant

**Keunggulan:**
- Highly customizable
- Consistent interaction patterns
- Built-in loading indicator
- Accessible dan responsive

---

### 4. **AppTextField Component**
- ✅ Label dengan required indicator
- ✅ Error message display
- ✅ Password visibility toggle
- ✅ Prefix icon support
- ✅ Suffix icon support
- ✅ Focus state styling
- ✅ Read-only mode
- ✅ Multi-line support
- ✅ Custom keyboard types
- ✅ Focus node management

**Keunggulan:**
- Full validation support
- Clear error states
- Accessible dan user-friendly
- Consistent styling

---

### 5. **Layout Components**

#### AppScaffold
- ✅ Base layout untuk semua screen
- ✅ Auto AppBar dengan customization
- ✅ Back button handling
- ✅ Body padding
- ✅ FAB support
- ✅ Custom actions

#### FormLayout
- ✅ Optimized untuk form screen
- ✅ Header dengan title/subtitle
- ✅ Auto spacing between fields
- ✅ Submit button area
- ✅ Bottom widget (social buttons, links, etc)
- ✅ Single child scrollview integrated

---

### 6. **Card Components**

#### ActionCard
- ✅ Tap animation
- ✅ Customizable padding
- ✅ Customizable border radius
- ✅ Shadow support
- ✅ Scale down effect on tap

#### ListItemCard
- ✅ Title + subtitle layout
- ✅ Leading icon/widget
- ✅ Trailing widget
- ✅ Optimized untuk list items
- ✅ Text truncation handling

#### FeatureCard
- ✅ Image/asset support
- ✅ Top-right badge
- ✅ Title + description
- ✅ Action buttons support
- ✅ Optimized untuk grid layout

#### AppBadge
- ✅ Customizable colors
- ✅ Customizable padding
- ✅ Label text styling

---

### 7. **Dialog & Notification**

#### AppDialog
- ✅ Custom dialog layout
- ✅ Close button
- ✅ Custom actions
- ✅ Dismissible control
- ✅ Scrollable content

#### AppSnackBar
- ✅ 4 types: success, error, warning, info
- ✅ Icon display
- ✅ Floating behavior
- ✅ Dismiss animation
- ✅ Customizable duration

---

### 8. **Screen Templates**

#### AuthScreenTemplate
- ✅ Form dengan multiple fields
- ✅ Loading state handling
- ✅ Social login buttons
- ✅ Auth links (forgot password, register)
- ✅ Professional layout

#### ListScreenTemplate
- ✅ Search bar
- ✅ Grid/list view ready
- ✅ Feature card integration
- ✅ Pull-to-refresh ready

#### DetailScreenTemplate
- ✅ Hero image section
- ✅ Status badges
- ✅ Detail rows
- ✅ Action buttons
- ✅ Scrollable content

---

## 🚀 Cara Menggunakan Template

### Step 1: Implementasi Form Screen
```dart
// File: lib/fitur/berikandonasi/presentation/pages/donation_form_page.dart
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/form_layout.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/app-text-field.dart';

class DonationFormPage extends StatefulWidget {
  @override
  State<DonationFormPage> createState() => _DonationFormPageState();
}

class _DonationFormPageState extends State<DonationFormPage> {
  final _amountController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donasi Kami',
      bodyPadding: const EdgeInsets.all(16),
      body: FormLayout(
        title: 'Berikan Donasi',
        subtitle: 'Bantuan Anda membuat perbedaan',
        fields: [
          AppTextField(
            label: 'Jumlah Donasi',
            hint: 'Rp 0',
            controller: _amountController,
            keyboardType: TextInputType.number,
            isRequired: true,
            errorText: _error,
            onChanged: (_) => setState(() => _error = null),
          ),
        ],
        submitButton: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Donasi Sekarang',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            size: ButtonSize.large,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Implement donation logic
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
```

### Step 2: Implementasi List Screen
```dart
// File: lib/fitur/berikandonasi/presentation/pages/donation_list_page.dart
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/feature_card.dart';

class DonationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donasi Aktif',
      bodyPadding: const EdgeInsets.all(16),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return FeatureCard(
            title: 'Donasi ${index + 1}',
            description: 'Deskripsi donasi',
            image: Center(child: Text('🎁', style: TextStyle(fontSize: 48))),
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

## 📋 Checklist untuk Setiap Fitur Baru

Sebelum mengimplementasikan fitur baru, pastikan:

- [ ] **Planning**
  - [ ] Tentukan tipe screen (form, list, detail, etc)
  - [ ] Sketch UI berdasarkan Figma design
  - [ ] Identifikasi komponen yang diperlukan

- [ ] **Folder Structure**
  - [ ] Buat folder fitur: `lib/fitur/nama_fitur/`
  - [ ] Buat subfolder: `presentation/pages/`, `data/`, `domain/`
  - [ ] Create main page file

- [ ] **Implementation**
  - [ ] Import template components
  - [ ] Gunakan `AppScaffold` sebagai root
  - [ ] Gunakan `AppColors` untuk semua warna
  - [ ] Gunakan `AppTextStyle` untuk semua text
  - [ ] Implement form fields dengan `AppTextField`
  - [ ] Implement buttons dengan `AppButton`

- [ ] **Styling**
  - [ ] Apply consistent spacing (16px default)
  - [ ] Use proper text styles (headingLarge untuk judul, bodyMedium untuk content)
  - [ ] Apply proper padding (16px untuk screen, 12px untuk items)

- [ ] **States**
  - [ ] Handle loading state
  - [ ] Handle error state
  - [ ] Handle empty state
  - [ ] Handle success state

- [ ] **Testing**
  - [ ] Test di berbagai ukuran screen
  - [ ] Test pada different devices/orientations
  - [ ] Test form validation
  - [ ] Test navigation flows
  - [ ] Test error handling

- [ ] **Accessibility**
  - [ ] Check semantic labels
  - [ ] Check color contrast
  - [ ] Check text readability

---

## 🔧 Customization Guide

### Jika ingin mengubah warna primary
```dart
// lib/core/theme/app_colors.dart
static const Color primaryBlue = Color(0xFF5B6EFF); // Ubah di sini
```

### Jika ingin mengubah font
```dart
// lib/core/theme/app_text_style.dart
static const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  fontFamily: 'YourFontName', // Ubah di sini
  fontWeight: FontWeight.w500,
);
```

### Jika ingin menambah komponen baru
```dart
// 1. Buat file baru di lib/core/widgets/
// 2. Import AppColors dan AppTextStyle
// 3. Implement component dengan consistent styling
// 4. Update TEMPLATE_GUIDE.md dengan dokumentasi
// 5. Test component
```

---

## 📊 Dokumentasi Files

| File | Tujuan | Audience |
|------|--------|----------|
| `TEMPLATE_GUIDE.md` | Dokumentasi lengkap sistem | Developers, Designers, PMs |
| `TEMPLATE_QUICK_REFERENCE.md` | Quick reference untuk coding | Developers |
| `IMPLEMENTATION_EXAMPLES.dart` | Contoh implementasi | Developers |
| `README_TEMPLATE_SYSTEM.md` | Overview sistem (ini) | Developers, Tech Lead |

---

## 🎓 Learning Resources

1. **Untuk memahami template system:**
   - Baca `TEMPLATE_GUIDE.md` dengan lengkap
   - Lihat contoh di `IMPLEMENTATION_EXAMPLES.dart`
   - Buka dan pelajari file components di `lib/core/widgets/`

2. **Untuk implementasi pertama kali:**
   - Copy template dari `auth_screen_template.dart` atau `list_screen_template.dart`
   - Modifikasi sesuai kebutuhan fitur
   - Ikuti checklist implementasi

3. **Untuk quick lookup:**
   - Gunakan `TEMPLATE_QUICK_REFERENCE.md`
   - Lihat section "Common Patterns"
   - Lihat "Troubleshooting" jika ada masalah

---

## 🤝 Kontribusi & Maintenance

### Jika menemukan bug di template:
1. Buat issue dengan detail lengkap
2. Jika bisa fix, submit pull request
3. Update dokumentasi jika diperlukan

### Jika ingin menambah komponen:
1. Diskusikan dengan tech lead terlebih dahulu
2. Design dengan consistent dengan existing components
3. Implementasikan dengan dokumentasi lengkap
4. Add ke dokumentasi template
5. Buat contoh penggunaan

### Regular Updates:
- [ ] Review template system setiap quarter
- [ ] Gather feedback dari developers
- [ ] Update based on design system changes
- [ ] Maintain backward compatibility

---

## 📞 Contact & Support

**Tech Lead:** [Contact Info]
**Designer:** [Contact Info]
**Documentation Owner:** [Contact Info]

---

**Created:** 27 November 2024
**Version:** 1.0.0
**Status:** ✅ Ready to use
