# JPM Food - Food Delivery Application

A comprehensive food delivery platform built with Flutter and Firebase, featuring dual interfaces for restaurant administrators and customers, enhanced with AI-powered assistance.

## Features

### Authentication & User Management
- Secure Firebase Authentication
- Role-based access control (Admin/Customer)
- Multi-page onboarding experience
- Profile management with image upload
- Password reset functionality

### Admin Features
- Restaurant profile configuration
- Menu category management
- Menu item CRUD operations
- Real-time inventory control
- Image upload for restaurant and menu items
- Dashboard with statistics

### Customer Features
- Restaurant discovery and browsing
- Category-based menu navigation
- Search functionality
- Shopping cart with quantity management
- Favorites system for restaurants and items
- AI-powered chatbot assistance (Google Gemini)
- Voice input support

## Tech Stack

**Frontend**
- Flutter 3.9.2+
- Dart
- Material Design 3

**Backend**
- Firebase Authentication
- Cloud Firestore
- Firebase Storage

**AI Integration**
- Google Gemini API

**State Management**
- Provider Pattern

**Navigation**
- GoRouter

## Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK
- Firebase account
- Google Gemini API key
- Android Studio / VS Code
- Xcode (for iOS development)

## Installation

1. Clone the repository
```bash
git clone [your-github-link]
cd jpm-food
```

2. Install dependencies
```bash
flutter pub get
```

3. Firebase Setup
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android app and download `google-services.json` to `android/app/`
   - Add iOS app and download `GoogleService-Info.plist` to `ios/Runner/`
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Firebase Storage
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. Configure AI Service
   - Get a Google Gemini API key from [Google AI Studio](https://aistudio.google.com/)
   - Create `lib/data/config/ai_config.dart`:
   ```dart
   class AiConfig {
     static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
   }
   ```

5. Run the application
```bash
flutter run
```

## Firebase Collections

The application uses the following Firestore collections:

- `users` - User profiles and roles
- `restaurants` - Restaurant information
- `categories` - Food categories
- `menuItems` - Menu items with details
- `favorites` - User favorite items
- `carts` - Shopping cart data

## Screenshots

[Add your app screenshots here]

## Configuration

### AppColors
Update `lib/data/config/app_colors.dart` to customize the app's color scheme:
```dart
class AppColors {
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFFF7931E);
}
```

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /menuItems/{itemId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurant_images/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /menu_items/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Testing

Run tests:
```bash
flutter test
```

## Dependencies

Key dependencies used in this project:

```yaml
dependencies:
  firebase_core: ^4.1.0
  cloud_firestore: ^6.0.1
  firebase_auth: ^5.0.1
  firebase_storage: ^13.0.1
  provider: ^6.1.5+1
  go_router: ^16.2.1
  http: ^0.13.6
  image_picker: ^1.2.0
  email_validator: ^3.0.0
  speech_to_text: ^7.3.0
  carousel_slider: ^5.1.1
```

## Troubleshooting

### Common Issues

**Firebase connection errors**
- Verify `google-services.json` is in the correct location
- Ensure Firebase project is properly configured
- Check internet connection

**Image upload failures**
- Verify Firebase Storage rules
- Check file permissions
- Ensure proper authentication

**AI chatbot not responding**
- Verify Gemini API key is correct
- Check API quota limits
- Ensure internet connectivity

## Future Enhancements

- Payment gateway integration
- Real-time order tracking
- Push notifications
- Rating and review system
- Delivery partner integration
- Advanced analytics dashboard
- Multi-language support

## Contributing

This is an academic project. For any issues or suggestions, please open an issue in the repository.

## License

This project is developed as part of an academic assignment.

## Acknowledgments

- Flutter Team for the amazing framework
- Firebase for backend services
- Google Gemini AI for chatbot capabilities
- Material Design for UI guidelines

---

**Version:** 1.0.0  
**Flutter Version:** 3.9.2+  
**Last Updated:** 2024