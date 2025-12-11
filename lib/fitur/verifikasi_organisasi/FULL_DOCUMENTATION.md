# Fitur Ajukan Verifikasi Akun Organisasi - Dokumentasi Lengkap

## 📋 Ringkasan
Fitur ini memungkinkan pengguna untuk mendaftar sebagai organisasi dan melakukan verifikasi akun organisasi mereka melalui alur langkah demi langkah (step-by-step flow).

## 🎯 Flow Pengguna

```
Splash Screen
    ↓
Role Selection Screen (Personal / Organisasi / Admin)
    ↓ [Klik "Organisasi"]
Owner Data Screen (Step 1)
  - Input: Nama, NIK, Alamat Pemilik
    ↓ [Lanjutkan]
Organization Data Screen (Step 2)
  - Input: ID Organisasi, Nama Legal, NPWP, Nomor Registrasi
    ↓ [Lanjutkan]
Documents Upload Screen (Step 3)
  - Upload: Akta, NPWP, Dokumen Lainnya (optional)
    ↓ [Kirim Verifikasi]
Verifying Screen (Step 4)
  - Status: Berkas sedang diverifikasi (loading animation)
    ↓ [Auto transition setelah proses verifikasi]
Success Screen (Step 5)
  - Message: Verifikasi berhasil
  - Action: Tombol "Masuk" → Navigate ke dashboard
```

## 📁 Struktur Direktori

```
lib/fitur/verifikasi_organisasi/
├── models/
│   └── verification_model.dart              # Model data verifikasi
├── providers/
│   └── verification_provider.dart           # State management (Provider)
├── screens/
│   ├── verification_flow.dart               # Main flow orchestrator
│   ├── owner_data_screen.dart               # Step 1: Data pemilik
│   ├── organization_data_screen.dart        # Step 2: Data organisasi
│   ├── documents_upload_screen.dart         # Step 3: Upload dokumen
│   ├── verifying_screen.dart                # Step 4: Verifikasi proses
│   └── success_screen.dart                  # Step 5: Sukses
├── README.md                                 # Dokumentasi singkat
├── INTEGRATION_EXAMPLE.dart                 # Contoh integrasi
└── FULL_DOCUMENTATION.md                    # File ini
```

## 🔧 Komponen Utama

### 1. **OrganizationVerificationData Model**
```dart
class OrganizationVerificationData {
  String? organizationId;
  String? ownerName;
  String? ownerNik;
  String? ownerAddress;
  String? orgLegalName;
  String? orgNpwp;
  String? orgRegistrationNo;
  String? docAktaPath;
  String? docNpwpPath;
  String? docOtherPath;
  
  // Validation methods
  bool get isOwnerDataComplete { ... }
  bool get isOrgDataComplete { ... }
  bool get isDocumentsComplete { ... }
}
```

### 2. **OrganizationVerificationProvider**
State management yang mengelola:
- Data verifikasi (owner, organisasi, dokumen)
- Step saat ini (0-4)
- Status loading
- Pesan terakhir

#### Methods:
- `setField(fieldName, value)` - Set field data
- `setDocumentPath(docType, path)` - Set dokumen path
- `nextStep()` - Ke step berikutnya
- `previousStep()` - Ke step sebelumnya
- `submitVerification()` - Submit ke database

### 3. **Screen Components**

#### Step 1: OwnerDataScreen
- Input fields: Nama, NIK, Alamat
- Progress indicator (4 step bar)
- Buttons: Kembali, Lanjutkan
- Validation: Semua field wajib diisi

#### Step 2: OrganizationDataScreen
- Input fields: ID Org, Nama Legal, NPWP, Nomor Registrasi
- Progress indicator
- Buttons: Kembali, Lanjutkan
- Validation: ID Org, Nama Legal, NPWP wajib diisi

#### Step 3: DocumentsUploadScreen
- Upload cards untuk 3 dokumen
- Icons & status indicators
- File upload handler
- Buttons: Kembali, Kirim Verifikasi
- Validation: Minimum Akta + NPWP harus upload

#### Step 4: VerifyingScreen
- Animation loading dengan scaling effect
- Progress bar linear
- Status text: "Berkas-Berkas mu Sedang di-Verifikasi!"
- Auto transition setelah 3 detik

#### Step 5: SuccessScreen
- Success icon dengan background circle
- Message text
- Button "Masuk" → Navigate ke home

## 💾 Database Schema

### Table: organization_verifications

```sql
CREATE TABLE public.organization_verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid REFERENCES public.organizations(id),
  owner_id uuid NOT NULL REFERENCES public.profiles(id),
  owner_name text NOT NULL,
  owner_nik text,
  owner_address text,
  org_legal_name text NOT NULL,
  org_npwp text,
  org_registration_no text,
  doc_akta_url text,
  doc_npwp_url text,
  doc_other_url text,
  status text NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')),
  admin_id uuid REFERENCES public.profiles(id),
  admin_notes text,
  created_at timestamp DEFAULT now(),
  reviewed_at timestamp
);
```

### Relations:
- `owner_id` → `profiles(id)` (Pemilik organisasi)
- `organization_id` → `organizations(id)` (Organisasi)
- `admin_id` → `profiles(id)` (Admin yang review)

## 🔗 Integrasi dengan Sistem Existing

### 1. Update Role Selection Screen
```dart
// Di lib/fitur/pilihrole/role_selection_screen.dart
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/verification_flow.dart';

// Saat user klik "Organisasi"
onPressed: _isLoading ? null : () {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const OrganizationVerificationFlow(),
    ),
  );
}
```

### 2. Add Routes di main.dart
```dart
MaterialApp(
  routes: {
    '/verification-org': (context) => ChangeNotifierProvider(
          create: (_) => OrganizationVerificationProvider(),
          child: const OrganizationVerificationFlow(),
        ),
  },
  // ... routes lainnya
)
```

## 📦 Dependencies

File ini menggunakan:
- `flutter/material.dart` - UI framework
- `provider/provider.dart` - State management
- `supabase_flutter/supabase_flutter.dart` - Backend

Pastikan sudah di `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  supabase_flutter: ^1.0.0
```

## 🎨 UI/UX Features

### Color Scheme
- Primary: `Color(0xFF768BBD)` - Ungu
- Success: `Color(0xFF4CAF50)` - Hijau
- Border: `Color(0xFFE0E0E0)` - Abu-abu terang
- Text Secondary: `Color(0xFF999999)` - Abu-abu tua

### Typography
- Title: 18pt, Bold
- Body: 14pt, Regular
- Helper: 12pt, Regular

### Animations
- Progress bar: Linear
- Verifying screen: Scale animation
- Navigation: Slide transition

## ⚙️ Penggunaan

### Basic Usage
```dart
// Import
import 'package:bersatubantu/fitur/verifikasi_organisasi/screens/verification_flow.dart';

// Navigate
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OrganizationVerificationFlow(),
  ),
);
```

### Advanced: Custom Provider Access
```dart
// Di widget manapun dalam flow
Consumer<OrganizationVerificationProvider>(
  builder: (context, provider, _) {
    print('Current step: ${provider.currentStep}');
    print('Owner name: ${provider.data.ownerName}');
    return Text('Step ${provider.currentStep}');
  },
)
```

## 📝 TODO & Future Improvements

- [ ] Implementasi file picker untuk upload dokumen
- [ ] Integrasi Supabase Storage untuk upload file
- [ ] Real-time verification status tracking
- [ ] Email notifications untuk status update
- [ ] Admin dashboard untuk review verifikasi
- [ ] Retry mechanism untuk failed uploads
- [ ] Document compression sebelum upload
- [ ] Progress tracking untuk multi-file upload
- [ ] Camera integration untuk scan dokumen
- [ ] Digital signature untuk dokumen

## 🐛 Known Issues & Workarounds

### Issue 1: File Upload Simulasi
Saat ini file upload masih simulasi. Untuk implementasi real:
1. Buka `lib/fitur/verifikasi_organisasi/providers/verification_provider.dart`
2. Cari method `uploadFile()`
3. Implementasi upload ke Supabase Storage

### Issue 2: Auto-transition dari Verifying ke Success
Saat ini menggunakan fixed delay 3 detik. Untuk real verification:
1. Implement polling ke server untuk check status
2. Atau gunakan real-time listener dari Supabase

## 🧪 Testing

### Manual Testing Steps:
1. Login & pilih Role "Organisasi"
2. Isi Owner Data & klik Lanjutkan
3. Isi Organization Data & klik Lanjutkan
4. Upload dokumen & klik Kirim Verifikasi
5. Wait untuk success screen

### Expected Results:
- ✅ Semua data tersimpan di database
- ✅ Status verifikasi = "pending"
- ✅ Success screen muncul setelah delay
- ✅ Klik "Masuk" navigate ke home

## 📞 Support & Questions

Jika ada pertanyaan atau issues, silakan check:
1. `README.md` - Dokumentasi singkat
2. `INTEGRATION_EXAMPLE.dart` - Contoh kode
3. Comment di setiap file
4. Database schema di atas

---

**Last Updated:** December 9, 2025
**Version:** 1.0.0
**Status:** Ready for Integration
