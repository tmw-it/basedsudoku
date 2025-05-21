#!/bin/bash

# Get version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
VERSION_CODE=$(grep '^version:' pubspec.yaml | sed 's/.*+//')

# Build the APK
flutter build apk --release

# Rename the output files
mv build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/based_sudoku_${VERSION}_${VERSION_CODE}.apk"
mv build/app/outputs/flutter-apk/app-release.apk.sha1 "build/app/outputs/flutter-apk/based_sudoku_${VERSION}_${VERSION_CODE}.apk.sha1"

echo "APK built and renamed to: based_sudoku_${VERSION}_${VERSION_CODE}.apk" 