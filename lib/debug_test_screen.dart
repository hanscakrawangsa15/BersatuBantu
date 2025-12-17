import 'package:flutter/material.dart';
import 'package:bersatubantu/test_dashboard_debug.dart';

class DebugTestScreen extends StatefulWidget {
  const DebugTestScreen({super.key});

  @override
  State<DebugTestScreen> createState() => _DebugTestScreenState();
}

class _DebugTestScreenState extends State<DebugTestScreen> {
  String _output = 'Click button to run tests...\n';
  bool _isLoading = false;

  void _runTest() async {
    setState(() {
      _isLoading = true;
      _output = 'Running test...\n';
    });

    // Capture print output
    final buffer = StringBuffer();
    final originalPrint = print;
    
    runZoned(
      () async {
        await testDashboardQuery();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          buffer.writeln(line);
          parent.print(zone, line);
        },
      ),
    );

    if (mounted) {
      setState(() {
        _output = buffer.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug Test'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTest,
              icon: const Icon(Icons.bug_report),
              label: const Text('Run Database Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black87,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    color: Colors.lime,
                    fontFamily: 'Courier',
                    fontSize: 11,
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

import 'dart:async';
