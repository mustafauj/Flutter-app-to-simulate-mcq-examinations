import '../network/network_service.dart';
import '../errors/app_errors.dart';
import '../../models/models.dart';

class DepartmentRepository {
  final NetworkService _networkService;

  DepartmentRepository(this._networkService);

  Future<List<Department>> getDepartments() async {
    try {
      final response = await _networkService.get('/departments');
      if (response.success && response.data != null) {
        final List<dynamic> departmentsJson = response.data as List<dynamic>;
        return departmentsJson.map((json) => Department.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  Future<Department> createDepartment(Department department) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>('/departments', body: department.toJson());
      if (response.success && response.data != null) {
        return Department.fromJson(response.data!);
      }
      throw Exception('Failed to create department');
    } catch (e) {
      print('Error creating department: $e');
      rethrow;
    }
  }

  Future<Department> updateDepartment(Department department) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>('/departments/${department.id}', body: department.toJson());
      if (response.success && response.data != null) {
        return Department.fromJson(response.data!);
      }
      throw Exception('Failed to update department');
    } catch (e) {
      print('Error updating department: $e');
      rethrow;
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    try {
      await _networkService.delete('/departments/$departmentId');
    } catch (e) {
      print('Error deleting department: $e');
      rethrow;
    }
  }
}
