import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen untuk reset user role (untuk debugging)
class ResetUserRoleScreen extends StatefulWidget {
  const ResetUserRoleScreen({super.key});

  @override
  State<ResetUserRoleScreen> createState() => _ResetUserRoleScreenState();
}

class _ResetUserRoleScreenState extends State<ResetUserRoleScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _message = '';

  Future<void> _resetCurrentUserRole() async {
    setState(() {
      _isLoading = true;
      _message = 'Loading...';
    });

    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _message = 'ERROR: No user logged in';
          _isLoading = false;
        });
        return;
      }

      print('[ResetRole] Resetting role for user: ${user.id}');

      // Reset role to NULL
      await supabase
          .from('profiles')
          .update({'role': null})
          .eq('id', user.id);

      setState(() {
        _message = 'SUCCESS: Role reset to NULL for user ${user.email}';
        _isLoading = false;
      });

      print('[ResetRole] Role reset successfully');
    } catch (e) {
      setState(() {
        _message = 'ERROR: ${e.toString()}';
        _isLoading = false;
      });
      print('[ResetRole] Error: $e');
    }
  }

  Future<void> _checkCurrentUserRole() async {
    setState(() {
      _isLoading = true;
      _message = 'Loading...';
    });

    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _message = 'ERROR: No user logged in';
          _isLoading = false;
        });
        return;
      }

      final profile = await supabase
          .from('profiles')
          .select('id, email, full_name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        setState(() {
          _message = 'ERROR: Profile not found';
          _isLoading = false;
        });
        return;
      }

      final role = profile['role'];
      setState(() {
        _message = '''
Current User Info:
ID: ${profile['id']}
Email: ${profile['email']}
Full Name: ${profile['full_name']}
Role: "$role" (type: ${role.runtimeType})
Role is null: ${role == null}
Role isEmpty: ${(role as String?)?.isEmpty ?? "N/A"}
        ''';
        _isLoading = false;
      });

      print('[ResetRole] Profile: $profile');
    } catch (e) {
      setState(() {
        _message = 'ERROR: ${e.toString()}';
        _isLoading = false;
      });
      print('[ResetRole] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset User Role (Debug)'),
        backgroundColor: const Color(0xFF768BBD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _checkCurrentUserRole,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF768BBD),
              ),
              child: const Text('Check Current User Role'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetCurrentUserRole,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Reset Role to NULL'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _message,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
