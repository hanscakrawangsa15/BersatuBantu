import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Debug screen untuk test file picker
class FilePickerDebugScreen extends StatefulWidget {
  const FilePickerDebugScreen({super.key});

  @override
  State<FilePickerDebugScreen> createState() => _FilePickerDebugScreenState();
}

class _FilePickerDebugScreenState extends State<FilePickerDebugScreen> {
  late String _debugLog;
  FilePickerResult? _selectedFile;

  @override
  void initState() {
    super.initState();
    _debugLog = 'Waiting for action...\n';
  }

  void _addLog(String message) {
    setState(() {
      _debugLog += '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
    print('[DEBUG] $message');
  }

  Future<void> _testFilePicker() async {
    _addLog('Starting FilePicker test...');
    
    try {
      _addLog('Calling FilePicker.platform.pickFiles()');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        allowMultiple: false,
      );

      if (result == null) {
        _addLog('❌ Result is NULL - User cancelled or error');
        return;
      }

      _addLog('✅ Got result with ${result.files.length} file(s)');

      if (result.files.isEmpty) {
        _addLog('❌ Files list is empty');
        return;
      }

      final file = result.files.first;
      _addLog('File name: ${file.name}');
      _addLog('File size: ${file.size} bytes');
      _addLog('File path: ${file.path}');
      _addLog('File has bytes: ${file.bytes != null}');
      _addLog('File bytes length: ${file.bytes?.length ?? 0}');

      setState(() {
        _selectedFile = result;
      });

      _addLog('✅ File picker completed successfully');
    } catch (e) {
      _addLog('❌ Exception: $e');
      _addLog('Exception type: ${e.runtimeType}');
    }
  }

  void _clearLog() {
    setState(() {
      _debugLog = 'Log cleared\n';
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Debug'),
        backgroundColor: const Color(0xFF768BBD),
      ),
      body: Column(
        children: [
          // Button area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _testFilePicker,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Test File Picker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF768BBD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _clearLog,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Selected file info
          if (_selectedFile != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ File Selected:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${_selectedFile!.files.first.name}'),
                  Text('Size: ${_selectedFile!.files.first.size} bytes'),
                  Text('Path: ${_selectedFile!.files.first.path}'),
                ],
              ),
            ),
          // Debug log
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugLog,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}