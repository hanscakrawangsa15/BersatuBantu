# BersatuBantu Template System - Quick Reference

## 🚀 Quick Start

### Import yang Paling Sering Digunakan
```dart
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/app-text-field.dart';
```

### Template Screen Minimal
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Judul Screen',
      bodyPadding: const EdgeInsets.all(16),
      body: Center(
        child: Text('Konten di sini'),
      ),
    );
  }
}
```

---

## 📦 Komponen yang Tersedia

| Komponen | File | Fungsi |
|----------|------|--------|
| **AppButton** | `app-button.dart` | Custom button dengan multiple variants |
| **AppTextField** | `app-text-field.dart` | Input field dengan validasi |
| **AppScaffold** | `app_scaffold.dart` | Base scaffold untuk semua screen |
| **FormLayout** | `form_layout.dart` | Layout khusus untuk form |
| **ActionCard** | `action_card.dart` | Card yang dapat diklik |
| **ListItemCard** | `action_card.dart` | List item dengan title/subtitle |
| **FeatureCard** | `feature_card.dart` | Card untuk feature/item |
| **AppBadge** | `feature_card.dart` | Badge untuk status/kategori |
| **AppDialog** | `app_dialog.dart` | Custom dialog |
| **AppSnackBar** | `app_dialog.dart` | Custom snackbar/toast |

---

## 🎨 Warna yang Sering Digunakan

```dart
// Primary
AppColors.primaryBlue          // Main color
AppColors.primaryBlueDark      // Untuk hover/pressed
AppColors.primaryBlueLight     // Untuk subtle elements

// Accents
AppColors.accentGreen          // Success/positive actions
AppColors.accentRed            // Negative/delete actions
AppColors.accentOrange         // Warning/attention
AppColors.accentYellow         // Highlight

// Text
AppColors.textPrimary          // Main text
AppColors.textSecondary        // Secondary text
AppColors.textTertiary         // Tertiary/hint text

// Background
AppColors.bgPrimary            // White background
AppColors.bgSecondary          // Light gray background
```

---

## 📝 Text Styles yang Sering Digunakan

```dart
// Untuk Heading
AppTextStyle.displaySmall      // Judul besar (24px)
AppTextStyle.headingLarge      // Heading (20px)
AppTextStyle.headingMedium     // Sub heading (18px)

// Untuk Content
AppTextStyle.bodyLarge         // Body utama (16px)
AppTextStyle.bodyMedium        // Body normal (14px)
AppTextStyle.bodySmall         // Body kecil (12px)

// Untuk Label
AppTextStyle.labelLarge        // Label besar
AppTextStyle.labelMedium       // Label normal
```

---

## ✅ Checklist untuk Membuat Screen Baru

- [ ] Extend `StatefulWidget` atau `StatelessWidget`
- [ ] Gunakan `AppScaffold` sebagai root widget
- [ ] Set `title` untuk AppBar
- [ ] Gunakan `bodyPadding` untuk spacing
- [ ] Gunakan komponen dari `core/widgets`
- [ ] Gunakan `AppColors` untuk semua warna
- [ ] Gunakan `AppTextStyle` untuk semua text
- [ ] Handle loading state dengan `isLoading`
- [ ] Tampilkan error dengan `AppSnackBar`
- [ ] Dispose controller di `onDispose`
- [ ] Test di berbagai ukuran screen

---

## 🔄 Common Patterns

### Pattern 1: Form dengan Validation
```dart
// 1. Declare controllers
final _controller = TextEditingController();
String? _error;

// 2. Add validation in TextField
AppTextField(
  controller: _controller,
  errorText: _error,
  onChanged: (_) => setState(() => _error = null),
)

// 3. Validate on submit
void _submit() {
  setState(() {
    _error = _controller.text.isEmpty ? 'Field is required' : null;
  });
  if (_error == null) {
    // proceed
  }
}
```

### Pattern 2: Loading State
```dart
// 1. Add loading flag
bool _isLoading = false;

// 2. Update button
AppButton(
  isLoading: _isLoading,
  onPressed: _handleSubmit,
)

// 3. Update on async operation
void _handleSubmit() async {
  setState(() => _isLoading = true);
  try {
    await performOperation();
    AppSnackBar.show(context, message: 'Success', type: SnackBarType.success);
  } catch (e) {
    AppSnackBar.show(context, message: 'Error: $e', type: SnackBarType.error);
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Pattern 3: List with Cards
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    final item = items[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FeatureCard(
        title: item.title,
        description: item.description,
        onTap: () => navigateToDetail(item.id),
      ),
    );
  },
)
```

### Pattern 4: Search Filter
```dart
// 1. Add search controller
final _searchController = TextEditingController();
List<Item> _filteredItems = [];

// 2. Update on search
void _handleSearch(String query) {
  setState(() {
    if (query.isEmpty) {
      _filteredItems = items;
    } else {
      _filteredItems = items
          .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  });
}

// 3. Show search field
AppTextField(
  controller: _searchController,
  hint: 'Search...',
  onChanged: _handleSearch,
  prefixIcon: Icon(Icons.search),
)
```

---

## 🐛 Troubleshooting

### Problem: TextField tidak tampil dengan benar
**Solution:** Pastikan AppTextField dibungkus dengan `SingleChildScrollView` atau Column dengan `shrinkWrap: true`

### Problem: Button text terpotong
**Solution:** Gunakan `SizedBox(width: double.infinity, child: AppButton(...))`

### Problem: Image tidak tampil di FeatureCard
**Solution:** Gunakan `imageProvider` parameter atau `image` parameter dengan Container

### Problem: Error text tidak hilang setelah diisi
**Solution:** Gunakan `onChanged: (_) => setState(() => _error = null)`

### Problem: Snackbar tidak muncul
**Solution:** Pastikan context memiliki Scaffold parent

---

## 📊 Spacing & Layout Guidelines

```dart
// Default paddings
const EdgeInsets.all(16)                    // Screen padding
const EdgeInsets.symmetric(horizontal: 16)  // Horizontal padding
const SizedBox(height: 16)                  // Large spacing
const SizedBox(height: 12)                  // Medium spacing
const SizedBox(height: 8)                   // Small spacing

// Common patterns
- Screen padding: 16px
- Between major sections: 24px
- Between minor sections: 16px
- Between form fields: 16px
- Between items: 12px
- Inside cards: 12px
```

---

## 🎯 Performance Tips

1. **Use const constructors** whenever possible
   ```dart
   const AppButton(...) // Good
   AppButton(...)       // Less optimal
   ```

2. **Lazy load lists** with pagination
   ```dart
   ListView.builder(...)  // Good for long lists
   ListView(...)          // Only for short lists
   ```

3. **Dispose controllers** in onDispose
   ```dart
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
   ```

4. **Check mounted** before setState in async operations
   ```dart
   Future.delayed(..., () {
     if (mounted) setState(() { ... });
   });
   ```

---

## 🔗 Related Files

- **Main file:** `lib/main.dart`
- **Routes:** `lib/core/app-route.dart`
- **Color definitions:** `lib/core/theme/app_colors.dart`
- **Typography:** `lib/core/theme/app_text_style.dart`
- **Theme config:** `lib/core/theme/app_theme.dart`
- **All widgets:** `lib/core/widgets/`
- **Full documentation:** `TEMPLATE_GUIDE.md`
- **Implementation examples:** `IMPLEMENTATION_EXAMPLES.dart`

---

## 📞 Support & Questions

Jika ada pertanyaan atau butuh bantuan, hubungi tech lead atau lihat `TEMPLATE_GUIDE.md` untuk dokumentasi lengkap.

---

**Last Updated:** 27 November 2024
**Template Version:** 1.0.0
