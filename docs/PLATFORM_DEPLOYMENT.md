# Platform-Specific Deployment Instructions

This document provides detailed instructions for deploying the Moments to Remember app to different platforms from various branches.

## Web Deployment

### Firebase Hosting (Recommended)

1. **Setup Firebase Projects**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize hosting in your project
   firebase init hosting
   ```

2. **Configure Multiple Environments**
   ```bash
   # Copy template
   cp .firebaserc.template .firebaserc
   cp firebase.json.template firebase.json
   
   # Edit .firebaserc with your project IDs
   ```

3. **Deploy Manually**
   ```bash
   # Production
   flutter build web --release
   firebase use production
   firebase deploy --only hosting
   
   # Staging  
   flutter build web --release --dart-define=ENVIRONMENT=staging
   firebase use staging
   firebase deploy --only hosting
   ```

### Alternative Web Hosting

#### Netlify
```bash
# Build
flutter build web --release

# Deploy (using Netlify CLI)
netlify deploy --prod --dir=build/web
```

#### Vercel
```bash
# Build
flutter build web --release

# Deploy (using Vercel CLI)
vercel --prod build/web
```

#### GitHub Pages
```bash
# Build with base href
flutter build web --base-href "/moments-to-remember/"

# The GitHub Action will handle deployment automatically
```

## Mobile Deployment

### Android

#### APK for Testing
```bash
# Development/Testing APK
flutter build apk --debug
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

#### Play Store (AAB)
```bash
# Build App Bundle
flutter build appbundle --release

# Upload to Play Console
# File location: build/app/outputs/bundle/release/app-release.aab
```

#### Signing Configuration
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password  
keyAlias=your_key_alias
storeFile=../keystore.jks
```

### iOS

#### Development Build
```bash
# Build for iOS
flutter build ios --debug

# Open in Xcode
open ios/Runner.xcworkspace
```

#### App Store
```bash
# Build for release
flutter build ios --release

# Open Xcode for archiving and upload
open ios/Runner.xcworkspace
```

#### TestFlight
1. Archive in Xcode
2. Upload to App Store Connect
3. Submit for TestFlight review

## Desktop Deployment

### Linux
```bash
# Enable Linux desktop
flutter config --enable-linux-desktop

# Install dependencies (Ubuntu/Debian)
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# Build
flutter build linux --release

# Package (optional)
cd build/linux/x64/release/bundle
tar -czf moments-to-remember-linux.tar.gz *
```

### Windows
```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Build (requires Visual Studio or Build Tools)
flutter build windows --release

# Installer (optional - requires Inno Setup or similar)
# Create installer script to package build/windows/runner/Release/
```

### macOS
```bash
# Enable macOS desktop
flutter config --enable-macos-desktop

# Build
flutter build macos --release

# Create DMG (optional)
# Use tools like create-dmg or dropdmg
```

## Environment-Specific Configuration

### Using dart-define for Environment Variables

```bash
# Development
flutter build web --dart-define=ENVIRONMENT=development --dart-define=API_URL=https://dev-api.example.com

# Staging
flutter build web --dart-define=ENVIRONMENT=staging --dart-define=API_URL=https://staging-api.example.com

# Production  
flutter build web --dart-define=ENVIRONMENT=production --dart-define=API_URL=https://api.example.com
```

### In Dart Code
```dart
const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');
```

## Automated Deployment Strategies

### Branch-based Deployment

| Branch | Environment | Platforms | Auto Deploy |
|--------|-------------|-----------|-------------|
| `main` | Production | Web, Android, Desktop | ✅ |
| `staging` | Staging | Web, Android | ✅ |
| `develop` | Development | Web | ✅ |
| `feature/*` | Development | Web (manual) | ❌ |

### Tag-based Deployment
```bash
# Create release tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# This can trigger production deployment
```

## Deployment Checklist

### Before Deployment
- [ ] Run tests: `flutter test`
- [ ] Code analysis: `flutter analyze`
- [ ] Check dependencies: `flutter pub deps`
- [ ] Update version in `pubspec.yaml`
- [ ] Update CHANGELOG.md
- [ ] Test on target platforms

### Web Deployment
- [ ] Build successful: `flutter build web --release`
- [ ] Test locally: `flutter run -d web-server`
- [ ] Check responsive design
- [ ] Verify PWA features
- [ ] Test on different browsers

### Mobile Deployment
- [ ] Test on physical devices
- [ ] Check app permissions
- [ ] Verify app icons and splash screens
- [ ] Test offline functionality
- [ ] Performance testing

### Desktop Deployment
- [ ] Test on target OS
- [ ] Check window resizing
- [ ] Verify keyboard shortcuts
- [ ] Test file system access
- [ ] Package and installer testing

## Rollback Procedures

### Web Rollback
```bash
# Firebase Hosting
firebase hosting:clone source-site-id:version-id target-site-id

# Manual rollback
git checkout previous-good-commit
flutter build web --release
firebase deploy --only hosting
```

### Mobile Rollback
- **Android**: Upload previous APK/AAB to Play Console
- **iOS**: Revert to previous App Store version

### Desktop Rollback
- Redistribute previous build artifacts
- Update download links

## Monitoring and Analytics

### Web Analytics
```javascript
// Add to web/index.html
gtag('config', 'GA_MEASUREMENT_ID');
```

### Mobile Analytics
```yaml
# Add to pubspec.yaml
dependencies:
  firebase_analytics: ^10.7.4
```

### Performance Monitoring
```yaml
# Add to pubspec.yaml
dependencies:
  firebase_performance: ^0.9.3+9
```

## Security Considerations

### Secrets Management
- Use GitHub Secrets for sensitive data
- Rotate credentials regularly
- Never commit API keys or passwords
- Use environment-specific configurations

### Code Signing
- Store certificates securely
- Use different certificates for different environments
- Keep private keys encrypted

### Content Security Policy (Web)
```html
<!-- Add to web/index.html -->
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline';">
```

This guide should provide comprehensive coverage for deploying the Moments to Remember app across all supported platforms and environments.