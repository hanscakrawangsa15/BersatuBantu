import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug helper untuk login flow
class DebugLoginFlow {
  static final supabase = Supabase.instance.client;

  /// Check user profile dan role
  static Future<void> checkUserProfile() async {
    print('\n========== DEBUG LOGIN FLOW ==========');
    
    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('ERROR: No user logged in');
        return;
      }

      print('User ID: ${user.id}');
      print('User Email: ${user.email}');

      // Check profile
      final profile = await supabase
          .from('profiles')
          .select('id, full_name, email, role')
          .eq('id', user.id)
          .maybeSingle();

      print('\nProfile data:');
      if (profile != null) {
        print('  ID: ${profile['id']}');
        print('  Full Name: ${profile['full_name']}');
        print('  Email: ${profile['email']}');
        print('  Role: ${profile['role']} (type: ${profile['role'].runtimeType})');
        print('  Role is null: ${profile['role'] == null}');
        print('  Role isEmpty: ${(profile['role'] as String?)?.isEmpty ?? "N/A"}');
      } else {
        print('  Profile not found!');
      }

      print('\n========== END DEBUG ==========\n');
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Update role manually for testing
  static Future<void> updateRoleForTesting(String userId, String role) async {
    try {
      print('[Debug] Updating role for user $userId to $role');
      await supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
      print('[Debug] Role updated successfully');
    } catch (e) {
      print('[Debug] Error updating role: $e');
    }
  }
}
