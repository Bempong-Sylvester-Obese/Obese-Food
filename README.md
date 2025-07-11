# Obese Food 🍏📱

> **AI-Powered Food Recognition & Nutrition Tracking App**

Obese Food is an innovative iOS application that leverages **AI-powered food image recognition** to help users track and manage their nutrition. Simply take a photo of your meal and instantly receive detailed nutritional insights. The app promotes healthy eating habits through a gamified system where users earn **Oex points** for meeting their dietary goals.

## ✨ Key Features

### 🍽️ **Smart Food Recognition**
- **AI-Powered Analysis**: Uses CoreML and Vision framework for accurate food detection
- **Instant Results**: Get nutritional breakdown within seconds
- **Ghanaian Cuisine Support**: Optimized for local dishes like Jollof Rice, Waakye, Banku, and Fufu

### 📊 **Nutritional Insights**
- **Calorie Tracking**: Monitor daily calorie intake
- **Macro Breakdown**: Detailed protein, fat, and carbohydrate analysis
- **Health Metrics**: Track sugar content and nutritional values

### 🎮 **Gamification System**
- **Oex Points**: Earn rewards for healthy eating choices
- **Achievement Levels**: Progress through different tiers
- **Goal Setting**: Set and track dietary objectives

### 👤 **User Management**
- **Profile Management**: Personalize your experience
- **Dietary Preferences**: Set custom food preferences
- **Activity Tracking**: Monitor health goals and activity levels

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | Swift + SwiftUI |
| **Backend** | Firebase (Firestore, Authentication, Storage) |
| **AI/ML** | CoreML, Vision Framework |
| **Cloud Functions** | Node.js (Firebase Functions) |
| **Image Processing** | Google Cloud Vision API |

## 📱 App Structure

```
ObeseFood/
├── Views/
│   ├── HomeView.swift          # Main camera and analysis interface
│   ├── NutritionView.swift     # Nutritional statistics and food database
│   └── ProfileView.swift       # User profile and settings
├── Models/
│   ├── FoodModel.swift         # Food data structure
│   └── UserModel.swift         # User data structure
├── Services/
│   ├── AIRecognition.swift     # AI food recognition service
│   └── FirebaseService.swift   # Firebase integration
└── Backend/
    └── analyzeFood.js          # Cloud function for image analysis
```

## 🚀 Getting Started

### Prerequisites
- Xcode 13.0+
- iOS 13.0+
- Firebase account
- Google Cloud Vision API access

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/Bempong-Sylvester-Obese/Obese-Food.git
   cd Obese-Food
   ```

2. Install dependencies
   ```bash
   # Swift Package Manager dependencies are handled by Xcode
   ```

3. Configure Firebase
   - Add your `GoogleService-Info.plist` to the project
   - Configure Firebase Authentication and Firestore

4. Build and run
   ```bash
   open ObeseFoodApp.xcodeproj
   ```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication, Firestore, and Storage
3. Download `GoogleService-Info.plist` and add to project
4. Configure security rules for Firestore

### AI Model Configuration
- Ensure CoreML model is properly integrated
- Configure Vision framework permissions
- Set up Google Cloud Vision API credentials

## 📊 Features in Detail

### Food Recognition
- **Real-time Analysis**: Process images instantly using CoreML
- **Accuracy**: Trained on diverse food datasets
- **Local Processing**: Privacy-focused on-device analysis

### Data Management
- **Cloud Storage**: Secure data storage with Firebase
- **Offline Support**: Local caching for offline access
- **Sync**: Automatic data synchronization across devices

## 🎯 Future Roadmap

### Phase 1 (Current)
- ✅ Basic food recognition
- ✅ Nutritional tracking
- ✅ User profiles
- ✅ Firebase integration

### Phase 2 (Planned)
- 📱 Android version development
- 🧠 Advanced AI meal planning
- 🌍 Social features and leaderboards
- 📈 Advanced analytics and insights

### Phase 3 (Future)
- 🤖 Personalized AI recommendations
- 🏥 Healthcare provider integration
- 🌐 Multi-language support
- 📊 Advanced health metrics

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Firebase** for backend services
- **Apple** for CoreML and Vision frameworks
- **Google Cloud** for Vision API
- **SwiftUI** for modern UI development

---

<div align="center">

**Made with ❤️ for healthier eating habits**

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-yellow.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>


