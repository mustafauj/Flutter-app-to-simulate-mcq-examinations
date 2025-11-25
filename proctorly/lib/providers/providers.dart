import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/core/errors/app_errors.dart';
import 'package:proctorly/core/validation/validators.dart';
import 'package:proctorly/core/network/network_service.dart';
import 'package:proctorly/core/repositories/auth_repository.dart';
import 'package:proctorly/core/repositories/college_repository.dart';
import 'package:proctorly/core/repositories/department_repository.dart';
import 'package:proctorly/core/repositories/test_repository.dart';
import 'package:proctorly/core/repositories/user_repository.dart';

// Authentication Provider
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  
  // Dependencies
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider({
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  }) : _authRepository = authRepository,
       _prefs = prefs {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    print('🔄 AuthProvider: Starting to load user from storage');
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already authenticated with Supabase
      if (_authRepository.networkService is SupabaseService) {
        final supabaseService = _authRepository.networkService as SupabaseService;
        if (supabaseService.isAuthenticated) {
          print('📱 AuthProvider: User already authenticated with Supabase');
          // Get user profile from database
          try {
            final userResponse = await _authRepository.networkService.get<Map<String, dynamic>>(
              'users',
              headers: {'id': supabaseService.currentUser!.id},
            );
            
            if (userResponse.success && userResponse.data != null) {
              _currentUser = User.fromJson(userResponse.data!);
        _isAuthenticated = true;
              print('✅ AuthProvider: User loaded from Supabase: ${_currentUser!.name}');
            }
          } catch (e) {
            print('❌ AuthProvider: Error loading user profile: $e');
          }
        } else {
          print('📱 AuthProvider: No Supabase authentication found');
        }
      } else {
        print('📱 AuthProvider: Using mock service, no stored user data');
      }
    } catch (e) {
      print('❌ AuthProvider: Error loading user: $e');
      debugPrint('Error loading user: $e');
    } finally {
      print('✅ AuthProvider: Finished loading user, setting isLoading to false');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToStorage() async {
    if (_currentUser != null) {
      // User data is saved to Supabase through the repository
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<AuthResult> login(String email, String password) async {
    print('🔄 AuthProvider: Starting login for $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validate input
      print('🔍 AuthProvider: Validating input...');
      final emailValidation = Validators.validateEmail(email);
      if (!emailValidation.isValid) {
        print('❌ AuthProvider: Email validation failed: ${emailValidation.errors.first}');
        _error = emailValidation.errors.first;
        _isLoading = false;
        notifyListeners();
        return AuthResult.failure(_error!);
      }

      final passwordValidation = Validators.validatePassword(password);
      if (!passwordValidation.isValid) {
        print('❌ AuthProvider: Password validation failed: ${passwordValidation.errors.first}');
        _error = passwordValidation.errors.first;
        _isLoading = false;
        notifyListeners();
        return AuthResult.failure(_error!);
      }

      print('✅ AuthProvider: Input validation passed, calling authRepository.login...');
      // Attempt login
      final user = await _authRepository.login(email, password);
      print('✅ AuthProvider: AuthRepository returned user: ${user?.name} (${user?.role})');
      
      _currentUser = user;
      _isAuthenticated = true;
      await _saveUserToStorage();
      
      // Clear the logout flag since user is now authenticated
      await _prefs.setBool('was_authenticated', false);
      
      // Initialize real-time subscriptions
      _initializeRealtimeSubscriptions();
      
      _isLoading = false;
      print('🔄 AuthProvider: Calling notifyListeners() after successful login');
      notifyListeners();
      print('✅ AuthProvider: Login completed successfully');
      return AuthResult.success(user!);
      
    } on AuthError catch (e) {
      print('❌ AuthProvider: AuthError: ${e.message}');
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(e.message);
    } on NetworkError catch (e) {
      print('❌ AuthProvider: NetworkError: ${e.message}');
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(e.message);
    } catch (e) {
      print('❌ AuthProvider: Unexpected error: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return AuthResult.failure(_error!);
    }
  }

  // New login method that accepts a User object directly
  Future<AuthResult> loginWithUser(String username, String password, User user) async {
    print('🔄 AuthProvider: Starting direct login for $username');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Set the user directly
      _currentUser = user;
      _isAuthenticated = true;
      
      // Clear the logout flag since user is now authenticated
      await _prefs.setBool('was_authenticated', false);
      
      print('🔄 AuthProvider: Calling notifyListeners() after successful direct login');
      notifyListeners();
      print('✅ AuthProvider: Direct login completed successfully');
      return AuthResult.success(user);
    } catch (e) {
      print('❌ AuthProvider: Direct login error: $e');
      _isLoading = false;
      _error = 'Login failed: $e';
      notifyListeners();
      return AuthResult.failure('Login failed: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> logout() async {
    print('🔄 AuthProvider: Starting logout process');
    _currentUser = null;
    _isAuthenticated = false;
    
    // Set flag to indicate user was previously authenticated
    await _prefs.setBool('was_authenticated', true);
    await _prefs.remove('user');
    
    // Clean up real-time subscriptions
    _cleanupRealtimeSubscriptions();
    
    print('✅ AuthProvider: Logout completed, user is now unauthenticated');
    notifyListeners();
  }

  void _initializeRealtimeSubscriptions() {
    if (_currentUser == null) return;
    
    // This will be called from the UI context where RealtimeProvider is available
    // The actual subscription logic will be handled in the UI components
  }

  void _cleanupRealtimeSubscriptions() {
    // This will be called from the UI context where RealtimeProvider is available
    // The actual cleanup logic will be handled in the UI components
  }
}

// Enhanced Theme Provider with College Support
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  College? _currentCollege;
  Color? _customPrimaryColor;
  Color? _customSecondaryColor;

  bool get isDarkMode => _isDarkMode;
  College? get currentCollege => _currentCollege;
  Color? get customPrimaryColor => _customPrimaryColor;
  Color? get customSecondaryColor => _customSecondaryColor;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    
    // Load college-specific colors
    final primaryColorHex = prefs.getString('primaryColor');
    final secondaryColorHex = prefs.getString('secondaryColor');
    
    if (primaryColorHex != null) {
      _customPrimaryColor = Color(int.parse(primaryColorHex));
    }
    if (secondaryColorHex != null) {
      _customSecondaryColor = Color(int.parse(secondaryColorHex));
    }
    
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setCollege(College college) async {
    _currentCollege = college;
    _customPrimaryColor = Color(int.parse(college.primaryColor));
    _customSecondaryColor = Color(int.parse(college.secondaryColor));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('primaryColor', college.primaryColor);
    await prefs.setString('secondaryColor', college.secondaryColor);
    
    notifyListeners();
  }

  ThemeData get currentTheme {
    final primaryColor = _customPrimaryColor ?? AppConstants.primaryColor;
    final secondaryColor = _customSecondaryColor ?? AppConstants.secondaryColor;
    
    if (_isDarkMode) {
      return _buildDarkTheme(primaryColor, secondaryColor);
    } else {
      return _buildLightTheme(primaryColor, secondaryColor);
    }
  }

  ThemeData _buildLightTheme(Color primaryColor, Color secondaryColor) {
    return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: AppConstants.surfaceColor,
        background: AppConstants.backgroundColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConstants.neutral900,
        onBackground: AppConstants.neutral900,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: AppConstants.headingStyle.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        color: AppConstants.surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppConstants.headingStyle,
        headlineMedium: AppConstants.subheadingStyle,
        bodyLarge: AppConstants.bodyStyle,
        bodyMedium: AppConstants.bodyStyle,
        bodySmall: AppConstants.captionStyle,
        labelSmall: AppConstants.smallStyle,
      ),
    );
  }

  ThemeData _buildDarkTheme(Color primaryColor, Color secondaryColor) {
    return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      brightness: Brightness.dark,
        primary: AppConstants.darkPrimaryColor,
        secondary: AppConstants.darkSecondaryColor,
        surface: AppConstants.darkSurfaceColor,
        background: AppConstants.darkBackgroundColor,
        error: AppConstants.darkErrorColor,
        onPrimary: AppConstants.neutral900,
        onSecondary: AppConstants.neutral900,
        onSurface: AppConstants.neutral100,
        onBackground: AppConstants.neutral100,
        onError: AppConstants.neutral900,
      ),
      appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
        backgroundColor: AppConstants.darkSurfaceColor,
        foregroundColor: AppConstants.neutral100,
        titleTextStyle: AppConstants.headingStyle.copyWith(
          color: AppConstants.neutral100,
          fontSize: 20,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        color: AppConstants.darkSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.darkPrimaryColor,
          foregroundColor: AppConstants.neutral900,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppConstants.headingStyle,
        headlineMedium: AppConstants.subheadingStyle,
        bodyLarge: AppConstants.bodyStyle,
        bodyMedium: AppConstants.bodyStyle,
        bodySmall: AppConstants.captionStyle,
        labelSmall: AppConstants.smallStyle,
      ).apply(
        bodyColor: AppConstants.neutral100,
        displayColor: AppConstants.neutral100,
      ),
    );
  }
}

// Department Provider
class DepartmentProvider extends ChangeNotifier {
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _error;
  
  // Dependencies
  final DepartmentRepository _departmentRepository;

  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DepartmentProvider({
    required DepartmentRepository departmentRepository,
  }) : _departmentRepository = departmentRepository {
    loadDepartments();
  }

  void _loadDefaultDepartments() {
    _departments = [
      // Tech University departments
      Department(
        id: '1',
        name: 'Computer Science',
        code: 'CS',
        description: 'Computer Science and Engineering',
        collegeId: '1',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '2',
        name: 'Information Technology',
        code: 'IT',
        description: 'Information Technology and Systems',
        collegeId: '1',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '3',
        name: 'Data Science',
        code: 'DS',
        description: 'Data Science and Analytics',
        collegeId: '1',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      // Engineering College departments
      Department(
        id: '4',
        name: 'Mechanical Engineering',
        code: 'ME',
        description: 'Mechanical Engineering and Design',
        collegeId: '2',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '5',
        name: 'Electrical Engineering',
        code: 'EE',
        description: 'Electrical and Electronics Engineering',
        collegeId: '2',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '6',
        name: 'Civil Engineering',
        code: 'CE',
        description: 'Civil Engineering and Construction',
        collegeId: '2',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      // Business School departments
      Department(
        id: '7',
        name: 'Business Administration',
        code: 'BA',
        description: 'Business Administration and Management',
        collegeId: '3',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '8',
        name: 'Finance',
        code: 'FN',
        description: 'Finance and Banking',
        collegeId: '3',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      Department(
        id: '9',
        name: 'Marketing',
        code: 'MK',
        description: 'Marketing and Communications',
        collegeId: '3',
        createdAt: DateTime.now(),
        isActive: true,
      ),
    ];
    notifyListeners();
  }

  List<Department> getDepartmentsByCollege(String collegeId) {
    return _departments.where((dept) => dept.collegeId == collegeId).toList();
  }

  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _departmentRepository.getDepartments();
    } catch (e) {
      _error = e.toString();
      print('Error loading departments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDepartment(Department department) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdDepartment = await _departmentRepository.createDepartment(department);
      _departments.add(createdDepartment);
    } catch (e) {
      _error = e.toString();
      print('Error creating department: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDepartment(Department department) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDepartment = await _departmentRepository.updateDepartment(department);
      final index = _departments.indexWhere((d) => d.id == department.id);
      if (index != -1) {
        _departments[index] = updatedDepartment;
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating department: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _departmentRepository.deleteDepartment(departmentId);
      _departments.removeWhere((d) => d.id == departmentId);
    } catch (e) {
      _error = e.toString();
      print('Error deleting department: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// College Provider
class CollegeProvider extends ChangeNotifier {
  List<College> _colleges = [];
  College? _currentCollege;
  bool _isLoading = false;
  String? _error;
  
  // Dependencies
  final CollegeRepository _collegeRepository;

  List<College> get colleges => _colleges;
  College? get currentCollege => _currentCollege;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CollegeProvider({
    required CollegeRepository collegeRepository,
  }) : _collegeRepository = collegeRepository {
    loadColleges();
  }

  void _loadDefaultColleges() {
    _colleges = [
      College(
        id: '1',
        name: 'Tech University',
        code: 'TU',
        description: 'Leading technology university with modern facilities',
        primaryColor: '0xFF6366F1',
        secondaryColor: '0xFF10B981',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      College(
        id: '2',
        name: 'Engineering College',
        code: 'EC',
        description: 'Premier engineering institution',
        primaryColor: '0xFF8B5CF6',
        secondaryColor: '0xFF06B6D4',
        createdAt: DateTime.now(),
        isActive: true,
      ),
      College(
        id: '3',
        name: 'Business School',
        code: 'BS',
        description: 'Top-ranked business and management school',
        primaryColor: '0xFFEF4444',
        secondaryColor: '0xFFF59E0B',
        createdAt: DateTime.now(),
        isActive: true,
      ),
    ];
    notifyListeners();
  }

  Future<void> setCurrentCollege(College college) async {
    _currentCollege = college;
    notifyListeners();
  }

  Future<void> loadColleges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _colleges = await _collegeRepository.getColleges();
    } catch (e) {
      _error = e.toString();
      print('Error loading colleges: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<College> createCollege(College college) async {
    print('🏛️ CollegeProvider: Starting to create college: ${college.name}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🏛️ CollegeProvider: Calling collegeRepository.createCollege...');
      final createdCollege = await _collegeRepository.createCollege(college);
      print('🏛️ CollegeProvider: College created successfully, adding to list');
      _colleges.add(createdCollege);
      print('🏛️ CollegeProvider: College added to list. Total colleges: ${_colleges.length}');
      return createdCollege;
    } catch (e) {
      _error = e.toString();
      print('❌ CollegeProvider: Error creating college: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏛️ CollegeProvider: Finished creating college');
    }
  }

  Future<void> updateCollege(College college) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCollege = await _collegeRepository.updateCollege(college);
      final index = _colleges.indexWhere((c) => c.id == college.id);
      if (index != -1) {
        _colleges[index] = updatedCollege;
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating college: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCollege(String collegeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _collegeRepository.deleteCollege(collegeId);
      _colleges.removeWhere((c) => c.id == collegeId);
    } catch (e) {
      _error = e.toString();
      print('Error deleting college: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Language Provider
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    notifyListeners();
  }
}

// Test Provider
class TestProvider extends ChangeNotifier {
  List<Test> _tests = [];
  List<Test> _draftTests = [];
  bool _isLoading = false;
  String? _error;
  
  // Dependencies
  final TestRepository _testRepository;

  List<Test> get tests => _tests;
  List<Test> get draftTests => _draftTests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestRepository get testRepository => _testRepository;

  TestProvider({
    required TestRepository testRepository,
  }) : _testRepository = testRepository {
    loadTests();
  }

  Future<void> loadTests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tests = await _testRepository.getTests();
      _draftTests = _tests.where((test) => test.status == TestStatus.draft).toList();
    } catch (e) {
      _error = e.toString();
      print('Error loading tests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTest(Test test) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 TestProvider: Creating test - ${test.title}');
      final createdTest = await _testRepository.createTest(test);
      print('✅ TestProvider: Test created successfully - ID: ${createdTest.id}');
      
      // Add to both lists
      _tests.add(createdTest);
      _draftTests.add(createdTest);
      
      print('📋 TestProvider: Test added to lists - Total tests: ${_tests.length}, Draft tests: ${_draftTests.length}');
    } catch (e) {
      _error = e.toString();
      print('❌ TestProvider: Error creating test: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTest(Test test) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update in draft tests
      final draftIndex = _draftTests.indexWhere((t) => t.id == test.id);
      if (draftIndex != -1) {
        _draftTests[draftIndex] = test;
      }
      
      // Update in published tests
      final publishedIndex = _tests.indexWhere((t) => t.id == test.id);
      if (publishedIndex != -1) {
        _tests[publishedIndex] = test;
      }
      
      // Update in Supabase
      await _testRepository.updateTest(test);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTest(String testId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _draftTests.removeWhere((t) => t.id == testId);
      _tests.removeWhere((t) => t.id == testId);
      
      // Delete from Supabase
      await _testRepository.deleteTest(testId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> publishTest(String testId) async {
    final testIndex = _draftTests.indexWhere((t) => t.id == testId);
    if (testIndex != -1) {
      final test = _draftTests[testIndex];
      final publishedTest = Test(
        id: test.id,
        title: test.title,
        description: test.description,
        createdBy: test.createdBy,
        collegeId: test.collegeId,
        departmentId: test.departmentId,
        startTime: test.startTime,
        endTime: test.endTime,
        durationMinutes: test.durationMinutes,
        status: TestStatus.published,
        questions: test.questions,
        createdAt: test.createdAt,
        publishedAt: DateTime.now(),
      );
      
      _tests.add(publishedTest);
      _draftTests.removeAt(testIndex);
      notifyListeners();
    }
  }

  List<Test> searchTests(String query) {
    if (query.isEmpty) return _tests;
    
    return _tests.where((test) {
      return test.title.toLowerCase().contains(query.toLowerCase()) ||
             test.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Test> filterTestsByDate(DateTime date) {
    return _tests.where((test) {
      final testDate = DateTime(test.startTime.year, test.startTime.month, test.startTime.day);
      final filterDate = DateTime(date.year, date.month, date.day);
      return testDate.isAtSameMomentAs(filterDate);
    }).toList();
  }

  List<Test> getTestsForWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _tests.where((test) {
      return test.startTime.isAfter(startOfWeek) && test.startTime.isBefore(endOfWeek);
    }).toList();
  }

  Future<void> unpublishTest(String testId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final testIndex = _tests.indexWhere((t) => t.id == testId);
      if (testIndex != -1) {
        final test = _tests[testIndex];
        final draftTest = Test(
          id: test.id,
          title: test.title,
          description: test.description,
          createdBy: test.createdBy,
          collegeId: test.collegeId,
          departmentId: test.departmentId,
          startTime: test.startTime,
          endTime: test.endTime,
          durationMinutes: test.durationMinutes,
          status: TestStatus.draft,
          questions: test.questions,
          createdAt: test.createdAt,
        );
        
        _draftTests.add(draftTest);
        _tests.removeAt(testIndex);
        notifyListeners();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitTestResult(TestResult result) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Results are submitted to Supabase through the repository
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Notification Provider
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    // Notifications can be loaded from Supabase when needed
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        createdAt: _notifications[index].createdAt,
        isRead: true,
        relatedId: _notifications[index].relatedId,
      );
      _updateUnreadCount();
      notifyListeners();
    }
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = AppNotification(
        id: _notifications[i].id,
        title: _notifications[i].title,
        message: _notifications[i].message,
        type: _notifications[i].type,
        createdAt: _notifications[i].createdAt,
        isRead: true,
        relatedId: _notifications[i].relatedId,
      );
    }
    _updateUnreadCount();
    notifyListeners();
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  bool get isLoading => false; // Add isLoading getter
}


class TestResultProvider extends ChangeNotifier {
  List<TestResult> _results = [];
  bool _isLoading = false;

  List<TestResult> get results => _results;
  bool get isLoading => _isLoading;

  TestResultProvider() {
    loadTestResults();
  }

  Future<void> loadTestResults() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Load test results from Supabase database using the view that includes test titles
      final networkService = SupabaseService();
      final response = await networkService.get<List<dynamic>>('/test_results_view');
      
      if (response.success && response.data != null) {
        _results = response.data!.map((json) => TestResult.fromJson(json)).toList();
        print('✅ Loaded ${_results.length} test results from database');
      } else {
        print('❌ Failed to load test results: ${response.error}');
        _results = []; // Keep empty list as fallback
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading test results: $e');
      _results = []; // Keep empty list as fallback
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  List<TestResult> getResultsForStudent(String studentId) {
    return _results.where((result) => result.studentId == studentId).toList();
  }

  TestResult? getResultForTest(String testId, String studentId) {
    try {
      return _results.firstWhere(
        (result) => result.testId == testId && result.studentId == studentId,
      );
    } catch (e) {
      return null;
    }
  }

  double getAverageScore(String studentId) {
    final studentResults = getResultsForStudent(studentId);
    if (studentResults.isEmpty) return 0.0;
    
    final totalPercentage = studentResults.fold<double>(0.0, (sum, result) {
      return sum + (result.score / result.totalQuestions * 100);
    });
    
    return totalPercentage / studentResults.length;
  }

  Map<String, dynamic> getStudentStats(String studentId) {
    final studentResults = getResultsForStudent(studentId);
    
    if (studentResults.isEmpty) {
      return {
        'totalTests': 0,
        'averageScore': 0.0,
        'highestScore': 0.0,
        'lowestScore': 0.0,
        'passedTests': 0,
        'failedTests': 0,
      };
    }
    
    final scores = studentResults.map((r) => r.score / r.totalQuestions * 100).toList();
    scores.sort();
    
    return {
      'totalTests': studentResults.length,
      'averageScore': getAverageScore(studentId),
      'highestScore': scores.last,
      'lowestScore': scores.first,
      'passedTests': scores.where((s) => s >= 60).length,
      'failedTests': scores.where((s) => s < 60).length,
    };
  }

  Future<void> submitTestResult(TestResult result) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Save to Supabase database
      final networkService = SupabaseService();
      final response = await networkService.post<Map<String, dynamic>>('/test_results', body: result.toJson());
      
      if (response.success) {
        print('✅ Test result saved to database successfully');
        _results.add(result);
      } else {
        print('❌ Failed to save test result to database: ${response.error}');
        // Still add to local results as fallback
        _results.add(result);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error submitting test result: $e');
      // Add to local results as fallback
      _results.add(result);
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }
}

// User Provider
class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  
  // Dependencies
  final UserRepository _userRepository;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider({
    required UserRepository userRepository,
  }) : _userRepository = userRepository {
    loadUsers();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userRepository.getUsers();
    } catch (e) {
      _error = e.toString();
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdUser = await _userRepository.createUser(user);
      _users.add(createdUser);
    } catch (e) {
      _error = e.toString();
      print('Error creating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    try {
      // User updates are handled through Supabase repository
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // User deletion is handled through Supabase repository
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}


