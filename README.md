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

## Deployment

### How to Deploy from a Branch

This section covers different deployment strategies for the Moments to Remember Flutter application from various branches.

#### Prerequisites for Deployment

- Flutter SDK (latest stable version)
- Dart SDK
- Platform-specific build tools (Android SDK, Xcode for iOS, etc.)
- Access to deployment targets (Firebase Hosting, Play Store, App Store, etc.)

#### Manual Deployment

##### 1. Web Deployment

Deploy the web version from any branch:

```bash
# Switch to your deployment branch
git checkout <branch-name>

# Install dependencies
flutter pub get

# Build for web production
flutter build web --release

# Deploy to Firebase Hosting (if configured)
firebase deploy --only hosting

# Or deploy to any static hosting service
# The built files will be in build/web/
```

##### 2. Android Deployment

Deploy Android APK/AAB from any branch:

```bash
# Switch to your deployment branch
git checkout <branch-name>

# Install dependencies
flutter pub get

# Build APK for testing
flutter build apk --release

# Build AAB for Play Store
flutter build appbundle --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
# AAB location: build/app/outputs/bundle/release/app-release.aab
```

##### 3. iOS Deployment

Deploy iOS app from any branch (requires macOS):

```bash
# Switch to your deployment branch
git checkout <branch-name>

# Install dependencies
flutter pub get

# Build for iOS
flutter build ios --release

# Open in Xcode for further processing
open ios/Runner.xcworkspace
```

##### 4. Desktop Deployment

Deploy desktop versions from any branch:

```bash
# Switch to your deployment branch
git checkout <branch-name>

# Install dependencies
flutter pub get

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

#### Automated Deployment with GitHub Actions

The repository includes GitHub Actions workflows for automated deployment from specific branches:

- **`main` branch**: Deploys to production
- **`staging` branch**: Deploys to staging environment
- **`develop` branch**: Deploys to development environment

##### Branch-specific Deployment Triggers

1. **Production Deployment**: Push to `main` branch
2. **Staging Deployment**: Push to `staging` branch  
3. **Development Deployment**: Push to `develop` branch
4. **Manual Deployment**: Use workflow dispatch for any branch

##### Environment Variables

Configure the following secrets in your GitHub repository:

```
FIREBASE_TOKEN          # For web deployment
ANDROID_KEYSTORE        # For Android signing
ANDROID_KEY_ALIAS       # Android key alias
ANDROID_STORE_PASSWORD  # Android store password
ANDROID_KEY_PASSWORD    # Android key password
```

#### Deployment Environments

##### Production (`main` branch)
- Web: Deployed to production Firebase Hosting
- Mobile: Ready for app store submission
- Desktop: Production builds generated

##### Staging (`staging` branch)  
- Web: Deployed to staging Firebase Hosting
- Mobile: Beta testing builds
- Desktop: Testing builds

##### Development (`develop` branch)
- Web: Deployed to development Firebase Hosting
- Mobile: Development builds
- Desktop: Development builds

#### Hot Deployment Tips

1. **Quick Web Deploy**: Use `flutter run -d web-server --web-port 56789` for local testing
2. **Branch Switching**: Always run `flutter clean && flutter pub get` after switching branches
3. **Build Optimization**: Use `--dart-define` for environment-specific configurations
4. **Testing**: Run `flutter test` before deployment to ensure code quality

#### Troubleshooting Deployment

- **Build Failures**: Check Flutter doctor: `flutter doctor`
- **Dependencies**: Clear pub cache: `flutter pub cache repair`
- **Platform Issues**: Update platform-specific dependencies
- **Branch Conflicts**: Ensure branch is up-to-date before deployment

For detailed platform-specific deployment instructions, see [Platform Deployment Guide](docs/PLATFORM_DEPLOYMENT.md).

For complete deployment setup instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Project Link: [https://github.com/YOUR_USERNAME/moments-to-remember](https://github.com/YOUR_USERNAME/moments-to-remember)
