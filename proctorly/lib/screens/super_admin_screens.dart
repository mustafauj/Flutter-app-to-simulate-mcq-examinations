import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';
import 'package:proctorly/screens/college_detail_screen.dart';
import 'package:proctorly/screens/common_login_screen.dart';
import 'package:proctorly/screens/notifications_screen.dart';
import 'package:proctorly/core/credentials/credentials_manager.dart';

// Super Admin Dashboard
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SuperAdminHomePage(),
    const CollegeManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Super Admin Dashboard' : 'College Management',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // Context-aware action button
          if (_currentIndex == 1) // College Management
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showCreateCollegeDialog(context);
                },
                tooltip: 'Add College',
              ),
            ),
          // View Credentials button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.key_rounded),
            onPressed: () => _showSavedCredentialsDialog(context),
            tooltip: 'View Saved Credentials',
            ),
          ),
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
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error opening notifications: $e'),
                    backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
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
          print('🔄 Refreshing data on SuperAdminDashboard...');
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
      bottomNavigationBar: Container(
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
        type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.school_rounded),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Colleges',
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Super Admin Profile'),
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
              children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          user?.name ?? 'Super Admin',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                        const Text(
                      'System Administrator',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                    ),
                ),
              ],
            ),
            const SizedBox(height: 20),
              _buildProfileInfoRow('Email', user?.email ?? 'superadmin@proctorly.com'),
              _buildProfileInfoRow('Role', 'Super Administrator'),
              _buildProfileInfoRow('Permissions', 'Full system access'),
              _buildProfileInfoRow('Can manage', 'All colleges, users, and settings'),
              if (user != null) ...[
                _buildProfileInfoRow('Member Since', _formatDate(user.createdAt)),
                _buildProfileInfoRow('Last Login', _formatDate(user.lastLogin)),
              ],
            ],
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

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Perform logout
              context.read<AuthProvider>().logout();
              // Navigate to login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const CommonLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showCreateCollegeDialog(BuildContext context) {
    // Direct implementation of the create college dialog
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedPrimaryColor = AppConstants.primaryColor;
    Color selectedSecondaryColor = AppConstants.secondaryColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create College'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'College Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'College Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Primary Color'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showColorPicker(context, (color) {
                              setState(() {
                                selectedPrimaryColor = color;
                              });
                            }),
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selectedPrimaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Secondary Color'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showColorPicker(context, (color) {
                              setState(() {
                                selectedSecondaryColor = color;
                              });
                            }),
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selectedSecondaryColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                nameController.dispose();
                codeController.dispose();
                descriptionController.dispose();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || codeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                try {
                  final college = College(
                    id: '', // Let Supabase generate UUID
                    name: nameController.text.trim(),
                    code: codeController.text.trim().toUpperCase(),
                    description: descriptionController.text.trim(),
                    primaryColor: '#${selectedPrimaryColor.value.toRadixString(16).substring(2)}',
                    secondaryColor: '#${selectedSecondaryColor.value.toRadixString(16).substring(2)}',
                    createdAt: DateTime.now(),
                    isActive: true,
                  );

                  await context.read<CollegeProvider>().createCollege(college);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    nameController.dispose();
                    codeController.dispose();
                    descriptionController.dispose();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('College created successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating college: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            children: [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.teal,
              Colors.indigo,
              Colors.pink,
              Colors.amber,
              Colors.cyan,
              Colors.lime,
              Colors.deepOrange,
              Colors.deepPurple,
              Colors.lightBlue,
              Colors.lightGreen,
              Colors.brown,
            ].map((color) => GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onColorSelected(color);
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _showSavedCredentialsDialog(BuildContext context) async {
    try {
      final credentialsText = await CredentialsManager.getAllCredentialsDisplay();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Saved Credentials'),
          content: SingleChildScrollView(
            child: SelectableText(
              credentialsText,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Copy all credentials to clipboard
                await Clipboard.setData(ClipboardData(text: credentialsText));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All credentials copied to clipboard!')),
                  );
                }
              },
              child: const Text('Copy All'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading credentials: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Super Admin Home Page
class SuperAdminHomePage extends StatelessWidget {
  const SuperAdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Welcome Section
            _buildWelcomeSection(),
            
            const SizedBox(height: 32),
            
            // Platform Overview Cards
            _buildPlatformOverview(),
            
            const SizedBox(height: 32),
            
            // Quick Actions Section
            _buildQuickActions(),
            
            const SizedBox(height: 32),
            
            // Recent Activity Section
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                    'Welcome, Super Admin!',
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                    const SizedBox(height: 8),
                  Text(
                    'Manage all colleges and users across the platform',
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
              'System Administrator',
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
  }

  Widget _buildPlatformOverview() {
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
              'Platform Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
            
            Consumer3<CollegeProvider, TestProvider, UserProvider>(
              builder: (context, collegeProvider, testProvider, userProvider, child) {
                return Consumer<TestResultProvider>(
                  builder: (context, testResultProvider, child) {
                    final totalColleges = collegeProvider.colleges.length;
                    final totalTests = testProvider.tests.length;
                    final totalUsers = userProvider.users.length;
                    final activeUsers = userProvider.users.where((user) => 
                      user.lastLogin.isAfter(DateTime.now().subtract(const Duration(days: 7)))
                    ).length;
                    
                    // Calculate platform health based on recent activity
                    final recentTests = testProvider.tests.where((test) => 
                      test.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
                    ).length;
                    final recentResults = testResultProvider.results.where((result) => 
                      result.submittedAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
                    ).length;
                    
                    // Platform health calculation (simplified)
                    final platformHealth = totalTests > 0 && totalUsers > 0 
                        ? ((recentTests + recentResults) / (totalTests + totalUsers) * 100).round()
                        : 100;
                    
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _buildModernStatCard(
                          'Total Colleges',
                          totalColleges.toString(),
                          Icons.school_rounded,
                          AppConstants.primaryColor,
                          'Registered',
                        ),
                        _buildModernStatCard(
                          'Total Tests',
                          totalTests.toString(),
                          Icons.quiz_rounded,
                          AppConstants.secondaryColor,
                          'Created',
                        ),
                        _buildModernStatCard(
                          'Active Users',
                          activeUsers.toString(),
                          Icons.people_rounded,
                          Colors.orange,
                          'Last 7 days',
                        ),
                        _buildModernStatCard(
                          'Platform Health',
                          '$platformHealth%',
                          Icons.health_and_safety_rounded,
                          Colors.green,
                          'Activity level',
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

  Widget _buildQuickActions() {
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
            
            Row(
              children: [
                Expanded(
              child: _buildModernActionCard(
                    'Manage Colleges',
                    'Add, edit, or remove colleges',
                Icons.school_rounded,
                AppConstants.primaryColor,
                    () {
                      // Navigate to college management
                    },
                  ),
                ),
            const SizedBox(width: 16),
                Expanded(
              child: _buildModernActionCard(
                    'View All Users',
                    'Manage users across all colleges',
                Icons.people_rounded,
                AppConstants.secondaryColor,
                    () {
                      // Navigate to users page
                    },
                  ),
                ),
              ],
            ),
          ],
    );
  }

  Widget _buildRecentActivity() {
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
                'New college created',
                'MIT College added to platform',
                '2 hours ago',
                Colors.green,
              ),
              const Divider(),
              _buildActivityItem(
                Icons.edit_rounded,
                'College updated',
                'Stanford University details modified',
                '4 hours ago',
                Colors.blue,
              ),
              const Divider(),
              _buildActivityItem(
                Icons.person_add_rounded,
                'New admin added',
                'College admin created for Harvard',
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

  Widget _buildModernActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: AppConstants.marginSmall),
            Text(
              value,
              style: AppConstants.headingStyle.copyWith(
                fontSize: 24,
                color: color,
              ),
            ),
            const SizedBox(height: AppConstants.marginSmall),
            Text(
              title,
              style: AppConstants.captionStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.marginSmall),
              Text(
                title,
                style: AppConstants.subheadingStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.marginSmall),
              Text(
                subtitle,
                style: AppConstants.captionStyle.copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// College Management Screen
class CollegeManagementScreen extends StatelessWidget {
  const CollegeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CollegeProvider>(
        builder: (context, collegeProvider, child) {
          if (collegeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: collegeProvider.colleges.length,
            itemBuilder: (context, index) {
              final college = collegeProvider.colleges[index];
              return _buildCollegeCard(context, college);
            },
          );
        },
      ),
    );
  }

  Widget _buildCollegeCard(BuildContext context, College college) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CollegeDetailScreen(college: college),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            // College Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                AppIcons.college,
                size: 30,
                color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))),
              ),
            ),
            const SizedBox(width: AppConstants.marginMedium),
            
            // College Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    college.name,
                    style: AppConstants.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Text(
                    college.description,
                    style: AppConstants.captionStyle,
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          college.code,
                          style: AppConstants.smallStyle.copyWith(
                            color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.marginSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: college.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          college.isActive ? 'Active' : 'Inactive',
                          style: AppConstants.smallStyle.copyWith(
                            color: college.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditCollegeDialog(context, college);
                    break;
                  case 'delete':
                    _showDeleteCollegeDialog(context, college);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showCreateCollegeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    Color selectedPrimaryColor = AppConstants.primaryColor;
    Color selectedSecondaryColor = AppConstants.secondaryColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create College'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'College Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'College Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Primary Color'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selectedPrimaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '#${selectedPrimaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Secondary Color'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selectedSecondaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '#${selectedSecondaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                print('🏛️ Create button pressed!');
                print('🏛️ Name: ${nameController.text.trim()}');
                print('🏛️ Code: ${codeController.text.trim()}');
                
                if (nameController.text.trim().isEmpty || codeController.text.trim().isEmpty) {
                  print('🏛️ Validation failed - empty fields');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                print('🏛️ Validation passed, proceeding with college creation...');

                // Generate a proper UUID (let Supabase handle this)
                final college = College(
                  id: '', // Let Supabase generate the UUID
                  name: nameController.text.trim(),
                  code: codeController.text.trim(),
                  description: descriptionController.text.trim(),
                  logo: null, // Optional logo URL
                  primaryColor: '#${selectedPrimaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  secondaryColor: '#${selectedSecondaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                  createdAt: DateTime.now(),
                  isActive: true,
                );

                Map<String, String>? adminCredentials;
                
                try {
                  // Create college
                  print('🏛️ SuperAdmin: Creating college: ${college.name}');
                  print('🏛️ SuperAdmin: College data: ${college.toJson()}');
                  final createdCollege = await context.read<CollegeProvider>().createCollege(college);
                  print('🏛️ SuperAdmin: College creation completed with ID: ${createdCollege.id}');

                  // Generate admin credentials for this college
                  final adminName = 'College Admin';
                  final adminEmail = 'admin@${createdCollege.code.toLowerCase()}.edu';
                  adminCredentials = CredentialsManager.generateCredentials('admin', createdCollege.id, collegeCode: createdCollege.code, userName: adminName);
                  print('🔑 Generated admin credentials: $adminCredentials');
                  await CredentialsManager.saveUserCredentials(adminCredentials, userEmail: adminEmail, userName: adminName);

                  Navigator.of(context).pop();
                  
                  // Refresh users list to show the newly created admin
                  try {
                    await context.read<UserProvider>().loadUsers();
                    print('✅ Users list refreshed after college creation');
                  } catch (e) {
                    print('⚠️ Error refreshing users list: $e');
                  }
                } catch (e) {
                  print('❌ Error creating college: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating college: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Show admin credentials to SuperAdmin immediately
                print('🔑 About to show credentials dialog for ${college.name}');
                
                // Show enhanced credentials dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Text('Admin Credentials for ${college.name}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'College Admin has been created successfully!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text('Admin Login Credentials:'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Username: ${adminCredentials?['username'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SelectableText(
                                'Password: ${adminCredentials?['password'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Please save these credentials securely. The college admin will use these to login and manage their college.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          // Copy credentials to clipboard
                          final credentialsText = 'Username: ${adminCredentials?['username'] ?? 'N/A'}\nPassword: ${adminCredentials?['password'] ?? 'N/A'}';
                          await Clipboard.setData(ClipboardData(text: credentialsText));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Credentials copied to clipboard!')),
                            );
                          }
                        },
                        child: const Text('Copy'),
                      ),
                    ],
                  ),
                );
                
                print('🔑 Credentials dialog call completed');
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminCredentialsDialog(BuildContext context, String collegeName, Map<String, String> credentials) {
    print('🔑 Showing credentials dialog for $collegeName with credentials: $credentials');
    print('🔑 Username: ${credentials['username']}');
    print('🔑 Password: ${credentials['password']}');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        print('🔑 Dialog builder called');
        return AlertDialog(
          title: Text('Admin Credentials for $collegeName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'College Admin has been created successfully!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Admin Login Credentials:'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username: ${credentials['username'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Password: ${credentials['password'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please save these credentials securely. The college admin will use these to login and manage their college.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Copy credentials to clipboard
                final credentialsText = 'Username: ${credentials['username'] ?? 'N/A'}\nPassword: ${credentials['password'] ?? 'N/A'}';
                await Clipboard.setData(ClipboardData(text: credentialsText));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credentials copied to clipboard!')),
                  );
                }
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCollegeDialog(BuildContext context, College college) {
    // Similar to create dialog but pre-filled with college data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit college functionality coming soon')),
    );
  }

  void _showDeleteCollegeDialog(BuildContext context, College college) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete College'),
        content: Text('Are you sure you want to delete "${college.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CollegeProvider>().deleteCollege(college.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('College deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Super Admin Users Page
class SuperAdminUsersPage extends StatelessWidget {
  const SuperAdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await context.read<UserProvider>().loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality can be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality will be available soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${userProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.loadUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (userProvider.users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No users found'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              final user = userProvider.users[index];
              return _buildUserCard(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                _getRoleIcon(user.role),
                size: 30,
                color: _getRoleColor(user.role),
              ),
            ),
            const SizedBox(width: AppConstants.marginMedium),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppConstants.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Text(
                    user.email,
                    style: AppConstants.captionStyle,
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toString().split('.').last.toUpperCase(),
                          style: AppConstants.smallStyle.copyWith(
                            color: _getRoleColor(user.role),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (user.collegeId.isNotEmpty) ...[
                        const SizedBox(width: AppConstants.marginSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'College: ${user.collegeId.substring(0, 8)}...',
                            style: AppConstants.smallStyle.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    // View user details functionality can be added here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User details view will be available soon')),
                    );
                    break;
                  case 'edit':
                    // Edit user functionality can be added here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User editing will be available soon')),
                    );
                    break;
                  case 'delete':
                    // Delete user functionality can be added here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User deletion will be available soon')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit User'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete User', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.teacher:
        return Colors.green;
      case UserRole.student:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
    }
  }
}

// Super Admin Tests Page
class SuperAdminTestsPage extends StatelessWidget {
  const SuperAdminTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality can be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality will be available soon')),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Super Admin Tests Page'),
      ),
    );
  }
}

// Department Management Screen
class DepartmentManagementScreen extends StatelessWidget {
  const DepartmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Departments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateDepartmentDialog(context);
            },
          ),
        ],
      ),
      body: Consumer2<DepartmentProvider, CollegeProvider>(
        builder: (context, departmentProvider, collegeProvider, child) {
          if (departmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: departmentProvider.departments.length,
            itemBuilder: (context, index) {
              final department = departmentProvider.departments[index];
              final college = collegeProvider.colleges.firstWhere(
                (c) => c.id == department.collegeId,
                orElse: () => College(
                  id: department.collegeId,
                  name: 'Unknown College',
                  code: 'UC',
                  description: '',
                  primaryColor: '0xFF6366F1',
                  secondaryColor: '0xFF10B981',
                  createdAt: DateTime.now(),
                  isActive: true,
                ),
              );
              return _buildDepartmentCard(context, department, college);
            },
          );
        },
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, Department department, College college) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            // Department Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                _getDepartmentIcon(department.name),
                size: 30,
                color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))),
              ),
            ),
            const SizedBox(width: AppConstants.marginMedium),
            
            // Department Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: AppConstants.subheadingStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Text(
                    department.description,
                    style: AppConstants.captionStyle,
                  ),
                  const SizedBox(height: AppConstants.marginSmall),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          department.code,
                          style: AppConstants.smallStyle.copyWith(
                            color: Color(int.parse(college.primaryColor.replaceFirst('#', '0xFF'))),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.marginSmall),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.neutral200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          college.name,
                          style: AppConstants.smallStyle.copyWith(
                            color: AppConstants.neutral600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditDepartmentDialog(context, department);
                    break;
                  case 'delete':
                    _showDeleteDepartmentDialog(context, department);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(AppIcons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(AppIcons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDepartmentIcon(String departmentName) {
    final name = departmentName.toLowerCase();
    if (name.contains('computer') || name.contains('cs')) {
      return AppIcons.computerScience;
    } else if (name.contains('engineering') || name.contains('mechanical')) {
      return AppIcons.engineering;
    } else if (name.contains('business') || name.contains('management')) {
      return AppIcons.business;
    } else if (name.contains('medical') || name.contains('medicine')) {
      return AppIcons.medical;
    } else if (name.contains('arts') || name.contains('design')) {
      return AppIcons.arts;
    } else if (name.contains('science') || name.contains('physics')) {
      return AppIcons.science;
    } else {
      return AppIcons.department;
    }
  }

  void _showCreateDepartmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCollegeId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Consumer<CollegeProvider>(
          builder: (context, collegeProvider, child) => AlertDialog(
            title: const Text('Create Department'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCollegeId,
                    decoration: const InputDecoration(
                      labelText: 'College',
                      border: OutlineInputBorder(),
                    ),
                    items: collegeProvider.colleges.map((college) {
                      return DropdownMenuItem(
                        value: college.id,
                        child: Text(college.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCollegeId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Department Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedCollegeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a college')),
                    );
                    return;
                  }
                  
                  final department = Department(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    code: codeController.text.trim(),
                    description: descriptionController.text.trim(),
                    collegeId: selectedCollegeId!,
                    createdAt: DateTime.now(),
                    isActive: true,
                  );
                  context.read<DepartmentProvider>().createDepartment(department);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Department created successfully')),
                  );
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDepartmentDialog(BuildContext context, Department department) {
    // Similar to create dialog but pre-filled with department data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit department functionality coming soon')),
    );
  }

  void _showDeleteDepartmentDialog(BuildContext context, Department department) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${department.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DepartmentProvider>().deleteDepartment(department.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Department deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

