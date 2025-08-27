import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/event_models.dart';

class CommonHeader extends StatefulWidget implements PreferredSizeWidget {
  final String currentPage;

  const CommonHeader({super.key, required this.currentPage});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  int unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    if (currentUser?.userType == 'customer') {
      try {
        final count = await EventManager.getUnreadNotificationCount();
        setState(() {
          unreadNotificationCount = count;
        });
      } catch (e) {
        print('Error loading notification count: $e');
      }
    }
  }

  ImageProvider _getProfileImage() {
    if (currentUser?.profileImagePath != null) {
      final imagePath = currentUser!.profileImagePath;
      if (imagePath.startsWith('assets/')) {
        return AssetImage(imagePath);
      } else if (imagePath.startsWith('base64:')) {
        // Handle base64 encoded images
        try {
          final base64String =
              imagePath.substring(7); // Remove 'base64:' prefix
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        } catch (e) {
          print('Error loading base64 image: $e');
          return const AssetImage('assets/images/profile_img.png');
        }
      } else {
        // This is a file path
        try {
          return FileImage(File(imagePath));
        } catch (e) {
          print('Error loading file image: $e');
          return const AssetImage('assets/images/profile_img.png');
        }
      }
    }
    return const AssetImage('assets/images/profile_img.png');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: GestureDetector(
        onTap: () {
          // Navigate based on user type and current page
          if (currentUser?.userType == 'organizator') {
            if (widget.currentPage != 'organizer_dashboard') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/organizer-dashboard',
                (route) => false,
              );
            }
          } else {
            if (widget.currentPage != 'home') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            }
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available,
              color: Colors.deepPurple,
              size: isMobile ? 24 : 28,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              const Text(
                "Trenuci za pamćenje",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        // Show navigation buttons only on desktop/tablet
        if (!isMobile) ...[
          TextButton(
            onPressed: () {
              // Navigate based on user type
              if (currentUser?.userType == 'organizator') {
                if (widget.currentPage != 'event_types') {
                  Navigator.pushNamed(context, '/event-types');
                }
              } else {
                if (widget.currentPage != 'events') {
                  Navigator.pushNamed(context, '/events');
                }
              }
            },
            child: Text(
              "Događaji",
              style: TextStyle(
                color: (widget.currentPage == 'events' ||
                        widget.currentPage == 'event_types')
                    ? Colors.deepPurple
                    : Colors.black,
                fontWeight: (widget.currentPage == 'events' ||
                        widget.currentPage == 'event_types')
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Kontakt", style: TextStyle(color: Colors.black)),
          ),
        ],
        IconButton(
          icon: Icon(
            Icons.shopping_basket,
            color: Colors.deepPurple,
            size: isMobile ? 22 : 24,
          ),
          onPressed: () {
            if (widget.currentPage != 'basket') {
              Navigator.pushNamed(context, '/basket');
            }
          },
        ),
        // Notification icon with badge (only for customers)
        if (currentUser?.userType == 'customer')
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.deepPurple,
                  size: isMobile ? 22 : 24,
                ),
                onPressed: () {
                  if (widget.currentPage != 'notifications') {
                    Navigator.pushNamed(context, '/notifications').then((_) {
                      // Reload notification count when returning from notifications page
                      _loadNotificationCount();
                    });
                  }
                },
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadNotificationCount > 99
                          ? '99+'
                          : unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        GestureDetector(
          onTap: () {
            if (widget.currentPage != 'profile') {
              Navigator.pushNamed(context, '/profile');
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
            child: CircleAvatar(
              radius: isMobile ? 16 : 20,
              backgroundImage: _getProfileImage(),
              backgroundColor: Colors.grey[300],
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading profile image: $exception');
              },
            ),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
      ],
    );
  }
}

class PurpleDivider extends StatelessWidget {
  const PurpleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Colors.deepPurple,
    );
  }
}
