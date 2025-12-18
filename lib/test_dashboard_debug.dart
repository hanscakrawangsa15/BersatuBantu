import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testDashboardQuery() async {
  try {
    final supabase = Supabase.instance.client;
    
    print('\n\n========== DATABASE QUERY TEST START ==========\n');
    
    // Test 1: Query organization_request table
    print('[TEST 1] Querying organization_request table...');
    final allRecords = await supabase
        .from('organization_request')
        .select('*')
        .order('tanggal_request', ascending: false);
    
    print('[TEST 1] Total records: ${allRecords.length}');
    
    // Test 2: Query only pending records
    print('\n[TEST 2] Querying pending records (status=pending)...');
    final pendingRecords = await supabase
        .from('organization_request')
        .select('*')
        .eq('status', 'pending')
        .order('tanggal_request', ascending: false);
    
    print('[TEST 2] Pending records count: ${pendingRecords.length}');
    
    // Test 3: Show detailed data
    if (pendingRecords.isNotEmpty) {
      print('\n[TEST 3] Detailed analysis of first PENDING record:');
      final firstRecord = pendingRecords[0] as Map<String, dynamic>;
      
      print('[TEST 3] >>>>>> FULL RECORD JSON <<<<<<');
      print(firstRecord.toString());
      
      print('\n[TEST 3] Field-by-field breakdown:');
      firstRecord.forEach((key, value) {
        final valueStr = value?.toString() ?? 'NULL';
        final shortened = valueStr.length > 50 ? '${valueStr.substring(0, 50)}...' : valueStr;
        print('[TEST 3]   "$key": "$shortened" (type: ${value.runtimeType}, isNull: ${value == null}, isEmpty: ${value is String ? value.isEmpty : "N/A"})');
      });
      
      print('\n[TEST 3] Expected fields check:');
      print('[TEST 3]   request_id exists: ${firstRecord.containsKey('request_id')}, value: ${firstRecord['request_id']}');
      print('[TEST 3]   nama_organisasi exists: ${firstRecord.containsKey('nama_organisasi')}, value: ${firstRecord['nama_organisasi']}');
      print('[TEST 3]   nama_pemilik exists: ${firstRecord.containsKey('nama_pemilik')}, value: ${firstRecord['nama_pemilik']}');
      print('[TEST 3]   email_organisasi exists: ${firstRecord.containsKey('email_organisasi')}, value: ${firstRecord['email_organisasi']}');
      print('[TEST 3]   email_pemilik exists: ${firstRecord.containsKey('email_pemilik')}, value: ${firstRecord['email_pemilik']}');
      print('[TEST 3]   no_telpon_pemilik exists: ${firstRecord.containsKey('no_telpon_pemilik')}, value: ${firstRecord['no_telpon_pemilik']}');
      print('[TEST 3]   no_telpon_organisasi exists: ${firstRecord.containsKey('no_telpon_organisasi')}, value: ${firstRecord['no_telpon_organisasi']}');
      print('[TEST 3]   status exists: ${firstRecord.containsKey('status')}, value: ${firstRecord['status']}');
      
      // Test 4: Try explicit field selection
      print('\n[TEST 4] Testing explicit field selection (nama_organisasi, nama_pemilik, email_organisasi, no_telpon_organisasi):');
      try {
        final explicitFields = await supabase
            .from('organization_request')
            .select('nama_organisasi, nama_pemilik, email_organisasi, no_telpon_organisasi')
            .eq('status', 'pending')
            .limit(1);
        
        if (explicitFields.isNotEmpty) {
          print('[TEST 4] Explicit fields result:');
          final record = explicitFields[0] as Map<String, dynamic>;
          print('[TEST 4] Record keys: ${record.keys.toList()}');
          print('[TEST 4] Record: $record');
        }
      } catch (e) {
        print('[TEST 4] Error with explicit selection: $e');
      }
      
    } else {
      print('[TEST 2] ⚠️ No pending records found');
      
      // If no pending, check all records
      if (allRecords.isNotEmpty) {
        print('\n[TEST 3] Found ${allRecords.length} total records');
        print('[TEST 3] First record status: ${allRecords[0]['status']}');
        print('[TEST 3] First record keys: ${(allRecords[0] as Map<String, dynamic>).keys.toList()}');
      }
    }
    
    print('\n========== DATABASE QUERY TEST COMPLETE ==========\n');
    
  } catch (e, stackTrace) {
    print('\n[ERROR] Test failed: $e');
    print('[ERROR] Stack trace: $stackTrace');
  }
}
