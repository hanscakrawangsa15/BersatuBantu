Langkah Mengambil dan Menggunakan Google Maps API Key

1) Buat API Key di Google Cloud Console
- Buka https://console.cloud.google.com/
- Pilih (atau buat) project baru
- Buka menu "APIs & Services" → "Credentials"
- Klik "Create credentials" → "API key"
- Salin API Key yang dihasilkan (jangan commit ke repo)

2) Aktifkan API yang dibutuhkan
- Masih di project yang sama, buka "Library"
- Aktifkan:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Geocoding API (opsional — dipakai untuk menampilkan alamat dari koordinat)

3) Batasi API Key (sangat disarankan)
- Di halaman Credentials, pilih key → "Edit"
- Under "Application restrictions":
  - Untuk Android: tambahkan package name + SHA-1 fingerprint
  - Untuk iOS: tambahkan bundle identifier
- Under "API restrictions": pilih hanya API yang diperlukan (Maps SDK for Android/iOS, Geocoding API)

4) Tempatkan key secara aman di proyek (contoh cara di repo ini)
- Tambahkan key ke file `.env` (file ini sudah ada di `.gitignore`), misalnya:
  GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
- Untuk Android: build script membaca `GOOGLE_MAPS_API_KEY` dari environment.
  - Saat build di CI atau lokal, set `GOOGLE_MAPS_API_KEY` environment variable.
  - Contoh (bash):
    export GOOGLE_MAPS_API_KEY="YOUR_API_KEY"
    flutter build apk
- Untuk iOS: tambahkan key ke `Info.plist` atau panggil `GMSServices.provideAPIKey("YOUR_API_KEY")` di `AppDelegate`.

5) File & konfigurasi yang sudah dibuat di repo ini
- `lib/fitur/postingkegiatandonasi/postingkegiatandonasi.dart`:
  - Menambahkan reverse geocoding (panggilan HTTP ke Geocoding API) untuk menampilkan alamat saat pengguna memilih di peta.
- `android/app/src/main/AndroidManifest.xml`:
  - Meta-data `com.google.android.geo.API_KEY` diisi dari manifest placeholder `${GOOGLE_MAPS_API_KEY}`.
- `android/app/build.gradle.kts`:
  - Menambahkan `manifestPlaceholders` yang mengambil `GOOGLE_MAPS_API_KEY` dari environment.

Contoh Android `AndroidManifest.xml` meta-data (sudah di-setup di repo):

```xml
<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="${GOOGLE_MAPS_API_KEY}" />
```

Contoh Swift (`ios/Runner/AppDelegate.swift`) untuk iOS (opsional jika mau set di kode):

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

6) Menjalankan secara lokal
- Set environment variable (Windows cmd):
  set GOOGLE_MAPS_API_KEY=YOUR_API_KEY
  flutter run
- Atau gunakan `.env` untuk aplikasi Dart (kebutuhan runtime geocoding):
  - Tambahkan `GOOGLE_MAPS_API_KEY` di `.env` dan pastikan `flutter_dotenv` memuatnya di `main.dart`.

7) Keamanan
- Jangan commit API key ke Git.
- Batasi key pada Google Cloud Console.

Jika mau, saya bisa:
- Menambahkan contoh `AppDelegate` Swift snippet untuk iOS.
- Tambahkan small README section di `README.md`.

