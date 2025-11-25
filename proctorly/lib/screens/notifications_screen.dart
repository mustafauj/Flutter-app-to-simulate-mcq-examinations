import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all notifications as read
              context.read<NotificationProvider>().markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          final notifications = notificationProvider.notifications;
          
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see notifications here when they arrive',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(context, notification);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationCard(BuildContext context, AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.marginMedium),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: InkWell(
        onTap: () {
          // Mark notification as read
          context.read<NotificationProvider>().markAsRead(notification.id);
          
          // Handle notification tap based on type
          _handleNotificationTap(context, notification);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            children: [
              // Notification Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.marginMedium),
              
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppConstants.subheadingStyle.copyWith(
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppConstants.marginSmall),
                    Text(
                      notification.message,
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.neutral600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.marginSmall),
                    Row(
                      children: [
                        Text(
                          _formatDate(notification.createdAt),
                          style: AppConstants.captionStyle.copyWith(
                            color: AppConstants.neutral500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: AppConstants.marginSmall),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppConstants.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action Button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showNotificationOptions(context, notification);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.test:
        return AppConstants.primaryColor;
      case NotificationType.result:
        return AppConstants.successColor;
      case NotificationType.reminder:
        return AppConstants.warningColor;
      case NotificationType.announcement:
        return AppConstants.infoColor;
      default:
        return AppConstants.neutral500;
    }
  }
  
  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.test:
        return AppIcons.tests;
      case NotificationType.result:
        return AppIcons.results;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.announcement:
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
  
  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    switch (notification.type) {
      case NotificationType.test:
        // Navigate to test details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to test details')),
        );
        break;
      case NotificationType.result:
        // Navigate to results
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to results')),
        );
        break;
      case NotificationType.reminder:
        // Show reminder details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Show reminder details')),
        );
        break;
      case NotificationType.announcement:
        // Show announcement details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Show announcement details')),
        );
        break;
    }
  }
  
  void _showNotificationOptions(BuildContext context, AppNotification notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read),
              title: const Text('Mark as Read'),
              onTap: () {
                context.read<NotificationProvider>().markAsRead(notification.id);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                context.read<NotificationProvider>().deleteNotification(notification.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification deleted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
