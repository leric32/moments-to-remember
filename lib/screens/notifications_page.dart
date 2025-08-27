import 'package:flutter/material.dart';
import '../widgets/common_header.dart';
import '../models/event_models.dart';
import '../models/user.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationData> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final loadedNotifications = await EventManager.getNotificationsForUser(
        currentUser?.username ?? '',
      );
      setState(() {
        notifications = loadedNotifications;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading notifications: $e');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await EventManager.markNotificationAsRead(notificationId);
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  Future<void> _markAllAsRead() async {
    await EventManager.markAllNotificationsAsRead();
    setState(() {
      notifications =
          notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: const CommonHeader(currentPage: 'notifications'),
      body: Column(
        children: [
          const PurpleDivider(),
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Obaveštenja',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (notifications.any((n) => !n.isRead))
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Označi sve kao pročitano',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple,
                    ),
                  )
                : notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nema obaveštenja',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kada organizator odgovori na vaše zahteve, videćete obaveštenja ovde',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    final isApproved = notification.type == 'approved';
    final isDeclined = notification.type == 'declined';

    Color iconColor;
    IconData iconData;
    Color borderColor;

    if (isApproved) {
      iconColor = Colors.green;
      iconData = Icons.check_circle;
      borderColor = Colors.green.withOpacity(0.3);
    } else if (isDeclined) {
      iconColor = Colors.red;
      iconData = Icons.cancel;
      borderColor = Colors.red.withOpacity(0.3);
    } else {
      iconColor = Colors.orange;
      iconData = Icons.info;
      borderColor = Colors.orange.withOpacity(0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : borderColor,
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Upravo sada';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sat${difference.inHours == 1 ? '' : 'a'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dan${difference.inDays == 1 ? '' : 'a'} ago';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}
