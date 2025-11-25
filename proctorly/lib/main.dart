import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/screens/screens.dart';
import 'package:proctorly/screens/common_login_screen.dart';
import 'package:proctorly/screens/super_admin_screens.dart';
import 'package:proctorly/screens/teacher_screens.dart';
import 'package:proctorly/screens/student_screens.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/core/network/network_service.dart';
import 'package:proctorly/core/repositories/college_repository.dart';
import 'package:proctorly/core/repositories/department_repository.dart';
import 'package:proctorly/core/repositories/test_repository.dart';
import 'package:proctorly/core/repositories/user_repository.dart';
import 'package:proctorly/core/repositories/auth_repository.dart';
import 'package:proctorly/core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Try to load environment variables from .env file
    try {
      await dotenv.load(fileName: ".env");
      print('✅ Environment variables loaded from .env file');
      print('🔗 Supabase URL: ${dotenv.env['SUPABASE_URL']}');
      print('🔑 Supabase Key: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 20)}...');
    } catch (e) {
      print('⚠️ Could not load .env file, using fallback values: $e');
      print('📁 Current working directory: ${Directory.current.path}');
      print('📁 Looking for .env file at: ${File('.env').absolute.path}');
    }
    
    // Initialize Supabase
    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? SupabaseConfig.projectUrl,
        anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? SupabaseConfig.anonKeyValue,
        debug: dotenv.env['SUPABASE_DEBUG'] == 'true' || SupabaseConfig.debug,
      );
      print('✅ Supabase initialized');
      
      // Initialize dependencies with Supabase
      final prefs = await SharedPreferences.getInstance();
      final networkService = SupabaseService();
      print('✅ Dependencies initialized with Supabase');
      
      runApp(ProctorlyApp(
        prefs: prefs,
        networkService: networkService,
      ));
    } catch (supabaseError) {
      print('❌ Supabase initialization failed: $supabaseError');
      print('🔄 Falling back to MockNetworkService');
      
      // Fallback initialization with mock service
      final prefs = await SharedPreferences.getInstance();
      final networkService = MockNetworkService();
      print('✅ Dependencies initialized with MockNetworkService');
      
      runApp(ProctorlyApp(
        prefs: prefs,
        networkService: networkService,
      ));
    }
  } catch (e) {
    print('❌ Critical error during initialization: $e');
    // Emergency fallback
    final prefs = await SharedPreferences.getInstance();
    final networkService = MockNetworkService();
    runApp(ProctorlyApp(
      prefs: prefs,
      networkService: networkService,
    ));
  }
}

class ProctorlyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final NetworkService networkService;
  
  const ProctorlyApp({
    super.key,
    required this.prefs,
    required this.networkService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(
          prefs: prefs,
          authRepository: AuthRepository(networkService),
        )),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CollegeProvider(
          collegeRepository: CollegeRepository(networkService),
        )),
        ChangeNotifierProvider(create: (_) => DepartmentProvider(
          departmentRepository: DepartmentRepository(networkService),
        )),
        ChangeNotifierProvider(create: (_) => TestProvider(
          testRepository: TestRepository(networkService),
        )),
        ChangeNotifierProvider(create: (_) => UserProvider(
          userRepository: UserRepository(networkService),
        )),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => TestResultProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: 'Proctorly',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            locale: languageProvider.currentLocale,
            supportedLocales: AppConstants.supportedLocales,
            localizationsDelegates: AppConstants.localizationsDelegates,
            builder: (context, child) {
              return child!;
            },
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                print('🏠 Main App: Building home widget - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.currentUser?.name}');
                
                if (authProvider.isLoading) {
                  print('🏠 Main App: Showing loading screen');
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (authProvider.isAuthenticated) {
                  print('🏠 Main App: User is authenticated, showing dashboard for role: ${authProvider.currentUser?.role}');
                  switch (authProvider.currentUser?.role) {
                    case UserRole.student:
                      print('🏠 Main App: Navigating to StudentDashboard');
                      return const StudentDashboard();
                    case UserRole.teacher:
                      print('🏠 Main App: Navigating to TeacherDashboard');
                      return const TeacherDashboard();
                     case UserRole.admin:
                       print('🏠 Main App: Navigating to AdminDashboard');
                       return AdminDashboard(collegeId: authProvider.currentUser?.collegeId ?? '');
                    case UserRole.superAdmin:
                      print('🏠 Main App: Navigating to SuperAdminDashboard');
                      return const SuperAdminDashboard();
                    default:
                      print('🏠 Main App: Unknown role, showing CommonLoginScreen');
                      return const CommonLoginScreen();
                  }
                }
                
                // Check if user was previously authenticated (logout scenario)
                // If so, show login screen; otherwise show college selection
                final wasAuthenticated = prefs.getBool('was_authenticated') ?? false;
                if (wasAuthenticated) {
                  print('🏠 Main App: User was previously authenticated, showing CommonLoginScreen');
                  // Clear the flag
                  prefs.setBool('was_authenticated', false);
                  return const CommonLoginScreen();
                }

                print('🏠 Main App: User not authenticated, showing CommonLoginScreen');
                return const CommonLoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
