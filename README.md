# Moments to Remember

A Flutter event reservation application with basket system and notifications.

## Features

- **Event Reservation System**: Browse and reserve spots for various events
- **Basket/Cart System**: Add multiple events to basket before submitting reservations
- **Notification System**: Get notified when your event reservations are approved or declined
- **Profile Management**: Upload and manage profile images with support for multiple formats
- **Responsive Design**: Optimized for both mobile and web/desktop platforms
- **Serbian Localization**: Complete Serbian UI translation
- **Universal Image Support**: Handles asset, network, and base64 images seamlessly

## Screenshots

*Add screenshots of your app here*

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS development setup (for iOS deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/moments-to-remember.git
cd moments-to-remember
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For mobile development
flutter run

# For web development on specific port
flutter run -d web-server --web-port 56789
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── event_models.dart
│   ├── user.dart
│   └── notification.dart
├── screens/                  # UI screens
│   ├── home_page.dart
│   ├── featured_events_page.dart
│   ├── event_details_page.dart
│   ├── basket_page.dart
│   ├── notifications_page.dart
│   ├── profile_settings_page.dart
│   └── ...
└── widgets/                  # Reusable widgets
    ├── common_header.dart
    ├── universal_image.dart
    └── ...
```

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Material Design**: UI components and theming
- **Image Picker**: Profile image upload functionality
- **SharedPreferences**: Local data storage

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
Project Link: [https://github.com/YOUR_USERNAME/moments-to-remember](https://github.com/YOUR_USERNAME/moments-to-remember)
