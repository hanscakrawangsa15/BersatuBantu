import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDebugScreen extends StatefulWidget {
  const ChatDebugScreen({super.key});

  @override
  State<ChatDebugScreen> createState() => _ChatDebugScreenState();
}

class _ChatDebugScreenState extends State<ChatDebugScreen> {
  final supabase = Supabase.instance.client;
  String _debugLog = 'Starting debug...\n';

  @override
  void initState() {
    super.initState();
    _runDebug();
  }

  Future<void> _runDebug() async {
    try {
      _addLog('1. Checking current user...');
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        _addLog('❌ No authenticated user!');
        return;
      }
      _addLog('✅ Current User ID: ${currentUser.id}');

      _addLog('\n2. Fetching all messages from table...');
      final allMessages = await supabase
          .from('messages')
          .select('*')
          .limit(100);
      _addLog('✅ Total messages in DB: ${allMessages.length}');
      
      if (allMessages.isNotEmpty) {
        _addLog('\nFirst message sample:');
        final first = allMessages[0];
        _addLog('  - id: ${first['id']}');
        _addLog('  - conversation_id: ${first['conversation_id']}');
        _addLog('  - sender_id: ${first['sender_id']}');
        _addLog('  - content: ${first['content']}');
        _addLog('  - created_at: ${first['created_at']}');
        _addLog('  - is_read: ${first['is_read']}');
      }

      _addLog('\n3. Fetching messages (schema: id, conversation_id, sender_id, content, created_at, is_read)...');
      final messages = await supabase
          .from('messages')
          .select('id, conversation_id, sender_id, content, created_at, is_read')
          .order('created_at', ascending: false)
          .limit(100);
      _addLog('✅ Messages returned: ${messages.length}');

      if (messages.isNotEmpty) {
        _addLog('\nGrouping messages by conversation_id...');
        Map<String, int> conversationGroups = {};
        
        for (var msg in messages) {
          final conversationId = msg['conversation_id'] as String?;
          final senderId = msg['sender_id'] as String?;
          String key = conversationId ?? senderId ?? 'unknown';
          
          conversationGroups[key] = (conversationGroups[key] ?? 0) + 1;
        }
        
        _addLog('✅ Unique conversations: ${conversationGroups.length}');
        for (var entry in conversationGroups.entries) {
          _addLog('  - Conversation: ${entry.key.substring(0, 8)}... (${entry.value} messages)');
        }

        _addLog('\n4. Loading profile names for senders...');
        Set<String> senderIds = {};
        for (var msg in messages) {
          if (msg['sender_id'] != null) {
            senderIds.add(msg['sender_id']);
          }
        }
        _addLog('✅ Unique senders: ${senderIds.length}');

        for (var senderId in senderIds.take(3)) {
          try {
            final profile = await supabase
                .from('profiles')
                .select('full_name')
                .eq('id', senderId)
                .maybeSingle();
            _addLog('  - ${senderId.substring(0, 8)}...: ${profile?['full_name'] ?? 'NOT FOUND'}');
          } catch (e) {
            _addLog('  - ${senderId.substring(0, 8)}...: ERROR - $e');
          }
        }

        _addLog('\n5. Checking RLS policies...');
        _addLog('✅ Can read messages: YES (if you see this)');

      } else {
        _addLog('❌ No messages returned from query!');
      }

    } catch (e) {
      _addLog('❌ ERROR: $e');
    }
  }

  void _addLog(String text) {
    setState(() {
      _debugLog += '$text\n';
    });
    print('[DEBUG] $text');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Debug'),
        backgroundColor: Colors.grey[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _debugLog,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.white,
            backgroundColor: Colors.grey[900],
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
