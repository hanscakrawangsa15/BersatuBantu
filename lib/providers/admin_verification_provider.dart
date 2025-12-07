import 'package:flutter/material.dart';
import '../services/organization_verification_service.dart';

class AdminVerificationProvider extends ChangeNotifier {
  final OrganizationVerificationService _service = OrganizationVerificationService();

  bool isLoading = false;
  String? lastMessage;
  List<Map<String, dynamic>> pendingRequests = [];

  Future<void> loadPending() async {
    isLoading = true;
    notifyListeners();
    try {
      pendingRequests = await _service.fetchPendingRequests();
      lastMessage = 'Loaded ${pendingRequests.length} pending requests';
    } catch (e) {
      lastMessage = 'Failed to load: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> approve(int id, {required String adminId}) async {
    try {
      await _service.updateVerificationStatus(id: id, status: 'approved', adminId: adminId, adminNotes: 'Your organization verification was approved.');
      lastMessage = 'Approved';
      // Remove locally
      pendingRequests.removeWhere((e) => e['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      lastMessage = 'Failed to approve: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(int id, {required String adminId, String? reason}) async {
    try {
      await _service.updateVerificationStatus(id: id, status: 'rejected', adminId: adminId, adminNotes: reason ?? 'Your organization verification was rejected.');
      lastMessage = 'Rejected';
      pendingRequests.removeWhere((e) => e['id'] == id);
      notifyListeners();
      return true;
    } catch (e) {
      lastMessage = 'Failed to reject: $e';
      notifyListeners();
      return false;
    }
  }
}
