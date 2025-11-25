import 'package:supabase_flutter/supabase_flutter.dart';

// Network Service Interface
abstract class NetworkService {
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? headers});
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers});
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers});
  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers});
  Future<void> logout();
  bool get isAuthenticated;
}

// API Response
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  
  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });
  
  factory ApiResponse.success(T data, [int? statusCode]) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }
  
  factory ApiResponse.failure(String error, [int? statusCode]) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

// Supabase Service Implementation
class SupabaseService implements NetworkService {
  final SupabaseClient _client = Supabase.instance.client;
  
  SupabaseService() {
    print('🌐 SupabaseService: Initialized');
  }
  
  @override
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? headers}) async {
    try {
      // Remove leading slash and handle query parameters
      String tableName = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      
      // Handle query parameters (e.g., '/users?college_id=123')
      if (tableName.contains('?')) {
        final parts = tableName.split('?');
        tableName = parts[0];
        final queryParams = parts[1];
        
        // Parse query parameters
        final params = <String, String>{};
        for (final param in queryParams.split('&')) {
          final keyValue = param.split('=');
          if (keyValue.length == 2) {
            params[keyValue[0]] = keyValue[1];
          }
        }
        
        // Apply filters
        var query = _client.from(tableName).select();
        for (final entry in params.entries) {
          query = query.eq(entry.key, entry.value);
        }
        
        final response = await query;
        return ApiResponse.success(response as T);
      } else {
        final response = await _client.from(tableName).select();
        return ApiResponse.success(response as T);
      }
    } on PostgrestException catch (e) {
      return ApiResponse.failure('Database error: ${e.message}', int.tryParse(e.code ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  @override
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      // Remove leading slash
      String tableName = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      
      print('🌐 SupabaseService: POST to $tableName');
      print('🌐 SupabaseService: Body: $body');
      
      final response = await _client
        .from(tableName)
        .insert(body ?? {})
        .select()
        .single();
      
      print('🌐 SupabaseService: Response: $response');
      return ApiResponse.success(response as T);
    } on PostgrestException catch (e) {
      print('❌ SupabaseService: PostgrestException: ${e.message} (Code: ${e.code})');
      return ApiResponse.failure('Database error: ${e.message}', int.tryParse(e.code ?? '0'));
    } catch (e) {
      print('❌ SupabaseService: Network error: $e');
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  @override
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      // Remove leading slash and extract ID from endpoint (assuming format: table/id)
      String cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final parts = cleanEndpoint.split('/');
      if (parts.length < 2) {
        return ApiResponse.failure('Invalid endpoint format');
      }
      
      final table = parts[0];
      final id = parts[1];
      
      final response = await _client
          .from(table)
          .update(body ?? {})
          .eq('id', id)
          .select()
          .single();
      
      return ApiResponse.success(response as T);
    } on PostgrestException catch (e) {
      return ApiResponse.failure('Database error: ${e.message}', int.tryParse(e.code ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  @override
  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers}) async {
    try {
      // Remove leading slash and extract ID from endpoint (assuming format: table/id)
      String cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final parts = cleanEndpoint.split('/');
      if (parts.length < 2) {
        return ApiResponse.failure('Invalid endpoint format');
      }
      
      final table = parts[0];
      final id = parts[1];
      
      await _client
          .from(table)
          .delete()
          .eq('id', id);
      
      return ApiResponse.success(null as T);
    } on PostgrestException catch (e) {
      return ApiResponse.failure('Database error: ${e.message}', int.tryParse(e.code ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  // Authentication methods
  Future<ApiResponse<Map<String, dynamic>>> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return ApiResponse.success({
          'user': response.user!.toJson(),
          'session': response.session?.toJson(),
        });
      } else {
        return ApiResponse.failure('Authentication failed');
      }
    } on AuthException catch (e) {
      return ApiResponse.failure('Auth error: ${e.message}', int.tryParse(e.statusCode ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> signUpWithEmail(String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      if (response.user != null) {
        return ApiResponse.success({
          'user': response.user!.toJson(),
          'session': response.session?.toJson(),
        });
      } else {
        return ApiResponse.failure('Registration failed');
      }
    } on AuthException catch (e) {
      return ApiResponse.failure('Auth error: ${e.message}', int.tryParse(e.statusCode ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  
  Future<ApiResponse<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.failure('Logout error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<void>> changePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return ApiResponse.success(null);
    } on AuthException catch (e) {
      return ApiResponse.failure('Password change error: ${e.message}', int.tryParse(e.statusCode ?? '0'));
    } catch (e) {
      return ApiResponse.failure('Network error: ${e.toString()}');
    }
  }
  
  // Get current user
  User? get currentUser => _client.auth.currentUser;
  
  // Get current session
  Session? get currentSession => _client.auth.currentSession;
  
  // Check if user is authenticated
  bool get isAuthenticated => _client.auth.currentUser != null;
  
  // Logout user
  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}

// Mock Service for Development
class MockNetworkService implements NetworkService {
  @override
  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock data for different endpoints
    if (endpoint == 'colleges') {
      return ApiResponse.success([
        {
          'id': '1',
          'name': 'Tech University',
          'code': 'TU',
          'description': 'Leading technology university with modern facilities',
          'primaryColor': '0xFF6366F1',
          'secondaryColor': '0xFF10B981',
          'createdAt': DateTime.now().toIso8601String(),
          'isActive': true,
        }
      ] as T);
    }
    
    return ApiResponse.failure('Mock service - Endpoint not implemented: $endpoint');
  }
  
  @override
  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (endpoint == '/auth/login') {
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;
      
      // Demo login credentials
      if (email == 'admin@demo.com' && password == 'admin123') {
        return ApiResponse.success({
          'id': 'demo_admin_1',
          'name': 'Demo Admin',
          'email': 'admin@demo.com',
          'role': 'superAdmin',
          'collegeId': '1',
          'departmentId': null,
          'year': null,
          'studentId': null,
          'employeeId': 'ADM001',
          'profilePicture': null,
          'canChangePassword': true,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        } as T);
      } else if (email == 'teacher@demo.com' && password == 'teacher123') {
        return ApiResponse.success({
          'id': 'demo_teacher_1',
          'name': 'Demo Teacher',
          'email': 'teacher@demo.com',
          'role': 'teacher',
          'collegeId': '1',
          'departmentId': '1',
          'year': null,
          'studentId': null,
          'employeeId': 'TCH001',
          'profilePicture': null,
          'canChangePassword': true,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        } as T);
      } else if (email == 'student@demo.com' && password == 'student123') {
        return ApiResponse.success({
          'id': 'demo_student_1',
          'name': 'Demo Student',
          'email': 'student@demo.com',
          'role': 'student',
          'collegeId': '1',
          'departmentId': '1',
          'year': 3,
          'studentId': 'STU001',
          'employeeId': null,
          'profilePicture': null,
          'canChangePassword': true,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        } as T);
      } else if (email == 'collegeadmin@demo.com' && password == 'collegeadmin123') {
        return ApiResponse.success({
          'id': 'demo_college_admin_1',
          'name': 'College Admin',
          'email': 'collegeadmin@demo.com',
          'role': 'admin',
          'collegeId': '1',
          'departmentId': null,
          'year': null,
          'studentId': null,
          'employeeId': 'COL_ADM001',
          'profilePicture': null,
          'canChangePassword': true,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        } as T);
      } else {
        return ApiResponse.failure('Invalid credentials. Try: admin@demo.com/admin123, teacher@demo.com/teacher123, student@demo.com/student123, or collegeadmin@demo.com/collegeadmin123');
      }
    }
    
    if (endpoint == '/auth/signup') {
      return ApiResponse.success({
        'id': 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        'name': body?['name'] ?? 'New User',
        'email': body?['email'] ?? 'user@demo.com',
        'role': body?['role'] ?? 'student',
        'collegeId': body?['collegeId'] ?? '1',
        'departmentId': body?['departmentId'],
        'year': body?['year'],
        'studentId': body?['studentId'],
        'employeeId': body?['employeeId'],
        'profilePicture': null,
        'canChangePassword': true,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      } as T);
    }
    
    return ApiResponse.failure('Mock service - Endpoint not implemented: $endpoint');
  }
  
  @override
  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success({'message': 'Updated successfully'} as T);
  }
  
  @override
  Future<ApiResponse<T>> delete<T>(String endpoint, {Map<String, String>? headers}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ApiResponse.success({'message': 'Deleted successfully'} as T);
  }
  
  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  
  @override
  bool get isAuthenticated => true; // Mock is always authenticated
}
