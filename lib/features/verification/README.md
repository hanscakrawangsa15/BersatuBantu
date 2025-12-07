Verification feature

Routes:
- `/verification/request` : Organization verification submission form (for organization-role users)
- `/verification/admin` : Admin review screen listing pending organization_verifications

Tables used:
- `organization_verifications` with fields like `organization_name`, `owner_id`, `proof_urls`, `status`, `created_at`, etc.
- `notifications` for in-app notifications; service inserts a notification row when admin reviews.

Services & Providers:
- `lib/services/organization_verification_service.dart`
- `lib/providers/organization_verification_provider.dart`
- `lib/providers/admin_verification_provider.dart`

Usage:
- Add a route link to navigate: `Navigator.of(context).pushNamed('/verification/request')` or `/verification/admin`.
