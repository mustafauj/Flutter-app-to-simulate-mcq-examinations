import '../network/network_service.dart';
import '../errors/app_errors.dart';
import '../../models/models.dart';

class UserRepository {
  final NetworkService _networkService;

  UserRepository(this._networkService);

  Future<List<User>> getUsers() async {
    try {
      final response = await _networkService.get('/users');
      if (response.success && response.data != null) {
        final List<dynamic> usersJson = response.data as List<dynamic>;
        return usersJson.map((json) {
          try {
            return User.fromJson(json);
          } catch (e) {
            print('Error parsing user JSON: $e');
            print('JSON data: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<User> createUser(User user) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>('/users', body: user.toJson());
      if (response.success && response.data != null) {
        return User.fromJson(response.data!);
      }
      throw Exception('Failed to create user');
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<User> updateUser(User user) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>('/users/${user.id}', body: user.toJson());
      if (response.success && response.data != null) {
        return User.fromJson(response.data!);
      }
      throw Exception('Failed to update user');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _networkService.delete('/users/$userId');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
