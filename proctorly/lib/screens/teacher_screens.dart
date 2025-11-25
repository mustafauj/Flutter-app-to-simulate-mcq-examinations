import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';
import 'package:proctorly/screens/common_login_screen.dart';
import 'package:proctorly/screens/professional_test_creation_screen.dart';

// Teacher Dashboard
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TeacherHomePage(),
      const TeacherTestsPage(),
      const TeacherStudentsScreen(),
      const TeacherProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: ResponsiveText(
              _getAppBarTitle(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: Responsive.getResponsiveAppBarHeight(context),
        actions: [
          // Notifications button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notifications coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              tooltip: 'Notifications',
            ),
          ),
          // Profile/User menu
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_rounded),
              onSelected: (value) {
                if (value == 'profile') {
                  _showProfileDialog(context);
                } else if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, color: AppConstants.primaryColor),
                      SizedBox(width: 12),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          print('🔄 Refreshing data on TeacherDashboard...');
          try {
            await context.read<TestProvider>().loadTests();
            await context.read<UserProvider>().loadUsers();
            await context.read<CollegeProvider>().loadColleges();
            await context.read<DepartmentProvider>().loadDepartments();
            print('✅ Data refreshed successfully');
          } catch (e) {
            print('❌ Error refreshing data: $e');
          }
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: ResponsiveWidget(
        mobile: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded),
                activeIcon: Icon(Icons.quiz_rounded),
                label: 'Tests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ),
        tablet: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 28),
                activeIcon: Icon(Icons.dashboard_rounded, size: 28),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded, size: 28),
                activeIcon: Icon(Icons.quiz_rounded, size: 28),
                label: 'Tests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded, size: 28),
                activeIcon: Icon(Icons.people_rounded, size: 28),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 28),
                activeIcon: Icon(Icons.person_rounded, size: 28),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ),
        desktop: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: AppConstants.primaryColor,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 32),
                activeIcon: Icon(Icons.dashboard_rounded, size: 32),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_rounded, size: 32),
                activeIcon: Icon(Icons.quiz_rounded, size: 32),
                label: 'Tests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded, size: 32),
                activeIcon: Icon(Icons.people_rounded, size: 32),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 32),
                activeIcon: Icon(Icons.person_rounded, size: 32),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Teacher Home';
      case 1:
        return 'Tests';
      case 2:
        return 'Students';
      case 3:
        return 'Profile';
      default:
        return 'Teacher Dashboard';
    }
  }

  void _showProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('Teacher Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 20),
            Text('Name: ${user?.name ?? 'N/A'}'),
            Text('Email: ${user?.email ?? 'N/A'}'),
            Text('College ID: ${user?.collegeId ?? 'N/A'}'),
            Text('Department ID: ${user?.departmentId ?? 'N/A'}'),
            const Text('Role: Teacher'),
            const Text('Permissions: Create tests, manage students'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Teacher Home Page
class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: SingleChildScrollView(
            padding: Responsive.getResponsivePadding(context),
            child: ResponsiveContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Professional Welcome Section
                  _buildWelcomeSection(context),
                  
                  SizedBox(height: Responsive.getResponsiveSpacing(context, 32)),
                  
                  // Quick Stats Section
                  _buildQuickStats(context),
                  
                  SizedBox(height: Responsive.getResponsiveSpacing(context, 32)),
                  
                  // Main Actions Section
                  _buildMainActions(context),
                  
                  SizedBox(height: Responsive.getResponsiveSpacing(context, 32)),
                  
                  // Recent Activity Section
                  _buildRecentActivity(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                AppConstants.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user?.name ?? 'Teacher'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready to create amazing learning experiences',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Educator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Teaching Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Consumer2<TestProvider, UserProvider>(
          builder: (context, testProvider, userProvider, child) {
            return Consumer<TestResultProvider>(
              builder: (context, testResultProvider, child) {
                final currentUser = context.read<AuthProvider>().currentUser;
                final myTests = testProvider.tests.where((test) => test.createdBy == currentUser?.id).toList();
                final activeTests = myTests.where((test) => 
                  test.status == TestStatus.published && 
                  DateTime.now().isAfter(test.startTime) && 
                  DateTime.now().isBefore(test.endTime)
                ).length;
                
                final students = userProvider.users.where((user) => 
                  user.role == UserRole.student && user.collegeId == currentUser?.collegeId
                ).length;
                
                final allResults = testResultProvider.results.where((result) => 
                  myTests.any((test) => test.id == result.testId)
                ).toList();
                
                final completedTests = allResults.length;
                final avgScore = allResults.isEmpty 
                    ? 0 
                    : (allResults.fold<int>(0, (sum, result) => sum + result.score) / allResults.length).round();
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildModernStatCard(
                      'Active Tests',
                      activeTests.toString(),
                      Icons.quiz_rounded,
                      AppConstants.primaryColor,
                      'Currently running',
                    ),
                    _buildModernStatCard(
                      'Total Students',
                      students.toString(),
                      Icons.people_rounded,
                      AppConstants.secondaryColor,
                      'Enrolled',
                    ),
                    _buildModernStatCard(
                      'Completed Tests',
                      completedTests.toString(),
                      Icons.check_circle_rounded,
                      Colors.green,
                      'This semester',
                    ),
                    _buildModernStatCard(
                      'Avg. Score',
                      '$avgScore%',
                      Icons.trending_up_rounded,
                      Colors.orange,
                      'Class average',
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.flash_on_rounded,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildModernActionCard(
              context,
              'Create Test',
              'Design new assessments',
              Icons.add_circle_rounded,
              AppConstants.primaryColor,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfessionalTestCreationScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              'View Results',
              'Analyze test performance',
              Icons.analytics_rounded,
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherResultsScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              'Manage Students',
              'View student profiles',
              Icons.people_rounded,
              Colors.orange,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TeacherStudentsScreen(),
                  ),
                );
              },
            ),
            _buildModernActionCard(
              context,
              'Live Monitoring',
              'Monitor active tests',
              Icons.monitor_rounded,
              Colors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveMonitoringScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.history_rounded,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.add_circle_rounded,
                'New test created',
                'Mathematics Quiz - Chapter 5',
                '2 hours ago',
                Colors.green,
              ),
              const Divider(),
              _buildActivityItem(
                Icons.people_rounded,
                'Students enrolled',
                '15 new students joined your class',
                '4 hours ago',
                Colors.blue,
              ),
              const Divider(),
              _buildActivityItem(
                Icons.analytics_rounded,
                'Results available',
                'Physics Test results are ready',
                '6 hours ago',
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// Teacher Tests Page
class TeacherTestsPage extends StatelessWidget {
  const TeacherTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        final currentUser = context.read<AuthProvider>().currentUser;
        final myTests = testProvider.tests.where((test) => test.createdBy == currentUser?.id).toList();
        
        return Scaffold(
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Tests',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: myTests.isEmpty
                    ? const Center(
                        child: Text('No tests created yet'),
                      )
                    : ListView.builder(
                        itemCount: myTests.length,
                        itemBuilder: (context, index) {
                          final test = myTests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(test.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(test.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Duration: ${test.durationMinutes} min • Questions: ${test.questions.length}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfessionalTestCreationScreen(testToEdit: test),
                                      ),
                                    );
                                  } else if (value == 'results') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TeacherResultsScreen(),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteTestDialog(context, test);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Edit'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'results',
                                    child: ListTile(
                                      leading: Icon(Icons.analytics),
                                      title: Text('View Results'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete, color: Colors.red),
                                      title: Text('Delete'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfessionalTestCreationScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showDeleteTestDialog(BuildContext context, Test test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test'),
        content: Text('Are you sure you want to delete "${test.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<TestProvider>().deleteTest(test.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting test: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Create Test Screen
class CreateTestScreen extends StatefulWidget {
  final Test? testToEdit;
  
  const CreateTestScreen({super.key, this.testToEdit});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  
  List<Question> _questions = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTest,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Test Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter test title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: const Text('Add Question'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeQuestion(index),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: question.text,
                              decoration: const InputDecoration(
                                labelText: 'Question Text',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                              onChanged: (value) {
                                _questions[index] = question.copyWith(text: value);
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            for (int i = 0; i < question.options.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: question.options[i].text,
                                        decoration: InputDecoration(
                                          labelText: 'Option ${i + 1}',
                                          border: const OutlineInputBorder(),
                                        ),
                                        onChanged: (value) {
                                          final newOptions = List<Answer>.from(question.options);
                                          newOptions[i] = question.options[i].copyWith(text: value);
                                          _questions[index] = question.copyWith(options: newOptions);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<int>(
                                      value: question.correctAnswerIndex,
                                      items: question.options.asMap().entries.map((entry) {
                                        return DropdownMenuItem(
                                          value: entry.key,
                                          child: Text('Option ${entry.key + 1}'),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        _questions[index] = question.copyWith(correctAnswerIndex: value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        testId: '',
        text: '',
        type: QuestionType.mcq,
        options: [
          Answer(id: 'opt1_${DateTime.now().millisecondsSinceEpoch}', questionId: '', studentId: '', text: 'Option A', isCorrect: false, submittedAt: DateTime.now()),
          Answer(id: 'opt2_${DateTime.now().millisecondsSinceEpoch}', questionId: '', studentId: '', text: 'Option B', isCorrect: false, submittedAt: DateTime.now()),
          Answer(id: 'opt3_${DateTime.now().millisecondsSinceEpoch}', questionId: '', studentId: '', text: 'Option C', isCorrect: false, submittedAt: DateTime.now()),
          Answer(id: 'opt4_${DateTime.now().millisecondsSinceEpoch}', questionId: '', studentId: '', text: 'Option D', isCorrect: false, submittedAt: DateTime.now()),
        ],
        correctAnswerIndex: 0,
        points: 10,
        order: _questions.length,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _saveTest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final test = Test(
        id: '', // Let Supabase generate UUID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: context.read<AuthProvider>().currentUser!.id,
        collegeId: context.read<AuthProvider>().currentUser!.collegeId,
        departmentId: '', // Optional field
        targetYears: null, // Optional field
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(days: 7)),
        durationMinutes: int.parse(_durationController.text),
        status: TestStatus.draft,
        questions: _questions, // Keep for UI, will be stored separately
        createdAt: DateTime.now(),
        publishedAt: null, // Will be set when published
        isActive: true,
      );

      await context.read<TestProvider>().createTest(test);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating test: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

// Teacher Results Screen
class TeacherResultsScreen extends StatelessWidget {
  const TeacherResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
      ),
      body: Consumer2<TestResultProvider, TestProvider>(
        builder: (context, testResultProvider, testProvider, child) {
          if (testResultProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUser = context.read<AuthProvider>().currentUser;
          final myTests = testProvider.tests.where((test) => test.createdBy == currentUser?.id).toList();
          final results = testResultProvider.results.where((result) => 
            myTests.any((test) => test.id == result.testId)
          ).toList();
          
          if (results.isEmpty) {
            return const Center(
              child: Text('No test results available yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(result.testTitle),
                  subtitle: Text('Student: ${result.studentId}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${result.score}/${result.totalQuestions}'),
                      Text('${((result.score / result.totalQuestions) * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                  onTap: () {
                    // Show detailed results
                    _showResultDetails(context, result);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showResultDetails(BuildContext context, TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Results: ${result.testTitle}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student ID: ${result.studentId}'),
            Text('Score: ${result.score}/${result.totalQuestions}'),
            Text('Percentage: ${((result.score / result.totalQuestions) * 100).toStringAsFixed(1)}%'),
            Text('Time Spent: ${result.timeSpent} minutes'),
            Text('Submitted: ${result.submittedAt.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Live Monitoring Screen
class LiveMonitoringScreen extends StatelessWidget {
  const LiveMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Test Monitoring'),
      ),
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          final activeTests = testProvider.tests.where((test) => 
            test.status == TestStatus.published && 
            DateTime.now().isAfter(test.startTime) && 
            DateTime.now().isBefore(test.endTime)
          ).toList();

          if (activeTests.isEmpty) {
            return const Center(
              child: Text('No active tests to monitor'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeTests.length,
            itemBuilder: (context, index) {
              final test = activeTests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(test.title),
                  subtitle: Text('Duration: ${test.durationMinutes} minutes'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, color: Colors.green),
                      Text('Active'),
                    ],
                  ),
                  onTap: () {
                    _showTestMonitoringDetails(context, test);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTestMonitoringDetails(BuildContext context, Test test) {
    showDialog(
      context: context,
      builder: (context) => Consumer<TestResultProvider>(
        builder: (context, testResultProvider, child) {
          final testResults = testResultProvider.results.where((result) => result.testId == test.id).toList();
          final completedCount = testResults.length;
          final inProgressCount = 0; // This would need real-time tracking
          
          return AlertDialog(
            title: Text('Monitoring: ${test.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Test Duration: ${test.durationMinutes} minutes'),
                Text('Start Time: ${test.startTime.toString()}'),
                Text('End Time: ${test.endTime.toString()}'),
                const SizedBox(height: 16),
                const Text('Live Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Students Taking: ${completedCount + inProgressCount}'),
                Text('Completed: $completedCount'),
                Text('In Progress: $inProgressCount'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Teacher Students Screen
class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = context.read<AuthProvider>().currentUser;
        final collegeStudents = userProvider.users.where((user) => 
          user.role == UserRole.student && user.collegeId == currentUser?.collegeId
        ).toList();
        
        return Scaffold(
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Students',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: collegeStudents.isEmpty
                    ? const Center(
                        child: Text('No students found'),
                      )
                    : ListView.builder(
                        itemCount: collegeStudents.length,
                        itemBuilder: (context, index) {
                          final user = collegeStudents[index];
                          
                          return Consumer<TestResultProvider>(
                            builder: (context, testResultProvider, child) {
                              final studentResults = testResultProvider.getResultsForStudent(user.id);
                              final testsTaken = studentResults.length;
                              final averageScore = studentResults.isEmpty 
                                  ? 0 
                                  : (studentResults.fold<int>(0, (sum, result) => sum + result.score) / studentResults.length).round();
                              
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getScoreColor(averageScore),
                                    child: Text(
                                      '$averageScore%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tests Taken: $testsTaken • Avg Score: $averageScore%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.analytics),
                                        onPressed: () {
                                          _showStudentTestResults(context, user, studentResults);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.info),
                                        onPressed: () {
                                          _showStudentDetails(context, user);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showStudentTestResults(BuildContext context, User student, List<TestResult> results) {
    // Filter results to only show tests created by the current teacher
    final currentUser = context.read<AuthProvider>().currentUser;
    final testProvider = context.read<TestProvider>();
    final myTests = testProvider.tests.where((test) => test.createdBy == currentUser?.id).toList();
    final filteredResults = results.where((result) => 
      myTests.any((test) => test.id == result.testId)
    ).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Results: ${student.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: filteredResults.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No test results yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This student hasn\'t taken any tests.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final result = filteredResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getScoreColor(result.score),
                          child: Text(
                            '${result.score}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          result.testTitle.isNotEmpty ? result.testTitle : 'Test Result',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score: ${result.score}%'),
                            Text('Correct: ${result.correctAnswers}/${result.totalQuestions}'),
                            Text('Time: ${result.timeSpent} minutes'),
                            Text('Date: ${_formatDate(result.submittedAt)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            _showDetailedTestResult(context, result);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDetailedTestResult(BuildContext context, TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Details: ${result.testTitle}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Test Title', result.testTitle.isNotEmpty ? result.testTitle : 'N/A'),
                _buildDetailRow('Score', '${result.score}%'),
                _buildDetailRow('Correct Answers', '${result.correctAnswers}/${result.totalQuestions}'),
                _buildDetailRow('Time Spent', '${result.timeSpent} minutes'),
                _buildDetailRow('Submitted At', _formatDate(result.submittedAt)),
                const SizedBox(height: 16),
                const Text(
                  'Answers:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...result.answers.map((answer) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: answer.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: answer.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Answer: ${answer.text}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: answer.isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        'Status: ${answer.isCorrect ? 'Correct' : 'Incorrect'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: answer.isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStudentDetails(BuildContext context, User student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Student Details: ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${student.email}'),
            Text('Role: ${student.role.toString().split('.').last}'),
            Text('College ID: ${student.collegeId}'),
            if (student.departmentId != null) Text('Department ID: ${student.departmentId}'),
            if (student.year != null) Text('Year: ${student.year}'),
            if (student.studentId != null) Text('Student ID: ${student.studentId}'),
            Text('Created: ${student.createdAt.toString()}'),
            Text('Last Login: ${student.lastLogin.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Teacher Profile Page
class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Center(
            child: Text('No user data available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Teacher',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email', user.email),
                      _buildInfoRow('Phone', user.phone ?? 'Not provided'),
                      _buildInfoRow('Role', 'Teacher'),
                      _buildInfoRow('Employee ID', user.employeeId ?? 'Not assigned'),
                      _buildInfoRow('Department ID', user.departmentId ?? 'Not assigned'),
                      _buildInfoRow('College ID', user.collegeId),
                      _buildInfoRow('Member Since', _formatDate(user.createdAt)),
                      _buildInfoRow('Last Login', _formatDate(user.lastLogin)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Profile editing functionality can be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile editing will be available soon')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Password change functionality can be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password change will be available soon')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CommonLoginScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
