# Obese Food App - Setup Guide

## 🚀 Quick Start

This guide will help you set up the Obese Food app for development and deployment.

## 📋 Prerequisites

- **Xcode 13.0+** (for iOS development)
- **iOS 13.0+** target device or simulator
- **Firebase account** (free tier available)
- **Apple Developer account** (for device testing and App Store deployment)

## 🔧 Setup Steps

### 1. Firebase Configuration

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Name it "Obese Food" or similar
   - Enable Google Analytics (recommended)

2. **Add iOS App to Firebase**
   - Click "Add app" and select iOS
   - Bundle ID: `com.obesefood.app` (or your preferred bundle ID)
   - Download `GoogleService-Info.plist`
   - Replace the placeholder file in `firebase/GoogleService-Info.plist`

3. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password and Google Sign-In
   - **Firestore Database**: Create database in production mode
   - **Storage**: Enable for image uploads
   - **Functions**: Enable for server-side processing

### 2. Xcode Project Setup

1. **Open the project**
   ```bash
   cd /Users/sylvesterbempong/Desktop/Projects/Obese-Food
   open ObeseFoodApp.xcodeproj
   ```

2. **Configure Bundle Identifier**
   - Select your project in Xcode
   - Go to "Signing & Capabilities"
   - Set your team and bundle identifier

3. **Add Firebase Configuration**
   - Drag `GoogleService-Info.plist` into your Xcode project
   - Make sure it's added to the target

### 3. Dependencies

The project uses Swift Package Manager. Dependencies will be resolved automatically when you build the project.

**Current Dependencies:**
- Firebase iOS SDK (Authentication, Firestore, Storage, Functions)

### 4. Build and Run

1. **Select Target Device**
   - Choose iOS Simulator or connected device
   - Minimum iOS 13.0

2. **Build Project**
   - Press `Cmd + B` to build
   - Press `Cmd + R` to run

## 🛠️ Development Features

### ✅ Implemented Features

- **Authentication System**: Email/password sign-up and sign-in
- **Food Recognition**: Basic image analysis (simulated)
- **Gamification**: Oex points system with levels and achievements
- **User Profiles**: Profile management with image upload
- **Navigation**: Tab-based navigation between main screens
- **Nutrition Tracking**: Basic nutrition information display

### 🔄 Current Limitations

- **AI Model**: Currently using simulated food recognition
- **Real-time Analysis**: No actual CoreML model integration
- **Data Persistence**: Limited to UserDefaults for gamification
- **Offline Support**: No offline data caching

## 🎯 Next Development Steps

### Phase 1: Core AI Integration
1. **Train CoreML Model**
   - Collect food image dataset
   - Train model for Ghanaian cuisine recognition
   - Integrate trained model into app

2. **Real Food Recognition**
   - Replace simulation with actual CoreML analysis
   - Add confidence thresholds
   - Implement fallback to Google Vision API

### Phase 2: Enhanced Features
1. **Data Persistence**
   - Implement CoreData for local storage
   - Add Firebase Firestore integration
   - Sync data across devices

2. **Advanced Gamification**
   - Add more achievement types
   - Implement social features
   - Create leaderboards

### Phase 3: Production Ready
1. **Testing**
   - Unit tests for core functionality
   - UI tests for user flows
   - Integration tests for Firebase

2. **Performance Optimization**
   - Image compression and caching
   - Efficient data loading
   - Background processing

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure all dependencies are resolved
   - Check bundle identifier matches Firebase config
   - Verify iOS deployment target is 13.0+

2. **Firebase Connection Issues**
   - Verify `GoogleService-Info.plist` is in project
   - Check Firebase project configuration
   - Ensure proper bundle ID matching

3. **Authentication Issues**
   - Verify Firebase Auth is enabled
   - Check email/password authentication is enabled
   - Test with valid email addresses

### Getting Help

- Check the [Firebase Documentation](https://firebase.google.com/docs)
- Review [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- Check project issues in the repository

## 📱 Testing

### Simulator Testing
- Use iOS Simulator for basic functionality testing
- Test different screen sizes and orientations
- Verify navigation and UI responsiveness

### Device Testing
- Test on physical device for camera functionality
- Verify image picker works correctly
- Test authentication flows

## 🚀 Deployment

### App Store Preparation
1. **App Store Connect Setup**
   - Create app listing
   - Add app description and screenshots
   - Set up pricing and availability

2. **Build for Distribution**
   - Archive the app in Xcode
   - Upload to App Store Connect
   - Submit for review

### Firebase Hosting (Optional)
- Deploy Firebase Functions
- Set up custom domain
- Configure security rules

## 📊 Analytics and Monitoring

### Firebase Analytics
- Track user engagement
- Monitor app performance
- Analyze user behavior

### Crashlytics (Recommended)
- Add Firebase Crashlytics
- Monitor app crashes
- Get detailed crash reports

---

**Happy Coding! 🎉**

For questions or issues, please check the project documentation or create an issue in the repository.
