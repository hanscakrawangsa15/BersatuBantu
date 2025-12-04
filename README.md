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

### Fokus Pengembangan: Flutter Mobile App + Supabase sebagai BaaS (Database PostgreSQL & Storage)

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
