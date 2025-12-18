# Implementasi Fitur Volunteer Event - Panduan Lengkap

## Ringkasan Fitur

Telah diimplementasikan **3 fitur utama** untuk sistem manajemen volunteer events:

1. **[6.13] Mendaftarkan Diri ke Volunteer** - Pengguna individu dapat mencari dan mendaftar pada kegiatan volunteer
2. **[6.14] Lihat Daftar Kegiatan yang Sedang Diikuti** - Tampilkan kegiatan volunteer aktif dengan status berlangsung/selesai
3. **[6.15] Lihat Daftar Kegiatan yang Pernah diikuti** - Tampilkan riwayat kegiatan volunteer

## Struktur File & Implementasi

### 1. Models (lib/models/)
```
lib/models/
├── event_model.dart              # Model untuk Event
└── event_registration_model.dart # Model untuk EventRegistration
```

**File**: `lib/models/event_model.dart`
- Class `Event` dengan properties: id, organizationId, title, description, location, city, startTime, endTime, quota, status, coverImageUrl, dll
- Helper methods: `isUpcoming`, `isOngoing`, `isCompleted`, `isFull`, `canRegister`
- Factory constructor `fromMap()` untuk parsing dari Supabase

**File**: `lib/models/event_registration_model.dart`
- Class `EventRegistration` dengan properties: id, eventId, userId, status, registeredAt, eventTitle, eventStartTime, eventEndTime, etc
- Helper properties: `isActive`, `isPast`, `displayStatus`

### 2. Services (lib/services/)
```
File: lib/services/volunteer_event_service.dart
```

**Class `VolunteerEventService`** (Singleton Pattern)

Metode utama:
- `fetchOpenVolunteerEvents()` - Ambil semua event volunteer yang terbuka
- `fetchFilteredVolunteerEvents(city?, searchQuery?)` - Filter event berdasarkan kota & pencarian
- `registerForEvent(eventId, userId)` - Daftarkan user untuk event
- `cancelRegistration(registrationId)` - Batalkan pendaftaran
- `fetchUserOngoingEvents(userId)` - Ambil event aktif yang sedang diikuti user
- `fetchUserPastEvents(userId)` - Ambil event yang sudah selesai diikuti user
- `getEventById(eventId)` - Ambil detail event spesifik
- `isUserRegistered(eventId, userId)` - Cek apakah user sudah terdaftar

**Koneksi Database:**
- Query ke tabel `events` dengan join ke `organizations`
- Query ke tabel `event_registrations` dengan join ke `events`
- Auto-filter berdasarkan waktu (ongoing vs past)

### 3. Providers (lib/providers/)
```
File: lib/providers/volunteer_event_provider.dart
```

**Class `VolunteerEventProvider`** extends ChangeNotifier

State properties:
- `openEvents` - List event yang terbuka untuk mendaftar
- `filteredEvents` - Hasil filter event
- `ongoingEvents` - Event yang sedang diikuti user
- `pastEvents` - Event yang pernah diikuti user
- `selectedEvent` - Event detail yang sedang dilihat
- `isUserRegistered` - Status registrasi user untuk event

Metode publik:
- `loadOpenEvents()` - Load semua event terbuka
- `filterEvents(city?, searchQuery?)` - Filter event
- `registerForEvent(eventId, userId)` - Register untuk event
- `cancelRegistration(registrationId)` - Batalkan registrasi
- `loadUserOngoingEvents(userId)` - Load event aktif user
- `loadUserPastEvents(userId)` - Load event riwayat user
- `loadEventDetails(eventId, userId)` - Load detail event + cek registrasi
- `clearSelectedEvent()` - Clear event terpilih

### 4. UI Screens

#### **Screen 6.13: Register Volunteer - Mendaftarkan Diri**
```
File: lib/fitur/pilihdaftar/register_volunteer_screen.dart
```

**Widget**: `RegisterVolunteerScreen` (StatefulWidget)

Fitur:
- Header dengan title "Mendaftarkan Diri"
- Filter dan search untuk event
- City dropdown filter (Semua, Jakarta, Bandung, Surabaya, dll)
- Search input untuk cari event by title
- List event cards dengan:
  - Cover image
  - Title, organization, date/time, location
  - Button "Bagikan" (share)
  - Button "Jadi Volunteer" (register)
- Bottom sheet untuk event detail dengan:
  - Full event information
  - "Daftar Sekarang" button untuk register
  - Notification jika sudah terdaftar

**Komponen Tambahan:**
- `EventDetailBottomSheet` - Bottom sheet untuk detail event

**Status Loading:**
- Loading indicator saat fetch events
- "Tidak ada event ditemukan" message jika kosong

---

#### **Screen 6.14: Lihat Daftar Kegiatan yang Sedang Diikuti**
```
File: lib/fitur/kegiatansedangdiikuti/my_ongoing_events_screen.dart
```

**Widget**: `MyOngoingEventsScreen` (StatefulWidget)

Fitur:
- Header "Lihat daftar kegiatan yang sedang diikuti"
- **Tab buttons**: "Berlangsung" | "Selesai"
- List event dengan status filter:
  - **Tab Berlangsung**: event dengan status `active` dan belum berakhir
  - **Tab Selesai**: event yang sudah dimulai tapi belum berakhir
- Event cards menampilkan:
  - Cover image
  - Title, organization, date/time, location
  - Status badge (Menunggu Persetujuan / Disetujui / Ditolak)
  - Buttons: "Berlangsung" (info) dan "Telah Terdaftar" (status)
- "Tidak ada kegiatan" message jika kosong
- Auto-load event saat screen diinisialisasi

---

#### **Screen 6.15: Lihat Daftar Kegiatan yang Pernah diikuti**
```
File: lib/fitur/kegiatanpernahdiikuti/my_past_events_screen.dart
```

**Widget**: `MyPastEventsScreen` (StatefulWidget)

Fitur:
- Header "Lihat daftar kegiatan yang pernah diikuti"
- **Tab buttons**: "Berlangsung" | "Selesai"
- List event dengan status filter:
  - **Tab Berlangsung**: event dengan status `attended`
  - **Tab Selesai**: event dengan status lain (rejected, cancelled, etc)
- Event cards menampilkan:
  - Cover image
  - Title, organization, date range, location
  - Status badge (Hadir / Ditolak / Dibatalkan)
  - Buttons: "Selasai" (info) dan "Berlangsung" (detail)
- Display historical records dengan informasi lengkap
- "Tidak ada riwayat kegiatan" message jika kosong
- Auto-load event saat screen diinisialisasi

---

## Database Schema (Event Related)

```sql
-- Events table
CREATE TABLE events (
  id uuid PRIMARY KEY,
  organization_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  cover_image_url text,
  category text, -- 'volunteer' or 'donation'
  location text,
  city text,
  start_time timestamp,
  end_time timestamp,
  quota integer,
  status text, -- 'draft', 'open', 'closed', 'completed'
  created_at timestamp
);

-- Event registrations table
CREATE TABLE event_registrations (
  id uuid PRIMARY KEY,
  event_id uuid NOT NULL,
  user_id uuid NOT NULL,
  status text, -- 'pending', 'approved', 'rejected', 'attended', 'cancelled'
  registered_at timestamp
);
```

## Integrasi dengan Main App

### Navigation Integration Needed:
Tambahkan route ke main.dart atau navigation handler:
```dart
// Di onGenerateRoute atau setNamedRoutes
'/register_volunteer' => RegisterVolunteerScreen()
'/my_ongoing_events' => MyOngoingEventsScreen()
'/my_past_events' => MyPastEventsScreen()
```

### Provider Setup:
Tambahkan provider di main.dart MultiProvider:
```dart
ChangeNotifierProvider(
  create: (_) => VolunteerEventProvider(),
),
```

### Bottom Navbar Integration:
Update `BottomNavBar` index 2 (Aksi) untuk navigate ke:
- RegisterVolunteerScreen sebagai screen utama
- Link ke MyOngoingEventsScreen dan MyPastEventsScreen

## Alur Data & State Management

### Mendaftarkan Diri (6.13):
1. Load open volunteer events (service → provider)
2. User search/filter events
3. User tap "Jadi Volunteer" → show event detail
4. User confirm registration
5. Service insert ke `event_registrations`
6. Provider update state & notify listeners

### Lihat Event Sedang Diikuti (6.14):
1. Load user ongoing events (service → provider)
2. Filter events: `end_time > NOW` dan `status != cancelled`
3. Tab toggle untuk filter by status
4. Display cards dengan status badge

### Lihat Event Pernah Diikuti (6.15):
1. Load user past events (service → provider)
2. Filter events: `end_time < NOW` dan `status != cancelled`
3. Tab toggle untuk filter by completion status
4. Display dengan historical data

## Styling Consistency

**Color Scheme:**
- Primary: `#768BBD` (button primary, headers)
- Header BG: `#8FA3CC` (gradient header background)
- Text: CircularStd font family
- Border radius: 16-30px untuk rounded corners

**Layout Pattern:**
- Header section dengan blue background
- White rounded container untuk main content
- Card-based list with shadows
- Tab buttons untuk filtering
- Bottom navbar integration

## Dependency Requirements

Pastikan `pubspec.yaml` include:
```yaml
provider: ^6.0.5        # State management (sudah ada)
intl: ^0.19.0          # Date formatting (mungkin perlu ditambah)
supabase_flutter: ^2.5.0 # Database
```

## Testing Notes

- Service methods handle null cases dan error gracefully
- Provider notifies listeners setelah setiap state change
- UI shows loading states dan empty states
- Date formatting sesuai locale Indonesia (id_ID)
- Registration validation (prevent duplicate registration)

## Future Enhancements

1. Add real-time listener untuk event updates (RealtimeSubscription)
2. Implement "Mark Attended" functionality untuk event completed
3. Add rating/review setelah event selesai
4. Email notification untuk registration confirmation
5. Share event functionality (social sharing)
6. Undo/Edit registration capability
7. Calendar view untuk upcoming events
8. Event reminder notifications

---

**Last Updated**: December 15, 2025
**Status**: Implementation Complete
**Next Step**: Test integration dengan main.dart dan database
