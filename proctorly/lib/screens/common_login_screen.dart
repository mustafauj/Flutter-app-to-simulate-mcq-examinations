import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';
import 'package:proctorly/core/credentials/credentials_manager.dart';
import 'package:proctorly/screens/screens.dart';
import 'package:proctorly/screens/super_admin_screens.dart';
import 'package:proctorly/screens/teacher_screens.dart';
import 'package:proctorly/screens/student_screens.dart';

class CommonLoginScreen extends StatefulWidget {
  const CommonLoginScreen({super.key});

  @override
  State<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isNavigating = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Check if it's SuperAdmin
      if (CredentialsManager.isSuperAdmin(username, password)) {
        print('🔑 SuperAdmin login detected');
        
        // Create SuperAdmin user
        final superAdminUser = User(
          id: 'superadmin_1',
          name: 'Super Admin',
          email: 'superadmin@proctorly.com',
          role: UserRole.superAdmin,
          collegeId: 'superadmin', // Special identifier for SuperAdmin
          departmentId: null,
          year: null,
          studentId: null,
          employeeId: 'SUPER_ADMIN_001',
          canChangePassword: false,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // Login through AuthProvider
        final result = await context.read<AuthProvider>().loginWithUser(
          username,
          password,
          superAdminUser,
        );

        if (result.success && mounted) {
          print('✅ SuperAdmin login successful, refreshing data and navigating to dashboard...');
          setState(() {
            _isNavigating = true;
            _isLoading = false;
          });

          // Refresh all providers to ensure cross-device data synchronization
          try {
            print('🔄 Refreshing providers for cross-device sync...');
            await context.read<TestProvider>().loadTests();
            await context.read<UserProvider>().loadUsers();
            await context.read<CollegeProvider>().loadColleges();
            await context.read<DepartmentProvider>().loadDepartments();
            await context.read<TestResultProvider>().loadTestResults();
            print('✅ All providers refreshed successfully');
          } catch (e) {
            print('⚠️ Error refreshing providers: $e');
            // Continue with navigation even if refresh fails
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SuperAdminDashboard()),
          );
        } else {
          _showError(result.error ?? 'Login failed');
        }
      } else {
        // Check user credentials
        final userCredentials = await CredentialsManager.findUserCredentials(username, password);
        
        if (userCredentials != null) {
          print('🔑 User login detected: ${userCredentials['role']}');
          
          // Get the actual user ID from database if not in credentials
          String userId = userCredentials['userId'] ?? '';
          if (userId.isEmpty) {
            print('⚠️ No userId in credentials, fetching from database...');
            try {
              final supabase = Supabase.instance.client;
              
              // Try to find user by username in user_credentials table first
              final credentialsResponse = await supabase
                  .from('user_credentials')
                  .select('user_id')
                  .eq('username', username)
                  .maybeSingle();
              
              if (credentialsResponse != null) {
                userId = credentialsResponse['user_id'];
                print('✅ Found user ID from credentials table: $userId');
              } else {
                // Fallback: try to find by email patterns
                final emailPatterns = [
                  '${username}@proctorly.com',
                  '${userCredentials['role']}@proctorly.com',
                  '${username}@${userCredentials['collegeCode']?.toLowerCase()}.edu',
                ];
                
                bool found = false;
                for (final email in emailPatterns) {
                  final userResponse = await supabase
                      .from('users')
                      .select('id')
                      .eq('email', email)
                      .maybeSingle();
                  
                  if (userResponse != null) {
                    userId = userResponse['id'];
                    print('✅ Found user ID by email $email: $userId');
                    found = true;
                    break;
                  }
                }
                
                if (!found) {
                  userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
                  print('⚠️ User not found in database, using temporary ID: $userId');
                }
              }
            } catch (e) {
              userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
              print('❌ Error fetching user ID: $e, using temporary ID: $userId');
            }
          }
          
          // Create user based on credentials
          final user = User(
            id: userId,
            name: _getDisplayName(userCredentials),
            email: '${username}@proctorly.com',
            role: _getUserRole(userCredentials['role']!),
            collegeId: userCredentials['collegeId'] ?? '',
            departmentId: userCredentials['departmentId']?.isNotEmpty == true ? userCredentials['departmentId'] : null,
            year: _getUserYear(userCredentials['role']!),
            studentId: userCredentials['role'] == 'student' ? username : null,
            employeeId: userCredentials['role'] != 'student' ? username : null,
            canChangePassword: true,
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
          );

          // Login through AuthProvider
          final result = await context.read<AuthProvider>().loginWithUser(
            username,
            password,
            user,
          );

          if (result.success && mounted) {
            print('✅ User login successful, refreshing data and navigating to dashboard...');
            setState(() {
              _isNavigating = true;
              _isLoading = false;
            });

            // Refresh all providers to ensure cross-device data synchronization
            try {
              print('🔄 Refreshing providers for cross-device sync...');
              await context.read<TestProvider>().loadTests();
              await context.read<UserProvider>().loadUsers();
              await context.read<CollegeProvider>().loadColleges();
              await context.read<DepartmentProvider>().loadDepartments();
              await context.read<TestResultProvider>().loadTestResults();
              print('✅ All providers refreshed successfully');
            } catch (e) {
              print('⚠️ Error refreshing providers: $e');
              // Continue with navigation even if refresh fails
            }

            // Navigate based on role
            Widget targetScreen;
            switch (user.role) {
              case UserRole.admin:
                targetScreen = AdminDashboard(collegeId: user.collegeId);
                break;
              case UserRole.teacher:
                targetScreen = const TeacherDashboard();
                break;
              case UserRole.student:
                targetScreen = const StudentDashboard();
                break;
              default:
                targetScreen = const CommonLoginScreen();
            }

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          } else {
            _showError(result.error ?? 'Login failed');
          }
        } else {
          _showError('Invalid username or password');
        }
      }
    } catch (e) {
      print('❌ Login error: $e');
      _showError('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isNavigating = false;
        });
      }
    }
  }

  String _getDisplayName(Map<String, String> credentials) {
    final role = credentials['role']!;
    final collegeId = credentials['collegeId']!;
    
    switch (role) {
      case 'admin':
        return 'College Admin ($collegeId)';
      case 'teacher':
        return 'Teacher ($collegeId)';
      case 'student':
        return 'Student ($collegeId)';
      default:
        return 'User ($collegeId)';
    }
  }

  UserRole _getUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  int? _getUserYear(String role) {
    if (role == 'student') {
      return 1; // Default year for students
    }
    return null;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryVariant,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isMobile(context) ? 16 : AppConstants.paddingLarge,
                vertical: Responsive.isMobile(context) ? 8 : AppConstants.paddingLarge,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    Responsive.isMobile(context) ? AppConstants.paddingMedium : AppConstants.paddingXLarge,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and Title
                        Container(
                          width: Responsive.isMobile(context) ? 60 : 80,
                          height: Responsive.isMobile(context) ? 60 : 80,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          ),
                          child: Icon(
                            AppIcons.college,
                            size: Responsive.isMobile(context) ? 30 : 40,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? AppConstants.marginMedium : AppConstants.marginLarge),
                        
                        Text(
                          'Proctorly',
                          style: AppConstants.headingStyle.copyWith(
                            fontSize: Responsive.isMobile(context) ? 24 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? 4 : AppConstants.marginSmall),
                        
                        Text(
                          'Educational Assessment Platform',
                          style: AppConstants.bodyStyle.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: Responsive.isMobile(context) ? 12 : 14,
                          ),
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? AppConstants.marginLarge : AppConstants.marginXLarge),
                        
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(AppIcons.profile),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? AppConstants.marginSmall : AppConstants.marginMedium),
                        
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? AppConstants.marginMedium : AppConstants.marginLarge),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.isMobile(context) ? 44 : 50,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _isNavigating) ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : _isNavigating
                                    ? const Text('Navigating...')
                                    : const Text('Login'),
                          ),
                        ),
                        SizedBox(height: Responsive.isMobile(context) ? AppConstants.marginMedium : AppConstants.marginLarge),
                        
                        // Demo Credentials Info
                        Container(
                          padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? AppConstants.paddingSmall : AppConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demo Credentials:',
                                style: AppConstants.captionStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: Responsive.isMobile(context) ? 11 : 12,
                                ),
                              ),
                              SizedBox(height: Responsive.isMobile(context) ? 4 : AppConstants.marginSmall),
                              Text(
                                'SuperAdmin: superadmin / superadmin123',
                                style: AppConstants.captionStyle.copyWith(
                                  fontSize: Responsive.isMobile(context) ? 10 : 12,
                                ),
                              ),
                              SizedBox(height: Responsive.isMobile(context) ? 2 : 4),
                              Text(
                                'Other users will be generated when colleges are created',
                                style: AppConstants.captionStyle.copyWith(
                                  fontSize: Responsive.isMobile(context) ? 10 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
