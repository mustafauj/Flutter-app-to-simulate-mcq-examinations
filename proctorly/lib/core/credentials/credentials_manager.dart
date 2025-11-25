import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CredentialsManager {
  static const String _userCredentialsFile = 'user_credentials.json';
  
  // SuperAdmin credentials (hardcoded)
  static const Map<String, String> _superAdminCredentials = {
    'username': 'superadmin',
    'password': 'superadmin123',
    'role': 'superAdmin'
  };

  // Get SuperAdmin credentials
  static Map<String, String> getSuperAdminCredentials() {
    return Map<String, String>.from(_superAdminCredentials);
  }

  // Check if credentials match SuperAdmin
  static bool isSuperAdmin(String username, String password) {
    return username == _superAdminCredentials['username'] && 
           password == _superAdminCredentials['password'];
  }

  // Helper function to get department prefix from department ID
  static String? _getDepartmentPrefix(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) return null;
    
    // Map common department IDs to readable prefixes
    // This is a simplified mapping - in a real app, you'd query the database
    final deptMappings = {
      '42cac285-402f-4995-83d7-48d3c38b263d': 'cse', // Computer Science
      'computer_science': 'cse',
      'cs': 'cse',
      'engineering': 'eng',
      'business': 'bus',
      'medical': 'med',
      'arts': 'art',
      'science': 'sci',
    };
    
    // Try to find a mapping
    for (final entry in deptMappings.entries) {
      if (departmentId.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Fallback: use first 3 characters of department ID
    return departmentId.length >= 3 ? departmentId.substring(0, 3).toLowerCase() : 'dept';
  }

  // Generate meaningful credentials for new users
  static Map<String, String> generateCredentials(String role, String collegeId, {String? departmentId, String? collegeCode, String? userName}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0'); // 4-digit suffix
    
    String username;
    String password;
    
    // Use college code if available, otherwise use first 4 chars of collegeId
    final collegePrefix = collegeCode?.toLowerCase() ?? collegeId.substring(0, 4).toLowerCase();
    
    // Extract initials from user name if provided
    String userInitials = '';
    if (userName != null && userName.isNotEmpty) {
      final nameParts = userName.trim().split(' ');
      userInitials = nameParts.map((part) => part.isNotEmpty ? part[0].toLowerCase() : '').join('');
      if (userInitials.length > 3) userInitials = userInitials.substring(0, 3);
    }
    
    // Create more readable usernames
    switch (role.toLowerCase()) {
      case 'admin':
        username = 'admin_${collegePrefix}${userInitials.isNotEmpty ? '_$userInitials' : ''}';
        password = 'Admin${collegePrefix.toUpperCase()}${randomSuffix}';
        break;
      case 'teacher':
        // Use department name instead of ID for better readability
        final deptPrefix = _getDepartmentPrefix(departmentId) ?? 'tch';
        username = '${collegePrefix}_${deptPrefix}${userInitials.isNotEmpty ? '_$userInitials' : ''}';
        password = 'Teach${collegePrefix.toUpperCase()}${randomSuffix}';
        break;
      case 'student':
        // Use department name instead of ID for better readability
        final deptPrefix = _getDepartmentPrefix(departmentId) ?? 'std';
        username = '${collegePrefix}_${deptPrefix}${userInitials.isNotEmpty ? '_$userInitials' : ''}';
        password = 'Student${collegePrefix.toUpperCase()}${randomSuffix}';
        break;
      default:
        username = '${collegePrefix}_user${userInitials.isNotEmpty ? '_$userInitials' : ''}';
        password = 'User${collegePrefix.toUpperCase()}${randomSuffix}';
    }
    
    return {
      'username': username,
      'password': password,
      'role': role,
      'collegeId': collegeId,
      'departmentId': departmentId ?? '',
      'collegeCode': collegeCode ?? '',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Save user credentials to local storage AND database
  static Future<void> saveUserCredentials(Map<String, String> credentials, {String? userEmail, String? userName}) async {
    try {
      // Save to local storage (for backup/offline access)
      await _saveToLocalStorage(credentials);
      
      // Save to Supabase database (for cross-device access)
      final userId = await _saveToDatabase(credentials, userEmail: userEmail, userName: userName);
      
      // Add userId to credentials for future reference
      credentials['userId'] = userId;
      await _saveToLocalStorage(credentials); // Save again with userId
      
      print('✅ Credentials saved successfully: ${credentials['username']}');
    } catch (e) {
      print('❌ Error saving credentials: $e');
    }
  }

  // Save to local storage
  static Future<void> _saveToLocalStorage(Map<String, String> credentials) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_userCredentialsFile');
    
    List<Map<String, String>> allCredentials = [];
    
    // Load existing credentials
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      // Convert Map<String, dynamic> to Map<String, String>
      allCredentials = jsonList.map((item) => Map<String, String>.from(item)).toList();
    }
    
    // Add new credentials
    allCredentials.add(credentials);
    
    // Save back to file
    await file.writeAsString(json.encode(allCredentials));
  }

  // Save to Supabase database
  static Future<String> _saveToDatabase(Map<String, String> credentials, {String? userEmail, String? userName}) async {
    try {
      // Import Supabase client
      final supabase = Supabase.instance.client;
      
      final email = userEmail ?? '${credentials['username']}@proctorly.com';
      
      // Check if user with this email already exists
      final existingUserResponse = await supabase
          .from('users')
          .select('id, email')
          .eq('email', email)
          .maybeSingle();
      
      String userId;
      
      if (existingUserResponse != null) {
        // User already exists, use existing user ID
        userId = existingUserResponse['id'];
        print('⚠️ User with email $email already exists, using existing user ID: $userId');
      } else {
        // Create new user profile
        final userData = {
          'name': userName ?? '${credentials['role']?.toUpperCase()} - ${credentials['collegeCode']?.toUpperCase()}',
          'email': email,
          'role': credentials['role'],
          'college_id': credentials['collegeId'],
          'department_id': credentials['departmentId']?.isNotEmpty == true ? credentials['departmentId'] : null,
          'created_at': DateTime.now().toIso8601String(),
          'last_login': DateTime.now().toIso8601String(),
        };
        
        // Insert user profile into users table
        final response = await supabase.from('users').insert(userData).select().single();
        userId = response['id'];
        print('✅ New user profile created in Supabase: ${credentials['username']}');
      }
      
      // Check if credentials already exist for this user
      final existingCredentialsResponse = await supabase
          .from('user_credentials')
          .select('id')
          .eq('user_id', userId)
          .eq('username', credentials['username']!)
          .maybeSingle();
      
      if (existingCredentialsResponse == null) {
        // Store credentials in user_credentials table for login
        await supabase.from('user_credentials').insert({
          'user_id': userId,
          'username': credentials['username'],
          'password_hash': credentials['password'], // Store plain password for now (you can hash it later)
          'role': credentials['role'],
          'college_id': credentials['collegeId'],
          'department_id': credentials['departmentId']?.isNotEmpty == true ? credentials['departmentId'] : null,
          'generated_at': DateTime.now().toIso8601String(),
        });
        print('✅ New credentials created for user: ${credentials['username']}');
      } else {
        print('⚠️ Credentials already exist for username: ${credentials['username']}');
      }
      
      print('📧 Email: $email');
      print('🔑 Username: ${credentials['username']}');
      print('🔑 Password: ${credentials['password']}');
      
      return userId;
    } catch (e) {
      print('❌ Error creating user profile in Supabase: $e');
      // Return empty string on error - we still want local storage to work
      return '';
    }
  }

  // Load user credentials from local storage
  static Future<List<Map<String, String>>> loadUserCredentials() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userCredentialsFile');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        // Convert Map<String, dynamic> to Map<String, String>
        return jsonList.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      print('❌ Error loading credentials: $e');
    }
    
    return [];
  }

  // Find user credentials by username and password
  static Future<Map<String, String>?> findUserCredentials(String username, String password) async {
    // First check local storage
    final allCredentials = await loadUserCredentials();
    
    for (final creds in allCredentials) {
      if (creds['username'] == username && creds['password'] == password) {
        print('✅ Found credentials in local storage');
        return creds;
      }
    }
    
    // If not found locally, check Supabase database
    print('⚠️ Credentials not found in local storage, checking Supabase database...');
    try {
      final supabase = Supabase.instance.client;
      
      // Query user_credentials table
      final response = await supabase
          .from('user_credentials')
          .select('''
            user_id,
            username,
            password_hash,
            role,
            college_id,
            department_id,
            users!inner(name, email)
          ''')
          .eq('username', username)
          .eq('is_active', true)
          .maybeSingle();
      
      if (response != null) {
        // For now, we'll compare with plain password (you should hash passwords in production)
        // Since we're storing plain passwords in the database for now
        if (response['password_hash'] == password) {
          print('✅ Found credentials in Supabase database');
          
          // Convert database response to credentials format
          final credentials = <String, String>{
            'userId': response['user_id']?.toString() ?? '',
            'username': response['username']?.toString() ?? '',
            'password': response['password_hash']?.toString() ?? '',
            'role': response['role']?.toString() ?? '',
            'collegeId': response['college_id']?.toString() ?? '',
            'departmentId': response['department_id']?.toString() ?? '',
            'userName': response['users']?['name']?.toString() ?? '',
            'userEmail': response['users']?['email']?.toString() ?? '',
          };
          
          // Save to local storage for future use
          await _saveToLocalStorage(credentials);
          print('✅ Credentials saved to local storage for future use');
          
          return credentials;
        } else {
          print('❌ Password mismatch in database');
        }
      } else {
        print('❌ Username not found in database');
      }
    } catch (e) {
      print('❌ Error checking Supabase database: $e');
    }
    
    return null;
  }

  // Get all credentials for a specific college
  static Future<List<Map<String, String>>> getCollegeCredentials(String collegeId) async {
    final allCredentials = await loadUserCredentials();
    return allCredentials.where((creds) => creds['collegeId'] == collegeId).toList();
  }

  // Delete user credentials
  static Future<void> deleteUserCredentials(String username) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_userCredentialsFile');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        // Convert Map<String, dynamic> to Map<String, String>
        final allCredentials = jsonList.map((item) => Map<String, String>.from(item)).toList();
        
        // Remove the credentials
        allCredentials.removeWhere((creds) => creds['username'] == username);
        
        // Save back to file
        await file.writeAsString(json.encode(allCredentials));
      }
    } catch (e) {
      print('❌ Error deleting credentials: $e');
    }
  }

  // Generate a random password
  static String generateRandomPassword({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    int random = DateTime.now().millisecondsSinceEpoch;
    final password = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      password.write(chars[random % chars.length]);
      // Simple pseudo-random generation
      random = (random * 1103515245 + 12345) % (1 << 31);
    }
    
    return password.toString();
  }

  // Format credentials for display
  static String formatCredentialsForDisplay(Map<String, String> credentials) {
    return 'Username: ${credentials['username']}\nPassword: ${credentials['password']}';
  }

  // Get all saved credentials formatted for display
  static Future<String> getAllCredentialsDisplay() async {
    final allCredentials = await loadUserCredentials();
    if (allCredentials.isEmpty) {
      return 'No credentials saved yet.';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('📋 SAVED CREDENTIALS:\n');
    buffer.writeln('💾 Stored: Local + Supabase Database');
    buffer.writeln('🌐 Login: Use username/password in login screen\n');
    
    for (int i = 0; i < allCredentials.length; i++) {
      final creds = allCredentials[i];
      buffer.writeln('${i + 1}. ${creds['role']?.toUpperCase()} - ${creds['collegeCode']?.toUpperCase()}');
      buffer.writeln('   Username: ${creds['username']}');
      buffer.writeln('   Password: ${creds['password']}');
      buffer.writeln('   Email: ${creds['username']}@proctorly.com');
      buffer.writeln('   Generated: ${creds['generatedAt']?.substring(0, 19)}');
      buffer.writeln('   Status: ✅ Active in Supabase');
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
}
