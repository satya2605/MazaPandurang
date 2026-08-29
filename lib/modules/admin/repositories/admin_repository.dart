import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/admin_models.dart';

class AdminRepository {
  final ApiClient _apiClient = ApiClient();

  Future<AdminDashboardStats> getDashboardStats() async {
    final response = await _apiClient.get('/admin/dashboard');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AdminDashboardStats.fromJson(json);
    }
    throw Exception('Failed to load Admin Dashboard stats (${response.statusCode})');
  }

  Future<List<AdminNgo>> getNgos({String? status}) async {
    final endpoint = status != null ? '/admin/ngos?status=$status' : '/admin/ngos';
    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminNgo.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> approveNgo(String id) async {
    final response = await _apiClient.patch('/admin/ngos/$id/approve');
    return response.statusCode == 200;
  }

  Future<bool> rejectNgo(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/ngos/$id/reject', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<String?> getNgoDocumentUrl(String ngoId, String documentId) async {
    final response = await _apiClient.get('/admin/ngos/$ngoId/documents/$documentId/url');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['url']?.toString();
    }
    return null;
  }

  Future<List<AdminService>> getServices({String? status, String? category}) async {
    String endpoint = '/admin/services';
    final params = <String>[];
    if (status != null) params.add('status=$status');
    if (category != null) params.add('category=$category');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminService.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> approveService(String id) async {
    final response = await _apiClient.patch('/admin/services/$id/approve');
    return response.statusCode == 200;
  }

  Future<bool> rejectService(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/services/$id/reject', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<bool> publishService(String id) async {
    final response = await _apiClient.patch('/admin/services/$id/publish');
    return response.statusCode == 200;
  }

  Future<bool> unpublishService(String id) async {
    final response = await _apiClient.patch('/admin/services/$id/unpublish');
    return response.statusCode == 200;
  }

  Future<List<AdminDindi>> getDindis({String? status}) async {
    final endpoint = status != null ? '/admin/dindis?status=$status' : '/admin/dindis';
    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminDindi.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> approveDindi(String id) async {
    final response = await _apiClient.patch('/admin/dindis/$id/approve');
    return response.statusCode == 200;
  }

  Future<bool> rejectDindi(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/dindis/$id/reject', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<bool> suspendDindi(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/dindis/$id/suspend', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<List<AdminDindiLeader>> getDindiLeaders({String? status}) async {
    final endpoint = status != null ? '/admin/dindi-leaders?status=$status' : '/admin/dindi-leaders';
    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminDindiLeader.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> approveDindiLeader(String id) async {
    final response = await _apiClient.patch('/admin/dindi-leaders/$id/approve');
    return response.statusCode == 200;
  }

  Future<bool> rejectDindiLeader(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/dindi-leaders/$id/reject', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<bool> suspendDindiLeader(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/dindi-leaders/$id/suspend', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<List<AdminLostPerson>> getLostPersons({String? status}) async {
    final endpoint = status != null ? '/admin/lost-persons?status=$status' : '/admin/lost-persons';
    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminLostPerson.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> approveLostPerson(String id) async {
    final response = await _apiClient.patch('/admin/lost-persons/$id/approve');
    return response.statusCode == 200;
  }

  Future<bool> rejectLostPerson(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/lost-persons/$id/reject', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<bool> closeLostPerson(String id, {String? reason}) async {
    final response = await _apiClient.patch('/admin/lost-persons/$id/close', body: {'reason': reason ?? ''});
    return response.statusCode == 200;
  }

  Future<List<AdminServiceReport>> getServiceReports({String? status}) async {
    final endpoint = status != null ? '/admin/service-reports?status=$status' : '/admin/service-reports';
    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminServiceReport.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> updateServiceReport(String id, {required String status, String? adminNotes}) async {
    final response = await _apiClient.patch('/admin/service-reports/$id', body: {
      'status': status,
      'admin_notes': adminNotes ?? '',
    });
    return response.statusCode == 200;
  }

  Future<List<AdminUser>> getUsers({String? role, String? status}) async {
    String endpoint = '/admin/users';
    final params = <String>[];
    if (role != null) params.add('role=$role');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _apiClient.get(endpoint);
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminUser.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> updateUserStatus(String id, String status) async {
    final response = await _apiClient.patch('/admin/users/$id/status', body: {'status': status});
    return response.statusCode == 200;
  }

  Future<List<AdminAuditLog>> getAuditLogs() async {
    final response = await _apiClient.get('/admin/audit-logs');
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => AdminAuditLog.fromJson(item)).toList();
    }
    return [];
  }

  // --- Palkhi Moderation & Operator Management ---

  Future<List<AdminPalkhi>> getPalkhis() async {
    try {
      final res = await _apiClient.get('/admin/palkhis');
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => AdminPalkhi.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> createPalkhi(Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.post('/admin/palkhis', body: payload);
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePalkhi(String id, Map<String, dynamic> payload) async {
    try {
      final res = await _apiClient.patch('/admin/palkhis/$id', body: payload);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> publishPalkhi(String id) async {
    try {
      final res = await _apiClient.patch('/admin/palkhis/$id/publish');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unpublishPalkhi(String id) async {
    try {
      final res = await _apiClient.patch('/admin/palkhis/$id/unpublish');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignPalkhiOperator(String id, String? operatorId) async {
    try {
      final res = await _apiClient.patch('/admin/palkhis/$id', body: {
        'assigned_operator_id': operatorId,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePalkhi(String id) async {
    try {
      final res = await _apiClient.delete('/admin/palkhis/$id');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

