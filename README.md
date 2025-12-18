
![github](https://github.com/user-attachments/assets/213b88a7-d48c-4964-886e-4c5e10f53fed)

# BersatuBantu — Mobile App Project

> Digital donation ecosystem for Social News, Goods & Money Donation, Volunteer Events, and Account Verification.

---

## Tim Pengembang

Proyek ini dikembangkan oleh:

| Nama | NRP | GitHub |
|:---:|:---:|:---:|
| Daniel Setiawan | 5026231010 | eLlawliet|
| Izzuddin Hammadi Faiz | 5026231018 | freudian178 |
| Kevin Nathanael | 5026231079 | kevin-079 |
| Hans Christian Cakrawangsa | 5026231130 | hanscakrawangsa15 |
| Dzaky Ahmad | 5026231184 | Jek786 |
| Heber Bryan Hutajulu | 5026231204 | heberbryan |


---

## 🌟 Project Overview

BersatuBantu adalah aplikasi mobile berbasis Flutter (Dart) yang dibangun untuk memudahkan individu dan organisasi dalam melakukan donasi barang & uang, mengelola kegiatan volunteer, serta mendukung verifikasi akun organisasi secara bertahap oleh admin, lengkap dengan sistem tracking status dan fitur pesan/chat.

---

### 🎯 Fokus Pengembangan: Flutter Mobile App + Supabase sebagai BaaS (Database PostgreSQL & Storage)

### 🎯 MVP (Minimum Viable Product)

- Daftar akun + pemilihan role (Individu/Organisasi/Admin)
- Ajukan verifikasi akun organisasi (status: pending)
- Admin melakukan review approve/reject
- Notifikasi hasil verifikasi
- Posting donasi & kegiatan volunteer (khusus akun organisasi terverifikasi)
- Memberikan donasi barang/uang (individu)
- Melihat riwayat partisipasi kegiatan
- Chat antara individu ↔ organisasi

---

## 📁 Arsitektur Aplikasi
<pre>
lib/
 ├── main.dart
 ├── config/
 │    ├── theme.dart
 │    ├── supabase_config.dart
 │    └── app_colors.dart
 │
 ├── models/
 │    ├── user.dart
 │    ├── organization_verification.dart
 │    ├── social_post.dart
 │    ├── volunteer_event.dart
 │    ├── donation.dart
 │    └── message.dart
 │
 ├── services/
 │    ├── auth_service.dart
 │    ├── organization_verification_service.dart
 │    ├── social_post_service.dart
 │    ├── volunteer_service.dart
 │    ├── donation_service.dart
 │    └── message_service.dart
 │
 ├── providers/
 │    ├── auth_provider.dart
 │    ├── admin_verification_provider.dart
 │    ├── org_verification_provider.dart
 │    ├── social_provider.dart
 │    ├── volunteer_provider.dart
 │    ├── donation_provider.dart
 │    └── message_provider.dart
 │
 ├── screens/
 │    ├── splash_screen.dart
 │    ├── login_screen.dart
 │    ├── register_screen.dart
 │    ├── organization_verification_request_screen.dart
 │    ├── admin_verification_review_screen.dart
 │    ├── home_screen.dart
 │    ├── volunteer_screen.dart
 │    ├── donation_screen.dart
 │    ├── message_screen.dart
 │    └── profile_screen.dart
 │
 ├── widgets/
 │    ├── primary_button.dart
 │    ├── dropdown_picker.dart
 │    ├── form_field.dart
 │    ├── dashboard_card.dart
 │    ├── donation_card.dart
 │    ├── volunteer_tile.dart
 │    └── message_bubble.dart
 │
 └── utils/
      ├── file_upload_helper.dart
      ├── date_helper.dart
      └── validator.dart
</pre>

## Commit Message Convention 
### Format
 
`<type>(optional scope): <description>`
Example: `feat(pre-event): add speakers section`
 
### 1. Type
 
Available types are:
 
- feat → Changes about addition or removal of a feature. Ex: `feat: add table on landing page`, `feat: remove table from landing page`
- fix → Bug fixing, followed by the bug. Ex: `fix: illustration overflows in mobile view`
- docs → Update documentation (README.md)
- style → Updating style, and not changing any logic in the code (reorder imports, fix whitespace, remove comments)
- chore → Installing new dependencies, or bumping deps
- refactor → Changes in code, same output, but different approach
- test → Update testing suite, cypress files
- revert → when reverting commits
- perf → Fixing something regarding performance (deriving state, using memo, callback)
- vercel → Blank commit to trigger vercel deployment. Ex: `vercel: trigger deployment`
 
### 2. Optional Scope
 
Labels per page Ex: `feat(pre-event): add date label`
 
\*If there is no scope needed, you don't need to write it
 
### 3. Description
 
Description must fully explain what is being done.
 
Add BREAKING CHANGE in the description if there is a significant change.
 
**If there are multiple changes, then commit one by one**
 
- After colon, there are a single space Ex: `feat: add something`
- When using `fix` type, state the issue Ex: `fix: file size limiter not working`
- Use imperative, and present tense: "change" not "changed" or "changes"
- Don't use capitals in front of the sentence
- Don't add full stop (.) at the end of the sentence

## Troubleshooting: profile creation race / FK errors during registration ⚠️

If you see logs like:

```
[Register] Auth response user ID: <uuid>
[Register] FK error detected while inserting profile ... Key (id)=(...) is not present in table "users".
```

Possible causes and fixes:

- The database trigger that automatically creates a `profiles` row when a new `auth.users` row is inserted may not be applied. Ensure `db/migrations/20251216_create_profiles_trigger.sql` has been executed on your Supabase project (use the SQL editor or `supabase db query`).
- Verify the user actually exists in `auth.users`: `SELECT * FROM auth.users WHERE id = '<uuid>';` If the row is missing the signup didn't complete correctly.
- If the trigger is not available or you prefer a quick fallback, the server exposes a secure admin endpoint `/admin/create-profile` that can create/upsert a profile using the Supabase service role key. Configure `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` and `ADMIN_PROFILE_KEY` in `server/.env` then call the endpoint with header `x-admin-key` to request profile creation.

If you want the app to automatically request the server fallback, build the Flutter app with:

```
flutter run --dart-define=ADMIN_PROFILE_URL=https://your-server/admin/create-profile \
                  --dart-define=ADMIN_PROFILE_KEY=your_admin_key_here
```

This project includes a client-side attempt + poll strategy in `lib/fitur/auth/register/register_screen.dart` and the server-side fallback implemented in `server/index.js`.

Password reset (mobile deep-link) ⚠️
----------------------------------
If users click the password reset link from email and land on an unreachable localhost URL (or a page that doesn't open the app), configure Supabase Auth redirect URLs so mobile clients open your app:

1. Open your Supabase project → Authentication → Settings → URL Configuration.
2. Add the following to **Redirect URLs** (and/or Allowed Redirect URLs):
      - `io.supabase.bersatubantu://reset-password` (for mobile password recovery)
      - `io.supabase.bersatubantu://login-callback/` (for OAuth sign-ins used by the app)
      - `http://localhost:57986/#/reset-password` (useful for local web development)
3. Ensure the app handles the custom scheme:
      - Android: intent-filter for `io.supabase.bersatubantu` (already added in `android/app/src/main/AndroidManifest.xml`).
      - iOS: add `CFBundleURLTypes` (already added in `ios/Runner/Info.plist`).

When configured, clicking the reset link opens the app. The app listens for the password recovery auth event and navigates to `ResetPasswordScreen` where the user can set a new password; the app then calls `supabase.auth.updateUser(...)` which updates the password in the database so the user can sign in again with their new password.
