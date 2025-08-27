# Deployment Setup Guide

This guide explains how to configure deployment for the Moments to Remember Flutter application from different branches.

## Quick Setup

### 1. Firebase Setup (for Web Deployment)

1. Create Firebase projects for each environment:
   - Production: `moments-to-remember-prod`
   - Staging: `moments-to-remember-staging`  
   - Development: `moments-to-remember-dev`

2. Copy and configure Firebase files:
   ```bash
   cp .firebaserc.template .firebaserc
   cp firebase.json.template firebase.json
   ```

3. Update `.firebaserc` with your project IDs:
   ```json
   {
     "projects": {
       "production": "moments-to-remember-prod",
       "staging": "moments-to-remember-staging",
       "development": "moments-to-remember-dev"
     }
   }
   ```

4. Get Firebase token:
   ```bash
   firebase login:ci
   ```

5. Add the token to GitHub Secrets as `FIREBASE_TOKEN`

### 2. GitHub Secrets Configuration

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):

#### Required Secrets
- `FIREBASE_TOKEN`: Firebase CLI token for web deployment

#### Optional Secrets (for Android signing)
- `ANDROID_KEYSTORE`: Base64 encoded keystore file
- `ANDROID_KEY_ALIAS`: Key alias for signing
- `ANDROID_STORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password

### 3. Branch Strategy

The deployment workflow supports these branches:

- **`main`**: Production deployment
- **`staging`**: Staging deployment
- **`develop`**: Development deployment

### 4. Manual Deployment

You can trigger manual deployment from any branch using GitHub Actions:

1. Go to Actions tab in your repository
2. Select "Deploy from Branch" workflow
3. Click "Run workflow"
4. Choose environment and branch
5. Click "Run workflow"

## Environment Configuration

### Production Environment
- Branch: `main`
- Web: Firebase Hosting (production project)
- Android: Signed APK + AAB for Play Store
- Desktop: All platforms (Linux, Windows, macOS)

### Staging Environment  
- Branch: `staging`
- Web: Firebase Hosting (staging project)
- Android: Signed APK for testing
- Desktop: None (to save build time)

### Development Environment
- Branch: `develop` or any other branch
- Web: Firebase Hosting (development project)
- Android: None (to save build time)
- Desktop: None (to save build time)

## Local Development Deployment

### Web Development Server
```bash
flutter run -d web-server --web-port 56789
```

### Build Locally for Testing
```bash
# Web
flutter build web --release

# Android
flutter build apk --release

# Desktop (example for Linux)
flutter build linux --release
```

## Troubleshooting

### Common Issues

1. **Firebase deployment fails**
   - Check if `FIREBASE_TOKEN` secret is set
   - Verify project IDs in `.firebaserc`
   - Ensure Firebase projects exist and hosting is enabled

2. **Android build fails**
   - Check Java version (should be 17)
   - Verify Android SDK setup
   - Check if all dependencies are compatible

3. **Desktop build fails**
   - Ensure platform is enabled: `flutter config --enable-<platform>-desktop`
   - Install platform-specific dependencies
   - Check Flutter version compatibility

### Getting Help

1. Check GitHub Actions logs for detailed error messages
2. Run `flutter doctor` to verify local setup
3. Test builds locally before pushing to repository

## Security Best Practices

1. Never commit Firebase configuration files with real project IDs to public repositories
2. Use environment-specific Firebase projects
3. Rotate Firebase tokens regularly
4. Use signed builds for production Android releases
5. Keep sensitive data in GitHub Secrets, not in code

## Advanced Configuration

### Custom Environment Variables

You can pass custom environment variables to the build:

```yaml
flutter build web --dart-define=API_URL=https://api.production.com
```

Add these in the workflow file under the build steps.

### Multiple Firebase Sites

For multiple hosting sites per environment, update `firebase.json`:

```json
{
  "hosting": [
    {
      "target": "main-site",
      "public": "build/web"
    },
    {
      "target": "admin-site", 
      "public": "build/admin"
    }
  ]
}
```

### Branch Protection

Consider setting up branch protection rules:
- Require PR reviews for `main` and `staging`
- Require status checks to pass
- Restrict force pushes

This ensures deployments only happen from properly reviewed code.