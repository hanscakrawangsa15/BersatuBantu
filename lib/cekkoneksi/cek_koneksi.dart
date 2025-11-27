import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CekKoneksiPage extends StatefulWidget {
  const CekKoneksiPage({super.key});

  @override
  State<CekKoneksiPage> createState() => _CekKoneksiPageState();
}

class _CekKoneksiPageState extends State<CekKoneksiPage> {
  final supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await supabase
          .from('events')
          .select('id, title, description, city, category, start_time, status')
          .order('start_time', ascending: true);

      setState(() {
        _events = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Koneksi & Tabel Events'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchEvents,
        label: const Text('Reload'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Terjadi error:\n$_error',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(child: Text('Supabase terhubung, tapi tabel events kosong.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchEvents,
      child: ListView.separated(
        itemCount: _events.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final event = _events[index];

          final title = event['title'] ?? '';
          final desc = event['description'] ?? '';
          final city = event['city'] ?? '';
          final category = event['category'] ?? '';
          final status = event['status'] ?? '';
          final startTimeText = event['start_time']?.toString() ?? '-';

          return ListTile(
            title: Text(title),
            subtitle: Text(
              '$city • $category • $startTimeText\n$desc',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(status),
          );
        },
      ),
    );
  }
}
