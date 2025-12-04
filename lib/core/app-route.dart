import 'package:flutter/widgets.dart';
import '../features/verification/organization_verification_form.dart';
import '../features/verification/admin_verification_review.dart';

class AppRoutes {
	static const verificationForm = '/verification/request';
	static const adminVerification = '/verification/admin';

	static Map<String, WidgetBuilder> routes() {
		return {
			verificationForm: (context) => const OrganizationVerificationForm(),
			adminVerification: (context) => const AdminVerificationReview(),
		};
	}
}

