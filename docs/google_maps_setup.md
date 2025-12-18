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

5) Setup untuk Web
- Tambahkan Google Maps JavaScript API script tag pada file `web/index.html` sebelum `flutter_bootstrap.js`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
```

- Ganti `YOUR_API_KEY` dengan API key Anda. Jika Anda menggunakan Places (autocomplete), sertakan `libraries=places`.
- Muat ulang halaman web setelah menambahkan script.
Notes:
- Autocomplete on web uses the Maps JavaScript `places` library (no CORS issues). If you previously saw "Failed to fetch" when calling the REST /place/autocomplete endpoint from the browser, switch to using the JS Places API (this project now uses it automatically when running on web).
- Make sure the Places API and Geocoding API are enabled in Google Cloud Console and that the key is unrestricted for local development or properly restricted for production.
- Deprecation: Google recommends using `google.maps.marker.AdvancedMarkerElement` over `google.maps.Marker` for new features. The web implementation in `google_maps_flutter_web` may still use `google.maps.Marker`. Migrating to `AdvancedMarkerElement` requires plugin changes or custom web interop; consider this when planning future updates. See:
  - https://developers.google.com/maps/deprecations
  - https://developers.google.com/maps/documentation/javascript/advanced-markers/migration

Note: The app will try to auto-inject the Maps JavaScript API at startup if you set `GOOGLE_MAPS_API_KEY` in `.env`. If you prefer not to rely on runtime injection, add the script tag to `web/index.html` manually.

- Location storage
  - `location_name`: will contain the human-readable place/address (text).
  - `location`: will contain latitude/longitude in JSONB format: `{ "lat": <number>, "lng": <number> }`.

Note: If you prefer not to run migrations from this repo, you can keep your database as-is; the Flutter client will write the chosen place name to `location_name` (text) and the coordinates to `location` (JSON/JSONB). If `location` does not exist or is not JSONB, you'll need to add or convert that column in Supabase (via the SQL editor) so the JSON data can be stored.

Quick SQL snippets for querying `location` JSONB in Supabase/Postgres:

- Get lat/lng as text:
  SELECT id, location->>'lat' AS lat, location->>'lng' AS lng FROM public.donation_campaigns;

- Find campaigns within bounding box:
  SELECT * FROM public.donation_campaigns
  WHERE (location->>'lat')::float BETWEEN :minLat AND :maxLat
    AND (location->>'lng')::float BETWEEN :minLng AND :maxLng;

- Find campaigns close to a point (approx using degrees):
  SELECT *, ((location->>'lat')::float - :lat)^2 + ((location->>'lng')::float - :lng)^2 AS dist_sq
  FROM public.donation_campaigns
  ORDER BY dist_sq LIMIT 20;



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

