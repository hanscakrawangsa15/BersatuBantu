import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk handle semua operasi Supabase
/// Gunakan service ini untuk semua operasi database dan auth
class SupabaseService {
  // Singleton pattern
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client
  final SupabaseClient _client = Supabase.instance.client;

  // Getter untuk auth
  GoTrueClient get auth => _client.auth;

  // Getter untuk database
  SupabaseClient get client => _client;

  /// Authentication Methods
  
  // Sign in dengan email & password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up dengan email & password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in dengan Google
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.bersatubantu://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign in dengan Apple
  Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.bersatubantu://login-callback/',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _client.auth.currentUser != null;

  // Stream auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Database Methods
  
  // Get data from table
  Future<List<Map<String, dynamic>>> getData(String table) async {
    try {
      final response = await _client.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Insert data to table
  Future<void> insertData(String table, Map<String, dynamic> data) async {
    try {
      await _client.from(table).insert(data);
    } catch (e) {
      rethrow;
    }
  }

  // Update data in table
  Future<void> updateData(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) async {
    try {
      await _client.from(table).update(data).eq(column, value);
    } catch (e) {
      rethrow;
    }
  }

  // Delete data from table
  Future<void> deleteData(
    String table,
    String column,
    dynamic value,
  ) async {
    try {
      await _client.from(table).delete().eq(column, value);
    } catch (e) {
      rethrow;
    }
  }

  /// Storage Methods (untuk upload file/gambar)
  
  // Upload file
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file,
  }) async {
    try {
      await _client.storage.from(bucket).upload(path, file);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      rethrow;
    }
  }

  // Get public URL
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}