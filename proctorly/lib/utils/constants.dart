import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppConstants {
  // Enhanced Color Scheme - Light Mode
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color secondaryVariant = Color(0xFF059669);
  static const Color accentColor = Color(0xFF8B5CF6); // Purple
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Surface Colors - Light Mode
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color backgroundColor = Color(0xFFF1F5F9);
  
  // Dark Mode Colors
  static const Color darkPrimaryColor = Color(0xFF818CF8);
  static const Color darkSecondaryColor = Color(0xFF34D399);
  static const Color darkSurfaceColor = Color(0xFF1F2937);
  static const Color darkSurfaceVariant = Color(0xFF374151);
  static const Color darkBackgroundColor = Color(0xFF111827);
  static const Color darkErrorColor = Color(0xFFF87171);
  
  // Neutral Colors
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Text Colors for Contrast
  static const Color onPrimaryTextColor = Colors.white; // For text on primary color backgrounds
  static const Color onSecondaryTextColor = Colors.white; // For text on secondary color backgrounds
  static const Color onSurfaceTextColor = Color(0xFF1F2937); // For text on light surfaces
  static const Color onBackgroundTextColor = Color(0xFF1F2937); // For text on light backgrounds

  // Responsive Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.4,
  );

  // Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Enhanced Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  // Page Transitions
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // Supported Locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('hi'),
    Locale('zh'),
  ];

  // Localizations Delegates
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // Test Types
  static const List<String> questionTypes = [
    'Multiple Choice',
    'Short Answer',
    'Fill in the Blanks',
  ];

  // Notification Types
  static const List<String> notificationTypes = [
    'test',
    'result',
    'reminder',
    'announcement',
  ];

  // User Roles
  static const List<String> userRoles = [
    'Student',
    'Teacher',
    'Admin',
    'Super Admin',
  ];
}

class AppStrings {
  // Authentication
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String home = 'Home';
  static const String tests = 'Tests';
  static const String results = 'Results';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';

  // Test Management
  static const String createTest = 'Create Test';
  static const String editTest = 'Edit Test';
  static const String deleteTest = 'Delete Test';
  static const String publishTest = 'Publish Test';
  static const String testTitle = 'Test Title';
  static const String testDescription = 'Test Description';
  static const String testDuration = 'Duration (minutes)';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String addQuestion = 'Add Question';
  static const String questionText = 'Question Text';
  static const String questionType = 'Question Type';
  static const String points = 'Points';
  static const String options = 'Options';
  static const String correctAnswer = 'Correct Answer';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String preview = 'Preview';

  // Test Taking
  static const String startTest = 'Start Test';
  static const String submitTest = 'Submit Test';
  static const String timeRemaining = 'Time Remaining';
  static const String question = 'Question';
  static const String of = 'of';
  static const String next = 'Next';
  static const String previous = 'Previous';
  static const String finish = 'Finish';

  // Results
  static const String testResults = 'Test Results';
  static const String score = 'Score';
  static const String totalScore = 'Total Score';
  static const String percentage = 'Percentage';
  static const String correctAnswers = 'Correct Answers';
  static const String incorrectAnswers = 'Incorrect Answers';
  static const String leaderboard = 'Leaderboard';
  static const String rank = 'Rank';

  // College Management
  static const String colleges = 'Colleges';
  static const String collegeName = 'College Name';
  static const String collegeCode = 'College Code';
  static const String collegeDescription = 'Description';
  static const String selectCollege = 'Select College';
  static const String createCollege = 'Create College';
  static const String editCollege = 'Edit College';
  static const String deleteCollege = 'Delete College';
  static const String collegeSettings = 'College Settings';
  static const String primaryColor = 'Primary Color';
  static const String secondaryColor = 'Secondary Color';
  static const String uploadLogo = 'Upload Logo';
  
  // Department Management
  static const String departments = 'Departments';
  static const String departmentName = 'Department Name';
  static const String departmentCode = 'Department Code';
  static const String departmentDescription = 'Description';
  static const String createDepartment = 'Create Department';
  static const String editDepartment = 'Edit Department';
  static const String deleteDepartment = 'Delete Department';
  static const String selectDepartment = 'Select Department';
  static const String allDepartments = 'All Departments';
  
  // Student Years
  static const String studentYear = 'Student Year';
  static const String firstYear = 'First Year';
  static const String secondYear = 'Second Year';
  static const String thirdYear = 'Third Year';
  static const String fourthYear = 'Fourth Year';
  static const String allYears = 'All Years';
  static const String year = 'Year';
  static const String selectYear = 'Select Year';
  
  // Test Targeting
  static const String targetAudience = 'Target Audience';
  static const String targetDepartment = 'Target Department';
  static const String targetYears = 'Target Years';
  static const String testVisibility = 'Test Visibility';
  
  // User Management
  static const String studentId = 'Student ID';
  static const String employeeId = 'Employee ID';
  static const String assignCredentials = 'Assign Credentials';
  static const String generatedPassword = 'Generated Password';
  static const String cannotChangePassword = 'Password cannot be changed by user';
  static const String adminAssigned = 'Assigned by Admin';
  
  // Common
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Information';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String sync = 'Sync';
  static const String offline = 'Offline';
  static const String online = 'Online';
}

class AppIcons {
  static const IconData home = Icons.home;
  static const IconData tests = Icons.quiz;
  static const IconData results = Icons.assessment;
  static const IconData profile = Icons.person;
  static const IconData settings = Icons.settings;
  static const IconData notifications = Icons.notifications;
  static const IconData create = Icons.add;
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData save = Icons.save;
  static const IconData cancel = Icons.cancel;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
  static const IconData refresh = Icons.refresh;
  static const IconData sync = Icons.sync;
  static const IconData offline = Icons.offline_bolt;
  static const IconData online = Icons.wifi;
  static const IconData preview = Icons.preview;
  static const IconData time = Icons.access_time;
  static const IconData calendar = Icons.calendar_today;
  static const IconData question = Icons.help;
  static const IconData answer = Icons.question_answer;
  static const IconData score = Icons.score;
  static const IconData leaderboard = Icons.leaderboard;
  static const IconData theme = Icons.palette;
  static const IconData language = Icons.language;
  static const IconData logout = Icons.logout;
  static const IconData login = Icons.login;
  static const IconData signup = Icons.person_add;
  static const IconData password = Icons.lock;
  static const IconData email = Icons.email;
  static const IconData visibility = Icons.visibility;
  static const IconData visibilityOff = Icons.visibility_off;
  
  // College Management Icons
  static const IconData college = Icons.school;
  static const IconData building = Icons.business;
  static const IconData colorLens = Icons.color_lens;
  static const IconData palette = Icons.palette;
  static const IconData upload = Icons.upload;
  static const IconData idCard = Icons.badge;
  static const IconData key = Icons.key;
  static const IconData admin = Icons.admin_panel_settings;
  
  // Department Management Icons
  static const IconData department = Icons.account_tree;
  static const IconData computerScience = Icons.computer;
  static const IconData engineering = Icons.engineering;
  static const IconData business = Icons.business_center;
  static const IconData medical = Icons.local_hospital;
  static const IconData arts = Icons.palette;
  static const IconData science = Icons.science;
  static const IconData year = Icons.calendar_today;
  static const IconData target = Icons.gps_fixed;
  static const IconData info = Icons.info;
}
