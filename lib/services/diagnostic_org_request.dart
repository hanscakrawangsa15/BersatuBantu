import 'package:supabase_flutter/supabase_flutter.dart';

/// Diagnostic tool to test organization_request table directly
/// Run this to verify:
/// 1. Database connection
/// 2. Table schema
/// 3. Data in organization_request
Future<void> testOrganizationRequestTable() async {
  final supabase = Supabase.instance.client;

  print('========== DIAGNOSTIC: ORGANIZATION_REQUEST TABLE ==========\n');

  try {
    // Test 1: Fetch all records
    print('[Test 1] Fetching ALL records from organization_request...');
    final allRecords = await supabase
        .from('organization_request')
        .select('*');
    
    print('[Test 1] ✅ Total records: ${allRecords.length}');
    if (allRecords.isNotEmpty) {
      print('[Test 1] First record: ${allRecords[0]}');
    } else {
      print('[Test 1] ⚠️ No records found');
    }
    print('');

    // Test 2: Fetch only pending records
    print('[Test 2] Fetching PENDING records...');
    final pendingRecords = await supabase
        .from('organization_request')
        .select('*')
        .eq('status', 'pending');
    
    print('[Test 2] ✅ Pending records: ${pendingRecords.length}');
    if (pendingRecords.isNotEmpty) {
      print('[Test 2] First pending record: ${pendingRecords[0]}');
    }
    print('');

    // Test 3: Check specific fields
    print('[Test 3] Checking field values in first record...');
    if (allRecords.isNotEmpty) {
      final record = allRecords[0] as Map<String, dynamic>;
      print('[Test 3] request_id: ${record['request_id']}');
      print('[Test 3] nama_organisasi: ${record['nama_organisasi']}');
      print('[Test 3] nama_pemilik: ${record['nama_pemilik']}');
      print('[Test 3] email_organisasi: ${record['email_organisasi']}');
      print('[Test 3] email_pemilik: ${record['email_pemilik']}');
      print('[Test 3] no_telpon_pemilik: ${record['no_telpon_pemilik']}');
      print('[Test 3] no_telpon_organisasi: ${record['no_telpon_organisasi']}');
      print('[Test 3] akta_berkas: ${record['akta_berkas']}');
      print('[Test 3] npwp_berkas: ${record['npwp_berkas']}');
      print('[Test 3] other_berkas: ${record['other_berkas']}');
      print('[Test 3] status: ${record['status']}');
      print('[Test 3] tanggal_request: ${record['tanggal_request']}');
    }
    print('');

    // Test 4: Test RLS by fetching as admin
    print('[Test 4] Checking if admin can read data...');
    try {
      final adminQuery = await supabase
          .from('organization_request')
          .select('nama_organisasi, nama_pemilik, email_organisasi')
          .eq('status', 'pending')
          .limit(1);
      print('[Test 4] ✅ Admin can read (RLS not blocking)');
      print('[Test 4] Sample: $adminQuery');
    } catch (e) {
      print('[Test 4] ❌ RLS is blocking: $e');
    }
    print('');

    print('========== DIAGNOSTIC COMPLETE ==========');
  } catch (e, stackTrace) {
    print('[DIAGNOSTIC] ❌ ERROR: $e');
    print('[DIAGNOSTIC] Stack: $stackTrace');
  }
}

/// Also test if verification_provider is actually inserting data
Future<void> testInsertSimpleRecord() async {
  final supabase = Supabase.instance.client;

  print('\n========== TEST: INSERT SIMPLE RECORD ==========\n');

  try {
    print('[Insert] Attempting to insert test record...');
    
    final testData = {
      'nama_organisasi': 'Test Organisasi',
      'nama_pemilik': 'Test Pemilik',
      'email_organisasi': 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
      'email_pemilik': 'pemilik@test.com',
      'password_organisasi': 'hashed_password_test',
      'no_telpon_pemilik': '0812345678',
      'no_telpon_organisasi': '021987654',
      'akta_berkas': 'http://example.com/akta.pdf',
      'npwp_berkas': 'http://example.com/npwp.pdf',
      'other_berkas': 'http://example.com/other.pdf',
      'status': 'pending',
    };

    final response = await supabase
        .from('organization_request')
        .insert(testData)
        .select('request_id');

    print('[Insert] ✅ Success! Request ID: ${response[0]['request_id']}');
    
    // Verify it was inserted
    final verify = await supabase
        .from('organization_request')
        .select('*')
        .eq('request_id', response[0]['request_id']);
    
    print('[Insert] ✅ Verification: ${verify[0]}');
  } catch (e) {
    print('[Insert] ❌ ERROR: $e');
  }
}
