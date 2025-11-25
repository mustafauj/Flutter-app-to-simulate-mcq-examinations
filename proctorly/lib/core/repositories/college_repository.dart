import '../network/network_service.dart';
import '../errors/app_errors.dart';
import '../../models/models.dart';

class CollegeRepository {
  final NetworkService _networkService;

  CollegeRepository(this._networkService);

  Future<List<College>> getColleges() async {
    try {
      final response = await _networkService.get('/colleges');
      if (response.success && response.data != null) {
        final List<dynamic> collegesJson = response.data as List<dynamic>;
        return collegesJson.map((json) => College.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching colleges: $e');
      return [];
    }
  }

  Future<College> createCollege(College college) async {
    try {
      print('🏛️ CollegeRepository: Creating college: ${college.name}');
      print('🏛️ CollegeRepository: College data: ${college.toJson()}');
      
      final response = await _networkService.post<Map<String, dynamic>>('/colleges', body: college.toJson());
      
      print('🏛️ CollegeRepository: Response success: ${response.success}');
      print('🏛️ CollegeRepository: Response data: ${response.data}');
      print('🏛️ CollegeRepository: Response error: ${response.error}');
      
      if (response.success && response.data != null) {
        final createdCollege = College.fromJson(response.data!);
        print('🏛️ CollegeRepository: Successfully created college: ${createdCollege.name}');
        return createdCollege;
      }
      throw Exception('Failed to create college: ${response.error}');
    } catch (e) {
      print('❌ CollegeRepository: Error creating college: $e');
      rethrow;
    }
  }

  Future<College> updateCollege(College college) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>('/colleges/${college.id}', body: college.toJson());
      if (response.success && response.data != null) {
        return College.fromJson(response.data!);
      }
      throw Exception('Failed to update college');
    } catch (e) {
      print('Error updating college: $e');
      rethrow;
    }
  }

  Future<void> deleteCollege(String collegeId) async {
    try {
      await _networkService.delete('/colleges/$collegeId');
    } catch (e) {
      print('Error deleting college: $e');
      rethrow;
    }
  }
}
