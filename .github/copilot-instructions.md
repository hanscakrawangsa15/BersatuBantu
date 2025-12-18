# Copilot / AI Agent Instructions — BersatuBantu

This file gives focused, actionable guidance for AI coding agents to be productive in this repository.

- Project type: Flutter mobile app (Dart) using Supabase as BaaS (Postgres + Storage + Auth).
- Runtime entry: [lib/main.dart](lib/main.dart) — loads `.env`, initializes Supabase, and contains auth/deep-link route handling.

Key services & patterns
- Supabase client wrapper: [lib/services/supabase.dart](lib/services/supabase.dart) — singleton `SupabaseService`, use this for all auth, DB and storage calls.
- Organization verification: [lib/services/organization_verification_service.dart](lib/services/organization_verification_service.dart) and provider [lib/providers/admin_verification_provider.dart](lib/providers/admin_verification_provider.dart). Storage bucket: `organization-proofs`, DB table: `organization_verifications`.
- Auth flows: password recovery and OAuth redirect handling live in [lib/main.dart](lib/main.dart); OAuth redirect scheme: `io.supabase.bersatubantu://login-callback/`.

Environment & secrets
- Environment vars loaded from `.env` (referenced in `pubspec.yaml` assets). Keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- Do not commit real secrets. The repo includes `.env` in assets for local dev — confirm presence before running.

Platform-specific notes
- File uploads behave differently on web vs mobile: web uses base64 bytes (see `uploadProofFile` in organization verification service), mobile uses `File` paths.
- Deep-link routing and password-recovery navigation are implemented in `MyApp` (see `onGenerateRoute` + auth listener in `lib/main.dart`). When simulating recovery flows, ensure the SDK session reflects a recovery event.

Developer workflows (commands)
- Install deps: `flutter pub get`
- Run on device/emulator: `flutter run` (run from repository root)
- Run tests: `flutter test`
- Lint/format: rely on `flutter format` / `dart format` as needed (project uses `flutter_lints`).

Repository conventions & expectations
- Services are singletons (e.g., `SupabaseService`) — prefer using them rather than creating new clients.
- State management: `provider` + `ChangeNotifier`. Providers live under `lib/providers/` and UI screens consume them.
- Commit message convention: follow the pattern in [README.md](README.md) (type(scope): description). Examples: `feat(donation): add donation flow`.

Files to inspect when making changes
- App bootstrap & routing: [lib/main.dart](lib/main.dart)
- Supabase wrapper: [lib/services/supabase.dart](lib/services/supabase.dart)
- Verification flow: [lib/services/organization_verification_service.dart](lib/services/organization_verification_service.dart) and [lib/providers/admin_verification_provider.dart](lib/providers/admin_verification_provider.dart)
- UI features grouped under `lib/fitur/` (screens split by features: `auth/`, `dashboard/`, `donasi/`, etc.)

Quick heuristics for edits
- If you change any Supabase table schema, update the corresponding service and provider that reads/writes it.
- When adding storage uploads, ensure both mobile (`File`) and web (base64) paths are considered.
- For auth-related changes, verify behavior for recovery flows and deep links (see `onAuthStateChange` usage in `lib/main.dart`).

When stuck or missing context
- Check `[README.md](README.md)` for project overview and commit conventions.
- Search for service or provider names under `lib/services/` and `lib/providers/` to find usages.

If you update this file: keep guidance short, include precise file examples, and avoid generic dev advice.

---
Please review and tell me if you'd like more detail on any subsystem (auth, storage, providers, or the verification workflow).
