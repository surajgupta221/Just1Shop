---
name: just1shop-general
applyTo: "**/*"
description: "General Just1Shop project context and conventions. Use for: understanding project structure, finding files, learning conventions. Applies to all files in workspace."
---

# Just1Shop Project Context & Conventions

## Project Overview
**Just1Shop** is a Flutter/Dart mobile app with Python backend, serving:
- 👤 Customers (shopping, ordering, payment)
- 🚗 Delivery Boys (real-time tracking, order delivery)
- 🔧 Admin Panel (product/user management, analytics)
- 👑 Owner (system monitoring, business metrics)

**Stack**:
- Frontend: Flutter/Dart
- Backend: Python (Flask)
- Admin: Python/Flask Web
- Database: Firebase (Firestore, Auth, Storage)
- Payments: Razorpay
- Maps: Google Maps API
- Notifications: Firebase Cloud Messaging

---

## Project Structure

```
lib/                          # Flutter app source
  ├── main.dart              # App entry point
  ├── core/                  # Business logic, services
  │   ├── firestore/         # Database operations
  │   ├── auth/              # Authentication
  │   └── location/          # GPS tracking
  ├── data/                  # Data models, repositories
  │   ├── models/            # Dart classes
  │   └── repositories/      # API calls, DB queries
  └── presentation/          # UI screens, widgets
      ├── screens/           # Full screens
      ├── widgets/           # Reusable components
      └── providers/         # State management

just1shop-backend/           # Python Flask backend
  ├── main.py               # API endpoints
  ├── requirements.txt       # Dependencies
  ├── tests/                # Unit tests
  └── uploads/              # Uploaded files storage

just1shop-admin/            # Admin web panel
  ├── app.py                # Flask app
  ├── templates/            # HTML templates
  └── static/               # CSS, JS

android/                    # Android-specific config
  ├── build.gradle          # Build configuration
  ├── local.properties       # Local paths
  └── app/src/              # Android source

pubspec.yaml               # Flutter dependencies
google-services.json       # Firebase config (KEEP PRIVATE)
Firestore Database Structure.js  # Schema docs
Firestore Security Rules.js     # Auth rules
```

---

## Key Conventions

### Dart/Flutter
- **Naming**: Classes `PascalCase`, functions `camelCase`, constants `UPPER_CASE`
- **Files**: One class per file, named after class in snake_case
- **State**: Use Provider for global state, StatefulWidget for local
- **Async**: Always use `async/await`, handle `FirebaseException`
- **Imports**: Group by `dart`, `package`, `relative`

### Python
- **Style**: Follow PEP 8, use `snake_case` for functions/variables
- **Error Handling**: All routes wrapped in try-catch, return JSON errors
- **Validation**: Input validation on all API endpoints
- **Logging**: Use Python logging module, not print()
- **Imports**: Group by stdlib, third-party, local

### File Naming
- Dart: `user_profile.dart`, `auth_service.dart`
- Python: `user_routes.py`, `firestore_client.py`
- Classes: `UserProfile`, `AuthService`
- Constants: `DEFAULT_TIMEOUT`, `MAX_RETRIES`

---

## Common Commands

### Build & Run
```bash
# Flutter
flutter pub get                 # Get dependencies
flutter run                     # Run on device
flutter run --release           # Release build

# Python Backend
pip install -r requirements.txt # Install deps
python main.py                  # Start server
python run_server.py            # Production server

# Admin Panel
python just1shop-admin/app.py   # Start admin web
```

### Testing
```bash
# Flutter
flutter test                    # Run unit tests
flutter test --coverage         # With coverage

# Python
pytest just1shop-backend/tests/ # Run tests
```

### Build APK/Web
```bash
flutter build apk --release      # Android APK
flutter build web --release      # Web version
flutter build aab --release      # Play Store bundle
```

---

## Key Files & Their Purpose

| File | Purpose | Role |
|------|---------|------|
| `Customer Home Screen.dart` | Main customer UI | Customer/Admin |
| `lib/core/auth/` | Firebase authentication | All |
| `lib/core/firestore/` | Database operations | All |
| `just1shop-backend/main.py` | API endpoints | Admin/Backend Dev |
| `pubspec.yaml` | Dependencies (Dart) | All |
| `Firestore Database Structure.js` | Data schema docs | Admin/Owner |
| `Firestore Security Rules.js` | Access control | Owner/Admin |
| `android/build.gradle` | Android config | Android Dev |

---

## Version & Compatibility Notes

- **Minimum Flutter**: 3.0.0
- **Min Android**: API 21 (Android 5.0)
- **Target Android**: API 33+ (Play Store requirement)
- **Firebase**: Latest stable (v9+)
- **Dart**: 2.18+
- **Python**: 3.8+

---

## Debugging Tips

**Flutter crashes?**
- Check `flutter doctor`
- Review iOS/Android logs
- Check Firebase auth/Firestore connectivity

**Backend API failing?**
- Check Python error logs
- Verify Firestore rules allow operation
- Check network connectivity

**Build failures?**
- Run `flutter clean && flutter pub get`
- Check Gradle version compatibility
- Verify google-services.json present

**Slow app?**
- Profile with DevTools
- Check Firestore query indexes
- Reduce image sizes

---

## Communication with Other Developers

When reporting bugs:
1. Specify role (owner/admin/delivery/user)
2. Describe what you were doing
3. What error appeared (exact message)
4. Device/platform (Android/iOS)
5. Attached relevant logs

Example:
> "Customer role: Getting Firebase auth error when signing up. Screen: Login > Sign Up button. Error: 'operation-not-allowed'. Device: Android API 28"

---

## Important: Never Commit
- ❌ `google-services.json` (use `.gitignore`)
- ❌ `serviceAccountKey.json`
- ❌ Environment keys, passwords, API keys
- ❌ `build/`, `*.iml`, `.env`

---

## Useful Documentation Links

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Dart Language](https://dart.dev/guides)
- [Python Flask](https://flask.palletsprojects.com)
- [Razorpay Integration](https://razorpay.com/docs/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
