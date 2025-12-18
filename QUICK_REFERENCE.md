# Quick Reference - Volunteer Event Features

## 📍 File Locations

### New Models
| File | Purpose |
|------|---------|
| `lib/models/event_model.dart` | Event data structure |
| `lib/models/event_registration_model.dart` | Registration data structure |

### New Service
| File | Purpose |
|------|---------|
| `lib/services/volunteer_event_service.dart` | Database & business logic for events |

### New Provider
| File | Purpose |
|------|---------|
| `lib/providers/volunteer_event_provider.dart` | State management (ChangeNotifier) |

### New Screens (3 Features)
| Feature | File | Purpose |
|---------|------|---------|
| 6.13 | `lib/fitur/pilihdaftar/register_volunteer_screen.dart` | Register for volunteer events |
| 6.14 | `lib/fitur/kegiatansedangdiikuti/my_ongoing_events_screen.dart` | View ongoing events with tabs |
| 6.15 | `lib/fitur/kegiatanpernahdiikuti/my_past_events_screen.dart` | View past events with tabs |

---

## 🔑 Key Classes & Methods

### Event Model
```dart
Event.fromMap(map)          // Parse from Supabase
event.isUpcoming            // Bool: event hasn't started
event.isOngoing             // Bool: event is happening now
event.isCompleted           // Bool: event has finished
event.canRegister           // Bool: user can register
```

### EventRegistration Model
```dart
EventRegistration.fromMap(map)  // Parse from Supabase
reg.isActive                    // Bool: user can still attend
reg.isPast                      // Bool: event has ended
reg.displayStatus               // String: "Disetujui", "Ditolak", etc
```

### VolunteerEventService
```dart
fetchOpenVolunteerEvents()               // Get all open events
fetchFilteredVolunteerEvents(city?, q?)  // Filter events
registerForEvent(eventId, userId)        // Register user
fetchUserOngoingEvents(userId)           // Get active events
fetchUserPastEvents(userId)              // Get past events
isUserRegistered(eventId, userId)        // Check registration
```

### VolunteerEventProvider
```dart
loadOpenEvents()                         // Load all events
filterEvents(city?, searchQuery?)        // Filter by criteria
registerForEvent(eventId, userId)        // Register & update state
loadUserOngoingEvents(userId)            // Load active events
loadUserPastEvents(userId)               // Load historical events
```

---

## 🎯 UI Features by Screen

### Screen 6.13: Register Volunteer
```
┌─ Header ──────────────────────────────┐
│ Mendaftarkan Diri        [Search]     │
└───────────────────────────────────────┘
┌─ Filters ─────────────────────────────┐
│ [Filter] [City: Semua]                │
│ [Search field: Cari kegiatan...]      │
└───────────────────────────────────────┘
┌─ Event List ──────────────────────────┐
│ ┌─ Event Card ──────────────────────┐ │
│ │ [Cover Image]                    │ │
│ │ Title                            │ │
│ │ Org • Date • Location            │ │
│ │ [Share] [Jadi Volunteer]         │ │
│ └──────────────────────────────────┘ │
│ ┌─ Event Card ──────────────────────┐ │
│ │ ...                              │ │
│ └──────────────────────────────────┘ │
└───────────────────────────────────────┘
┌─ Bottom Sheet (Detail) ───────────────┐
│ Detail Kegiatan      [Close]          │
│ [Image]                               │
│ Title                                 │
│ Description                           │
│ [Daftar Sekarang] or [Sudah Terdaftar]│
└───────────────────────────────────────┘
```

### Screen 6.14: Ongoing Events
```
┌─ Header ──────────────────────────────┐
│ Lihat daftar kegiatan       [Search]  │
│ yang sedang diikuti                   │
└───────────────────────────────────────┘
┌─ Tabs ────────────────────────────────┐
│ [Berlangsung Active] [Selesai]        │
└───────────────────────────────────────┘
┌─ Event List (Berlangsung) ────────────┐
│ ┌─ Active Event Card ───────────────┐ │
│ │ [Cover Image]                    │ │
│ │ Title • Org • Date • Location    │ │
│ │ [Disetujui] Badge                │ │
│ │ [Berlangsung] [Telah Terdaftar]  │ │
│ └──────────────────────────────────┘ │
└───────────────────────────────────────┘
```

### Screen 6.15: Past Events
```
┌─ Header ──────────────────────────────┐
│ Lihat daftar kegiatan       [Search]  │
│ yang pernah diikuti                   │
└───────────────────────────────────────┘
┌─ Tabs ────────────────────────────────┐
│ [Berlangsung Active] [Selesai]        │
└───────────────────────────────────────┘
┌─ Event List (Berlangsung=Attended) ───┐
│ ┌─ Past Event Card ─────────────────┐ │
│ │ [Cover Image]                    │ │
│ │ Title • Org • Date Range • Loc   │ │
│ │ [Hadir] Badge                    │ │
│ │ [Selasai] [Berlangsung]          │ │
│ └──────────────────────────────────┘ │
└───────────────────────────────────────┘
```

---

## 💾 Database Queries

### Fetch Open Events
```sql
SELECT e.*, o.name as organization_name
FROM events e
JOIN organizations o ON e.organization_id = o.id
WHERE e.category = 'volunteer' 
  AND e.status != 'draft'
ORDER BY e.start_time ASC;
```

### Fetch User's Ongoing Events
```sql
SELECT er.*, e.title, e.start_time, e.end_time, e.location, 
       e.cover_image_url, o.name as organization_name
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN organizations o ON e.organization_id = o.id
WHERE er.user_id = 'USER_ID'
  AND er.status != 'cancelled'
  AND e.end_time > NOW()
ORDER BY er.registered_at DESC;
```

### Fetch User's Past Events
```sql
SELECT er.*, e.title, e.start_time, e.end_time, e.location, 
       e.cover_image_url, o.name as organization_name
FROM event_registrations er
JOIN events e ON er.event_id = e.id
JOIN organizations o ON e.organization_id = o.id
WHERE er.user_id = 'USER_ID'
  AND er.status != 'cancelled'
  AND e.end_time < NOW()
ORDER BY er.registered_at DESC;
```

### Register User
```sql
INSERT INTO event_registrations (event_id, user_id, status, registered_at)
VALUES ('EVENT_ID', 'USER_ID', 'approved', NOW());
```

---

## 🚦 Data Flow Diagram

### Registration Flow (6.13)
```
User → Screen Init
  ↓
Load Open Events (Service)
  ↓
Populate Provider.openEvents
  ↓
Display Event List
  ↓
User clicks Event
  ↓
Load Event Detail + Check Registration
  ↓
Show Bottom Sheet
  ↓
User clicks "Daftar"
  ↓
registerForEvent() → Supabase Insert
  ↓
Update Provider.isUserRegistered = true
  ↓
Show Success & Close
  ↓
Reload Event List
```

### View Ongoing Events Flow (6.14)
```
User → Screen Init
  ↓
Load User Ongoing Events (Service)
  ↓
Filter: end_time > NOW && status != cancelled
  ↓
Populate Provider.ongoingEvents
  ↓
Display Event List with Tabs
  ↓
User tabs "Berlangsung" (active events) / "Selesai" (pending)
  ↓
Filter list by isActive property
  ↓
Update UI with filtered events
```

### View Past Events Flow (6.15)
```
User → Screen Init
  ↓
Load User Past Events (Service)
  ↓
Filter: end_time < NOW && status != cancelled
  ↓
Populate Provider.pastEvents
  ↓
Display Event List with Tabs
  ↓
User tabs "Berlangsung" (attended) / "Selesai" (rejected/cancelled)
  ↓
Filter list by status
  ↓
Update UI with filtered events
```

---

## 🎨 Color Scheme

| Element | Color | Hex |
|---------|-------|-----|
| Primary Button | Blue | #768BBD |
| Header Background | Light Blue | #8FA3CC |
| Card Background | White | #FFFFFF |
| Text Primary | Dark Gray | #333333 |
| Text Secondary | Medium Gray | #666666 |
| Badge Success | Green | Varies |
| Badge Pending | Orange | Varies |
| Badge Info | Blue | Varies |

---

## 📋 Status Values

### Event Status
- `draft` - Not published
- `open` - Accepting registrations
- `closed` - No longer accepting
- `completed` - Event finished

### Registration Status
- `pending` - Waiting approval
- `approved` - Registered & confirmed
- `rejected` - Application rejected
- `attended` - Marked as attended
- `cancelled` - User cancelled

### Display Status (Indonesian)
- pending → "Menunggu Persetujuan"
- approved → "Disetujui"
- rejected → "Ditolak"
- attended → "Hadir"
- cancelled → "Dibatalkan"

---

## 🧪 Test Scenarios

### Test 1: Register for Event
1. Navigate to Register Volunteer screen
2. Verify events load with correct info
3. Click event → see detail
4. Click "Daftar Sekarang"
5. Verify registration success
6. Click same event again → "Anda Sudah Terdaftar" shows

### Test 2: View Ongoing Events
1. Navigate to Ongoing Events screen
2. Verify current registrations load
3. Toggle between "Berlangsung" / "Selesai" tabs
4. Verify correct filtering

### Test 3: View Past Events
1. Navigate to Past Events screen
2. Verify historical registrations load
3. Toggle between "Berlangsung" / "Selesai" tabs
4. Verify correct status filtering

---

## ✅ Pre-Integration Checklist

- [ ] Add `intl` to pubspec.yaml if missing
- [ ] Add `VolunteerEventProvider` to MultiProvider in main.dart
- [ ] Setup navigation routes for 3 screens
- [ ] Update BottomNavBar to link to new screens
- [ ] Verify Supabase tables have test data
- [ ] Test Supabase auth & user session
- [ ] Run `flutter clean && flutter pub get`
- [ ] Test each screen independently
- [ ] Test navigation between screens
- [ ] Verify dark mode compatibility (if applicable)

---

**For Complete Implementation Details**: See `FEATURE_IMPLEMENTATION_GUIDE.md`
**For Integration Checklist**: See `IMPLEMENTATION_CHECKLIST.md`
**For AI Agent Instructions**: See `.github/copilot-instructions.md`
