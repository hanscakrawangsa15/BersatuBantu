import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Quick test screen untuk test authentication
class QuickAuthTestScreen extends StatefulWidget {
  const QuickAuthTestScreen({super.key});

  @override
  State<QuickAuthTestScreen> createState() => _QuickAuthTestScreenState();
}

class _QuickAuthTestScreenState extends State<QuickAuthTestScreen> {
  final supabase = Supabase.instance.client;
  final _emailController = TextEditingController(text: 'hamsterpro.hans@gmail.com');
  final _passwordController = TextEditingController(text: 'AkuHans!5');
  String _output = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _testRegister() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing Register...\n';
    });

    try {
      _appendOutput('Email: ${_emailController.text}');
      _appendOutput('Password: ${_passwordController.text}');
      _appendOutput('\n--- Starting Registration ---');
      
      // Test sign up
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': 'Test User'},
      );

      _appendOutput('✅ Auth SignUp Response:');
      _appendOutput('  User ID: ${response.user?.id}');
      _appendOutput('  Email: ${response.user?.email}');
      _appendOutput('  Session: ${response.session != null ? "EXISTS" : "NULL"}');

      if (response.user != null) {
        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 500));

        // Try to insert profile
        _appendOutput('\n--- Inserting Profile ---');
        try {
          await supabase.from('profiles').insert({
            'id': response.user!.id,
            'full_name': 'Test User',
            'email': _emailController.text.trim(),
            'role': null,
          });
          _appendOutput('✅ Profile inserted successfully');
        } catch (e) {
          _appendOutput('❌ Profile insert error: $e');
          
          // Try upsert
          _appendOutput('\n--- Trying Upsert ---');
          await supabase.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': 'Test User',
            'email': _emailController.text.trim(),
            'role': null,
          });
          _appendOutput('✅ Profile upserted successfully');
        }

        // Sign out
        _appendOutput('\n--- Signing Out ---');
        await supabase.auth.signOut();
        _appendOutput('✅ Signed out successfully');

        _appendOutput('\n✅ REGISTRATION TEST PASSED!');
      } else {
        _appendOutput('❌ User is null');
      }
    } catch (e) {
      _appendOutput('❌ ERROR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing Login...\n';
    });

    try {
      _appendOutput('Email: ${_emailController.text}');
      _appendOutput('Password: ${_passwordController.text}');
      _appendOutput('\n--- Starting Login ---');
      
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      _appendOutput('✅ Auth SignIn Response:');
      _appendOutput('  User ID: ${response.user?.id}');
      _appendOutput('  Email: ${response.user?.email}');
      _appendOutput('  Session: ${response.session != null ? "EXISTS" : "NULL"}');

      if (response.user != null) {
        _appendOutput('\n--- Fetching Profile ---');
        final profile = await supabase
            .from('profiles')
            .select('id, full_name, email, role')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (profile != null) {
          _appendOutput('✅ Profile found:');
          _appendOutput('  ID: ${profile['id']}');
          _appendOutput('  Name: ${profile['full_name']}');
          _appendOutput('  Email: ${profile['email']}');
          _appendOutput('  Role: ${profile['role']}');
          _appendOutput('  Role is null: ${profile['role'] == null}');
        } else {
          _appendOutput('❌ Profile not found');
        }

        _appendOutput('\n✅ LOGIN TEST PASSED!');
      } else {
        _appendOutput('❌ User is null');
      }
    } on AuthException catch (e) {
      _appendOutput('❌ AUTH ERROR: ${e.message}');
      _appendOutput('   Status: ${e.statusCode}');
    } catch (e) {
      _appendOutput('❌ ERROR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
      _output = 'Checking Current User...\n';
    });

    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        _appendOutput('ℹ️ No user currently logged in');
      } else {
        _appendOutput('✅ User is logged in:');
        _appendOutput('  ID: ${user.id}');
        _appendOutput('  Email: ${user.email}');
        
        // Check profile
        _appendOutput('\n--- Checking Profile ---');
        final profile = await supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
        
        if (profile != null) {
          _appendOutput('✅ Profile exists:');
          profile.forEach((key, value) {
            _appendOutput('  $key: $value');
          });
        } else {
          _appendOutput('❌ Profile not found');
        }
      }
    } catch (e) {
      _appendOutput('❌ ERROR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _listAllUsers() async {
    setState(() {
      _isLoading = true;
      _output = 'Listing All Users...\n';
    });

    try {
      final profiles = await supabase
          .from('profiles')
          .select('id, email, full_name, role')
          .order('created_at', ascending: false);
      
      _appendOutput('Total users: ${profiles.length}\n');
      
      for (var i = 0; i < profiles.length; i++) {
        final profile = profiles[i];
        _appendOutput('${i + 1}. ${profile['email']}');
        _appendOutput('   Name: ${profile['full_name']}');
        _appendOutput('   Role: ${profile['role']}');
        _appendOutput('   ID: ${profile['id']}\n');
      }
    } catch (e) {
      _appendOutput('❌ ERROR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTestUser() async {
    setState(() {
      _isLoading = true;
      _output = 'Deleting Test User...\n';
    });

    try {
      final email = _emailController.text.trim();
      _appendOutput('Deleting user: $email');
      
      // Delete from profiles
      await supabase
          .from('profiles')
          .delete()
          .eq('email', email);
      
      _appendOutput('✅ User deleted from profiles');
      _appendOutput('\nNote: Also delete from Authentication → Users in Supabase Dashboard');
    } catch (e) {
      _appendOutput('❌ ERROR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _appendOutput(String text) {
    setState(() {
      _output += '$text\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF768BBD),
      appBar: AppBar(
        title: const Text('Quick Auth Test'),
        backgroundColor: const Color(0xFF364057),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Credentials Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Test Register'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Test Login'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _checkCurrentUser,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Check User'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _listAllUsers,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text('List All'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteTestUser,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete User'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Output Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _output.isEmpty ? 'Output will appear here...' : _output,
                      style: const TextStyle(
                        color: Colors.greenAccent,
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
      ),
    );
  }
}