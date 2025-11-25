import '../network/network_service.dart';
import '../errors/app_errors.dart';
import '../../models/models.dart';

class AuthRepository {
  final NetworkService _networkService;

  AuthRepository(this._networkService);
  
  NetworkService get networkService => _networkService;

  Future<User?> login(String username, String password) async {
    try {
      // For now, we'll use a simple credential check
      // In a real implementation, this would authenticate with Supabase Auth
      final response = await _networkService.get('/users', headers: {'username': username});
      
      if (response.success && response.data != null) {
        final List<dynamic> usersJson = response.data as List<dynamic>;
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        
        // Find user by username (assuming username is stored in email or name field)
        final user = users.firstWhere(
          (u) => u.email == username || u.name == username,
          orElse: () => throw Exception('User not found'),
        );
        
        return user;
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // Clear any stored authentication state
      await _networkService.logout();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      // Check if user is authenticated and get current user
      if (_networkService.isAuthenticated) {
        final response = await _networkService.get('/users/me');
        if (response.success && response.data != null) {
          return User.fromJson(response.data!);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
