# Publishing Guide

This document outlines the steps required to publish the Sudoku app to various app stores.

## Common Steps

1. Update `pubspec.yaml`:
   ```yaml
   name: sudoku
   description: A beautiful and intuitive Sudoku game
   version: 1.0.0+1  # Format: version_name+version_code
   ```

2. Create a privacy policy (required by all stores)

3. Prepare store assets:
   - High-quality screenshots
   - App icon in various sizes
   - App description
   - Keywords
   - Support URL

4. Test thoroughly:
   ```bash
   flutter test
   flutter build [platform] --release
   ```

5. Consider using CI/CD:
   - GitHub Actions
   - Codemagic
   - Fastlane
   - These can automate the build and release process

## Android (Google Play Store)

### Prerequisites
- Google Play Developer account ($25 one-time fee)
- App assets:
  - App icon (512x512 PNG)
  - Feature graphic (1024x500 PNG)
  - Screenshots (at least 2)
  - App description
  - Privacy policy URL

### Build Steps
1. Build release bundle:
   ```bash
   flutter build appbundle
   ```
   The bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

2. Upload to Google Play Console:
   - Create new app
   - Upload bundle
   - Complete store listing
   - Set up pricing & distribution
   - Submit for review

## iOS (App Store)

### Prerequisites
- Apple Developer Program account ($99/year)
- App assets:
  - App icon (1024x1024 PNG)
  - Screenshots for different devices
  - App description
  - Privacy policy URL

### Build Steps
1. Build iOS app:
   ```bash
   flutter build ios
   ```

2. Open Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. In Xcode:
   - Set version and build numbers
   - Configure signing & capabilities
   - Archive the app
   - Upload to App Store Connect

4. Complete App Store listing and submit for review

## macOS (Mac App Store)

### Prerequisites
- Same Apple Developer Program account as iOS
- App assets (similar to iOS)

### Build Steps
1. Build macOS app:
   ```bash
   flutter build macos
   ```

2. Open Xcode:
   ```bash
   open macos/Runner.xcworkspace
   ```

3. In Xcode:
   - Set version and build numbers
   - Configure signing & capabilities
   - Archive the app
   - Upload to App Store Connect

4. Complete Mac App Store listing and submit for review

## Windows (Microsoft Store)

### Prerequisites
- Microsoft Partner Center account
- App assets:
  - App icon
  - Screenshots
  - App description
  - Privacy policy URL

### Build Steps
1. Build Windows app:
   ```bash
   flutter build windows
   ```

2. Create MSIX package:
   - Use MSIX Packaging Tool
   - Sign with your certificate

3. Upload to Partner Center and submit for review

## Linux (Snap Store)

### Prerequisites
- Ubuntu One account
- App assets:
  - App icon
  - Screenshots
  - App description

### Build Steps
1. Build Linux app:
   ```bash
   flutter build linux
   ```

2. Create snap package:
   - Create snapcraft.yaml
   - Build snap:
     ```bash
     snapcraft
     ```

3. Upload to Snap Store and submit for review

## Version Management

### Version Numbers
- Follow semantic versioning: MAJOR.MINOR.PATCH
- Example: 1.0.0, 1.0.1, 1.1.0, 2.0.0
- Update in `pubspec.yaml`

### Build Numbers
- Increment with each release
- Format: version_name+version_code
- Example: 1.0.0+1, 1.0.0+2

## Release Checklist

Before each release:
1. [ ] Update version numbers
2. [ ] Run all tests
3. [ ] Build release version
4. [ ] Test release build
5. [ ] Update changelog
6. [ ] Prepare store assets
7. [ ] Submit for review
8. [ ] Monitor review process
9. [ ] Plan post-release monitoring

## Troubleshooting

### Common Issues
1. Build failures
   - Check Flutter version
   - Verify dependencies
   - Clean build:
     ```bash
     flutter clean
     flutter pub get
     ```

2. Store rejections
   - Review guidelines
   - Check metadata
   - Verify assets
   - Test on multiple devices

### Support
- Flutter documentation: https://docs.flutter.dev
- Platform-specific documentation:
  - Android: https://developer.android.com
  - iOS: https://developer.apple.com
  - Windows: https://docs.microsoft.com
  - macOS: https://developer.apple.com
  - Linux: https://snapcraft.io/docs 