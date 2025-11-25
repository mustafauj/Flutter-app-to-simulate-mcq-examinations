import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/utils/constants.dart';

class CollegeDetailScreen extends StatelessWidget {
  final College college;
  
  const CollegeDetailScreen({
    super.key,
    required this.college,
  });

  // Helper function to parse hex color
  Color _parseHexColor(String hexColor) {
    try {
      // Remove # if present
      String cleanHex = hexColor.replaceAll('#', '');
      
      // Add alpha if not present (assume FF for full opacity)
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex';
      }
      
      // Parse as hex
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // Fallback to default color if parsing fails
      return AppConstants.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(college.name),
        backgroundColor: _parseHexColor(college.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit college functionality can be added here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit college functionality will be available soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // College Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _parseHexColor(college.primaryColor),
                    _parseHexColor(college.secondaryColor),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        child: Icon(
                          AppIcons.college,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppConstants.marginMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              college.name,
                              style: AppConstants.headingStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: AppConstants.marginSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                college.code,
                                style: AppConstants.bodyStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.marginMedium),
                  Text(
                    college.description,
                    style: AppConstants.bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.marginXLarge),
            
            // College Stats
            Text(
              'College Statistics',
              style: AppConstants.subheadingStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.marginMedium),
            
            Consumer2<DepartmentProvider, UserProvider>(
              builder: (context, departmentProvider, userProvider, child) {
                final departments = departmentProvider.departments
                    .where((d) => d.collegeId == college.id)
                    .toList();
                final users = userProvider.users
                    .where((u) => u.collegeId == college.id)
                    .toList();
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.marginMedium,
                  mainAxisSpacing: AppConstants.marginMedium,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'Departments',
                      departments.length.toString(),
                      AppIcons.department,
                      AppConstants.primaryColor,
                    ),
                    _buildStatCard(
                      context,
                      'Total Users',
                      users.length.toString(),
                      Icons.people,
                      AppConstants.secondaryColor,
                    ),
                    _buildStatCard(
                      context,
                      'Teachers',
                      users.where((u) => u.role == UserRole.teacher).length.toString(),
                      Icons.person,
                      AppConstants.warningColor,
                    ),
                    _buildStatCard(
                      context,
                      'Students',
                      users.where((u) => u.role == UserRole.student).length.toString(),
                      Icons.school,
                      AppConstants.successColor,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppConstants.marginXLarge),
            
            // College Information
            Text(
              'College Information',
              style: AppConstants.subheadingStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.marginMedium),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('College Code', college.code),
                    _buildInfoRow('Status', college.isActive ? 'Active' : 'Inactive'),
                    _buildInfoRow('Created', _formatDate(college.createdAt)),
                    _buildInfoRow('Primary Color', college.primaryColor),
                    _buildInfoRow('Secondary Color', college.secondaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.marginXLarge),
            
            // Actions
            Text(
              'Quick Actions',
              style: AppConstants.subheadingStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.marginMedium),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    'Manage Departments',
                    'Add and manage departments',
                    AppIcons.department,
                    () {
                      // Department management functionality can be added here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Department management will be available soon')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.marginMedium),
                Expanded(
                  child: _buildActionCard(
                    context,
                    'Manage Users',
                    'Add and manage users',
                    Icons.people,
                    () {
                      // User management functionality can be added here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User management will be available soon')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: AppConstants.neutral600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyStyle,
            ),
          ),
        ],
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
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}