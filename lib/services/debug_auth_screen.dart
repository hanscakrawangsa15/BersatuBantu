import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final supabase = Supabase.instance.client;
  String _debugInfo = 'Memuat...';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    StringBuffer info = StringBuffer();
    
    try {
      // 1. Cek session
      final session = supabase.auth.currentSession;
      info.writeln('📱 SESSION STATUS:');
      info.writeln(session != null ? '✅ Session EXISTS' : '❌ Session NULL');
      info.writeln('');
      
      // 2. Cek user
      final user = supabase.auth.currentUser;
      info.writeln('👤 USER STATUS:');
      info.writeln(user != null ? '✅ User EXISTS' : '❌ User NULL');
      
      if (user != null) {
        info.writeln('');
        info.writeln('📋 USER INFO:');
        info.writeln('ID: ${user.id}');
        info.writeln('Email: ${user.email}');
        info.writeln('Created: ${user.createdAt}');
        info.writeln('Metadata: ${user.userMetadata}');
        info.writeln('');
        
        // 3. Cek profile di database
        info.writeln('🔍 CHECKING DATABASE:');
        try {
          final response = await supabase
              .from('profiles')
              .select('*')
              .eq('id', user.id)
              .maybeSingle();
          
          if (response != null) {
            info.writeln('✅ Profile FOUND in database');
            info.writeln('Data: $response');
          } else {
            info.writeln('❌ Profile NOT FOUND in database');
            info.writeln('💡 Solution: Add profile to database');
          }
        } catch (e) {
          info.writeln('❌ Database query error: $e');
        }
      } else {
        info.writeln('');
        info.writeln('⚠️ USER NOT AUTHENTICATED');
        info.writeln('💡 Solution: Login first before accessing dashboard');
      }
      
    } catch (e) {
      info.writeln('❌ Error: $e');
    }
    
    setState(() {
      _debugInfo = info.toString();
    });
    
    // Print to console
    print('='.padRight(50, '='));
    print('AUTH DEBUG REPORT');
    print('='.padRight(50, '='));
    print(_debugInfo);
    print('='.padRight(50, '='));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FA3CC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF364057),
        title: const Text(
          'Debug Auth Status',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Authentication Debug Info',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF364057),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      _debugInfo,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _checkAuthStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Debug Info'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF364057),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  // Test login dengan user dari database
                  showDialog(
                    context: context,
                    builder: (context) => const TestLoginDialog(),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Test Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestLoginDialog extends StatefulWidget {
  const TestLoginDialog({super.key});

  @override
  State<TestLoginDialog> createState() => _TestLoginDialogState();
}

class _TestLoginDialogState extends State<TestLoginDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _message = '';

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.session != null) {
        setState(() {
          _message = '✅ Login successful!\nUser: ${response.user?.email}';
          _isLoading = false;
        });
        
        // Wait 2 seconds then close
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _message = '❌ Login failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Test Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _message,
              style: TextStyle(
                color: _message.contains('✅') ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _testLogin,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Login'),
        ),
      ],
    );
  }
}