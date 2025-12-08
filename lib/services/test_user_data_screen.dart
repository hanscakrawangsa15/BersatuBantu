import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'debug_user_data.dart';

class TestUserDataScreen extends StatefulWidget {
  const TestUserDataScreen({super.key});

  @override
  State<TestUserDataScreen> createState() => _TestUserDataScreenState();
}

class _TestUserDataScreenState extends State<TestUserDataScreen> {
  final supabase = Supabase.instance.client;
  String _debugOutput = 'Tekan tombol untuk memulai debug...';
  bool _isLoading = false;

  Future<void> _runDebug() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Loading...';
    });

    try {
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        setState(() {
          _debugOutput = 'ERROR: No user logged in';
          _isLoading = false;
        });
        return;
      }

      String output = 'USER INFO:\n';
      output += 'ID: ${user.id}\n';
      output += 'Email: ${user.email}\n';
      output += 'Metadata: ${user.userMetadata}\n\n';

      // Query database
      output += 'QUERYING DATABASE:\n';
      
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        output += 'SUCCESS: Profile found\n';
        output += 'Data: $response\n\n';
        
        final fullName = response['full_name'];
        output += 'full_name value: "$fullName"\n';
        output += 'full_name type: ${fullName.runtimeType}\n';
        output += 'full_name is null: ${fullName == null}\n';
        output += 'full_name isEmpty: ${fullName?.isEmpty ?? "N/A"}\n';
      } else {
        output += 'ERROR: No profile found\n';
        output += 'Listing all profiles:\n';
        
        final allProfiles = await supabase
            .from('profiles')
            .select('id, full_name, email');
        
        for (var profile in allProfiles) {
          output += '  ID: ${profile['id']}\n';
          output += '  Name: ${profile['full_name']}\n';
          output += '  Email: ${profile['email']}\n\n';
        }
      }

      setState(() {
        _debugOutput = output;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _debugOutput = 'ERROR: $e\n\nStack trace: $stackTrace';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug User Data'),
        backgroundColor: const Color(0xFF768BBD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _runDebug,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF768BBD),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Run Debug'),
            ),
            const SizedBox(height: 16),
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
                    _debugOutput,
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
