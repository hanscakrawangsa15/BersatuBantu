import 'package:flutter/material.dart';
import 'package:bersatubantu/services/diagnostic_org_request.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String _output = '';
  bool _isLoading = false;

  void _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _output = 'Running diagnostic...\n';
    });

    // Capture print output
    final originalPrint = print;
    final buffer = StringBuffer();

    // Override print temporarily
    printToBuffer(String message) {
      buffer.write('$message\n');
      originalPrint(message);
    }

    await testOrganizationRequestTable();

    setState(() {
      _output = buffer.toString();
      _isLoading = false;
    });
  }

  void _runInsertTest() async {
    setState(() {
      _isLoading = true;
      _output = 'Running insert test...\n';
    });

    await testInsertSimpleRecord();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic: Organization Request'),
        backgroundColor: const Color(0xFF768BBD),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runDiagnostic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF768BBD),
                    ),
                    child: const Text('Run Diagnostic'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runInsertTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Test Insert'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _output.isEmpty
                        ? 'Click "Run Diagnostic" to check organization_request table...'
                        : _output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
