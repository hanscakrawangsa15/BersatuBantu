import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper class untuk debug user data dari Supabase
class DebugUserData {
  static final supabase = Supabase.instance.client;

  /// Print semua informasi user yang tersedia
  static Future<void> printAllUserInfo() async {
    print('\n========== DEBUG USER DATA ==========');
    
    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('ERROR: No user logged in');
        return;
      }

      print('User ID: ${user.id}');
      print('User Email: ${user.email}');
      print('User Metadata: ${user.userMetadata}');
      print('User Created At: ${user.createdAt}');
      
      // Try to fetch from profiles table
      print('\n--- Attempting to fetch from profiles table ---');
      
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        print('SUCCESS: Profile found');
        print('Profile data: $response');
        print('Available columns: ${response.keys.toList()}');
        
        // Print each column
        response.forEach((key, value) {
          print('  $key: "$value" (type: ${value.runtimeType})');
        });
      } else {
        print('ERROR: No profile found for user ID: ${user.id}');
        
        // Try to list all profiles
        print('\n--- Listing all profiles in database ---');
        final allProfiles = await supabase
            .from('profiles')
            .select('id, full_name, email');
        
        print('Total profiles: ${allProfiles.length}');
        for (var profile in allProfiles) {
          print('  ID: ${profile['id']}, Name: ${profile['full_name']}, Email: ${profile['email']}');
        }
      }
    } catch (e, stackTrace) {
      print('EXCEPTION: $e');
      print('Stack trace: $stackTrace');
    }
    
    print('========== END DEBUG ==========\n');
  }

  /// Test query dengan berbagai metode
  static Future<void> testDifferentQueries() async {
    print('\n========== TESTING DIFFERENT QUERIES ==========');
    
    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('ERROR: No user logged in');
        return;
      }

      print('Testing with User ID: ${user.id}');
      
      // Test 1: Select all columns
      print('\n[Test 1] Select all columns');
      try {
        final result = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
        print('Result: $result');
      } catch (e) {
        print('Error: $e');
      }

      // Test 2: Select specific columns
      print('\n[Test 2] Select specific columns (full_name, email)');
      try {
        final result = await supabase
            .from('profiles')
            .select('full_name, email')
            .eq('id', user.id)
            .maybeSingle();
        print('Result: $result');
      } catch (e) {
        print('Error: $e');
      }

      // Test 3: Select with limit
      print('\n[Test 3] Select with limit 1');
      try {
        final result = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .limit(1)
            .maybeSingle();
        print('Result: $result');
      } catch (e) {
        print('Error: $e');
      }

      // Test 4: Get all profiles
      print('\n[Test 4] Get all profiles');
      try {
        final result = await supabase
            .from('profiles')
            .select('id, full_name, email');
        print('Total records: ${result.length}');
        for (var record in result) {
          print('  ${record['id']}: ${record['full_name']} (${record['email']})');
        }
      } catch (e) {
        print('Error: $e');
      }

    } catch (e, stackTrace) {
      print('EXCEPTION: $e');
      print('Stack trace: $stackTrace');
    }
    
    print('========== END TESTING ==========\n');
  }
}
