import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final String? conversationId;
  final String? senderId;
  final String senderName;

  const ChatDetailScreen({
    super.key,
    this.conversationId,
    this.senderId,
    required this.senderName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  RealtimeChannel? _messageChannel;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoadingMessages = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    print('[ChatDetail] initState - conversation: ${widget.conversationId}, sender: ${widget.senderId}');
    
    _currentUserId = supabase.auth.currentUser?.id;
    _loadMessages();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_messageChannel != null) {
      _messageChannel!.unsubscribe();
    }
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoadingMessages = true);

      if (_currentUserId == null) {
        print('[ChatDetail] No authenticated user');
        return;
      }

      // Load messages for this conversation
      List<dynamic> messages;

      if (widget.conversationId != null) {
        // Load messages with specific conversation_id
        messages = await supabase
            .from('messages')
            .select('id, conversation_id, sender_id, content, image_url, created_at, is_read')
            .eq('conversation_id', widget.conversationId!)
            .order('created_at', ascending: true);
      } else if (widget.senderId != null) {
        // Load messages with specific sender_id
        messages = await supabase
            .from('messages')
            .select('id, conversation_id, sender_id, content, image_url, created_at, is_read')
            .eq('sender_id', widget.senderId!)
            .order('created_at', ascending: true);
      } else {
        messages = [];
      }

      if (mounted) {
        setState(() {
          _messages = messages.cast<Map<String, dynamic>>();
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('[ChatDetail] Error loading messages: $e');
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  void _setupRealtimeListener() {
    try {
      // Listen untuk pesan baru menggunakan Realtime Subscriptions
      final channel = supabase.channel('public:messages');
      _messageChannel = channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'message',
            callback: (payload) {
              print('[ChatDetail] New message received: $payload');
              // Only reload if it's for this conversation
              final newMsg = payload.newRecord;
              if ((newMsg['conversation_id'] == widget.conversationId) ||
                  (newMsg['sender_id'] == widget.senderId)) {
                _loadMessages();
              }
            },
          )
          .subscribe();
    } catch (e) {
      print('[ChatDetail] Error setting up realtime listener: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      setState(() => _isSending = true);

      if (_currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Not authenticated')),
        );
        return;
      }

      final messageContent = _messageController.text.trim();

      // Insert message to database
      await supabase.from('messages').insert({
        'conversation_id': widget.conversationId,
        'sender_id': _currentUserId,
        'content': messageContent,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      _messageController.clear();
      
      // Reload messages
      await _loadMessages();
      
      if (mounted) {
        setState(() => _isSending = false);
      }
    } catch (e) {
      print('[ChatDetail] Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final time = DateTime.parse(timeStr);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF768BBD),
        elevation: 0,
        title: Text(
          widget.senderName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'CircularStd',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada pesan.\nMulai percakapan!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'CircularStd',
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByMe = message['sender_id'] == _currentUserId;
                          final timestamp = _formatTime(message['created_at']);

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: isSentByMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSentByMe
                                        ? const Color(0xFF8FA3CC)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isSentByMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['content'] ?? '',
                                        style: TextStyle(
                                          color: isSentByMe
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'CircularStd',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        timestamp,
                                        style: TextStyle(
                                          color: isSentByMe
                                              ? Colors.white70
                                              : Colors.grey[600],
                                          fontSize: 11,
                                          fontFamily: 'CircularStd',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),

          // Message Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  // Input Field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'CircularStd',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Color(0xFF768BBD)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send Button
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA3CC),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  
                  // Attachment Button
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Show attachment options
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.attach_file,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
