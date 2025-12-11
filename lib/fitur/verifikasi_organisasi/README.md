# Fitur Verifikasi Organisasi

## Deskripsi
Fitur ini memungkinkan pengguna yang memilih role "Organisasi" untuk melakukan verifikasi akun organisasi mereka melalui alur langkah demi langkah.

## Flow
1. **Role Selection** → User memilih "Organisasi" di halaman pilih role
2. **Owner Data Screen** → Mengisi data pemilik organisasi (nama, NIK, alamat)
3. **Organization Data Screen** → Mengisi data organisasi (ID, nama legal, NPWP, nomor registrasi)
4. **Documents Upload Screen** → Upload dokumen pendukung (Akta, NPWP, dan optional dokumen lainnya)
5. **Verifying Screen** → Menampilkan status verifikasi sedang berlangsung
6. **Success Screen** → Menampilkan pesan sukses dan tombol masuk

## Struktur File
```
lib/fitur/verifikasi_organisasi/
├── models/
│   └── verification_model.dart       # Model data verifikasi
├── providers/
│   └── verification_provider.dart    # State management dengan Provider
└── screens/
    ├── verification_flow.dart        # Main flow container
    ├── owner_data_screen.dart        # Step 1: Data pemilik
    ├── organization_data_screen.dart # Step 2: Data organisasi
    ├── documents_upload_screen.dart  # Step 3: Upload dokumen
    ├── verifying_screen.dart         # Step 4: Proses verifikasi
    └── success_screen.dart           # Step 5: Sukses
```

## Database Table
Menggunakan tabel `organization_verifications` di Supabase dengan field:
- `id` - UUID primary key
- `organization_id` - Reference ke organizations table
- `owner_id` - Reference ke profiles table (pemilik)
- `owner_name` - Nama pemilik
- `owner_nik` - NIK pemilik
- `owner_address` - Alamat pemilik
- `org_legal_name` - Nama legal organisasi
- `org_npwp` - NPWP organisasi
- `org_registration_no` - Nomor registrasi
- `doc_akta_url` - URL dokumen akta
- `doc_npwp_url` - URL dokumen NPWP
- `doc_other_url` - URL dokumen lainnya
- `status` - Status verifikasi (pending, approved, rejected)
- `admin_id` - ID admin yang verifikasi
- `admin_notes` - Catatan admin
- `created_at` - Waktu pembuatan
- `reviewed_at` - Waktu diverifikasi

## Penggunaan

### Dari Role Selection Screen
Ketika user mengklik button "Organisasi", akan langsung diarahkan ke `OrganizationVerificationFlow`.

### Navigasi
```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) => const OrganizationVerificationFlow(),
  ),
);
```

## Provider State Management
`OrganizationVerificationProvider` mengelola:
- Data verifikasi (owner, organisasi, dokumen)
- Step/tahap saat ini (0-4)
- Status loading
- Pesan terakhir

### Methods:
- `setField(fieldName, value)` - Set field data
- `setDocumentPath(docType, path)` - Set dokumen path
- `nextStep()` - Lanjut ke step berikutnya
- `previousStep()` - Kembali ke step sebelumnya
- `submitVerification()` - Submit verifikasi ke database

## UI Components
- Progress indicator (linear bar 4 step)
- Text form fields dengan validation
- Document upload cards dengan status
- Loading indicators
- Success/verifying animations

## TODO
- [ ] Implementasi file upload ke Supabase Storage
- [ ] Integrasi real-time verification status
- [ ] Add file picker untuk upload dokumen
- [ ] Admin dashboard untuk review verifikasi
- [ ] Email notification untuk update status
