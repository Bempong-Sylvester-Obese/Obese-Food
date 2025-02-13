# Obese Food Architecture

## Overview
Obese Food is a mobile application that leverages AI-powered food image recognition to analyze meal components and provide nutritional insights. The app features a gamified system where users earn Oex points for meeting dietary goals and promotes healthier eating habits.

## System Architecture

### 1️⃣ **Frontend (Mobile Application)**
- **Platform**: iOS (Swift + SwiftUI)
- **UI Framework**: SwiftUI
- **State Management**: Combine
- **Navigation**: SwiftUI NavigationStack
- **Data Storage**: CoreData (for local caching)
- **APIs Used**:
  - Camera & Photo Library Access (for food image input)
  - AI/ML Model Integration (CoreML/TensorFlow Lite)
  - Firebase Authentication & Firestore

### 2️⃣ **Backend**
- **Cloud Service**: Firebase
- **Authentication**: Firebase Authentication (Email, Google Sign-in, Apple Sign-in)
- **Database**: Firestore (NoSQL)
- **Storage**: Firebase Cloud Storage (for storing images)
- **AI Processing**: Server-side TensorFlow model for food recognition
- **Functions**: Firebase Cloud Functions (for processing and updating nutritional data)

### 3️⃣ **AI Model**
- **Framework**: CoreML / TensorFlow Lite
- **Purpose**: Identifies food items from user-uploaded images and calculates nutritional value
- **Dataset**: Trained on a large dataset of food images with labeled nutritional data

### 4️⃣ **Gamification & Rewards System**
- Users earn **Oex Points** based on:
  - Daily meal tracking
  - Healthy food choices
  - Community challenges
- Points can be redeemed for in-app rewards and discounts

## Future Enhancements
- 📱 **Android App**: Expansion to Flutter or Kotlin for cross-platform support
- 🤖 **Advanced AI**: Improved food detection accuracy with larger datasets
- 🌍 **Community Features**: Social leaderboards, sharing meal insights

This architecture ensures a **scalable, secure, and seamless** user experience while promoting healthy eating habits through technology. 🚀
