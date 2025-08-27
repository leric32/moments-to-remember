import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/featured_events_page.dart';
import 'screens/basket_page.dart';
import 'screens/profile_settings_page.dart';
import 'screens/organizer_dashboard.dart';
import 'screens/event_types_page.dart';
import 'screens/create_event_page.dart';
import 'screens/event_details_page.dart';
import 'screens/notifications_page.dart';
import 'models/user.dart';
import 'models/event_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize users and events
  await initializeUsers();
  await initializeEvents();

  runApp(const MomentsToRememberApp());
}

class MomentsToRememberApp extends StatelessWidget {
  const MomentsToRememberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trenuci za pamćenje',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamilyFallback: const [
          'Roboto',
          'Noto Sans',
          'Noto Serif',
          'Arial Unicode MS',
          'Helvetica',
        ],
      ),
      home: FutureBuilder<User?>(
        future: UserManager.loadCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF6F3FF),
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple,
                ),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            currentUser = snapshot.data;
            // Check user type to determine which page to show
            if (currentUser!.userType == 'organizator') {
              return const OrganizerDashboard();
            } else {
              return const HomePage();
            }
          }

          return const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/events': (context) => const FeaturedEventsPage(),
        '/basket': (context) => const BasketPage(),
        '/profile': (context) => const ProfileSettingsPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/organizer-dashboard': (context) => const OrganizerDashboard(),
        '/event-types': (context) => const EventTypesPage(),
        '/create-event': (context) => const CreateEventPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/event-details') {
          final eventId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<List<EventData>>(
              future: EventManager.loadEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error loading event details'),
                    ),
                  );
                }

                final events = snapshot.data!;
                final event = events.firstWhere(
                  (e) => e.id == eventId,
                  orElse: () => events.first,
                );

                return EventDetailsPage(eventId: event.id);
              },
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
