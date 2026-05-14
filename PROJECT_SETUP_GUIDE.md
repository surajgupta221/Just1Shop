# JUST1SHOP - Complete Project Setup Guide

## Project Status Summary

### ✅ Flutter Frontend (Android App)
- **Status**: Compilation errors fixed - **NO ERRORS**
- **Framework**: Flutter 3.10.0+
- **State Management**: BLoC pattern
- **Features**: Auth, Products, Cart, Checkout, Orders, Profile
- **Notifications**: Firebase Cloud Messaging + Local Notifications
- **Payment**: Razorpay integration (ready for production key)

### ✅ Python FastAPI Backend
- **Status**: Ready to run
- **Framework**: FastAPI + Uvicorn
- **Database**: Firestore (Firebase)
- **Features**: Products, Categories, Orders, Addresses, Banners, Offers, Coupons
- **Port**: 8000 (http://localhost:8000)
- **Auto-reload**: Enabled for development

### ✅ Python Flask Admin Dashboard
- **Status**: Ready to run
- **Framework**: Flask
- **Port**: 5000 (http://localhost:5000)
- **Features**: Product management, Category management, Offers, Banners

---

## Part 1: Flutter App Setup & Testing

### Prerequisites
- Flutter SDK 3.10.0 or higher
- Android SDK/Emulator or physical Android device
- Firebase project configured

### Step 1: Verify Compilation
```bash
cd e:\Just1Shop
flutter clean
flutter pub get
flutter analyze
```

**Expected Output**: `No issues found!`

### Step 2: Run Flutter App
```bash
# Run on Android emulator
flutter run -d emulator-5554

# Or run on physical device (connected via USB)
flutter run

# Run with specific build type
flutter run --profile
```

### Step 3: Firebase Configuration
Ensure your `google-services.json` is in the project root with:
- Firebase project ID from Google Cloud Console
- Valid authentication providers enabled (Phone Auth)
- Firestore database created

---

## Part 2: Python Backend Setup

### Prerequisites
- Python 3.10 or higher
- pip package manager
- Virtual environment (venv)

### Step 1: Setup FastAPI Backend

```bash
# Navigate to backend directory
cd e:\Just1Shop\just1shop-backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify installation
pip list
```

### Step 2: Configure Firebase Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your **Just1Shop** project
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click on service account → **Keys** → **Add Key** → **Create new key** (JSON)
5. Download the JSON file and save as `serviceAccountKey.json` in `just1shop-backend/`

```bash
# Verify file exists
ls just1shop-backend/serviceAccountKey.json
```

### Step 3: Run FastAPI Backend

```bash
# From just1shop-backend directory with venv activated
python run_server.py

# Or directly with uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

**Expected Output**:
```
Starting Just1Shop Backend Server...
Server will be available at http://0.0.0.0:8000
API documentation at http://localhost:8000/docs
```

**Verify Backend is Running**:
- Open browser: http://localhost:8000/docs
- You should see Swagger API documentation
- Try GET /products endpoint

### Step 4: Backend API Endpoints

```
GET  /products                  - Get all active products
POST /add-product               - Add new product
GET  /categories                - Get all categories
POST /add-category              - Add new category
GET  /addresses/{user_id}       - Get user addresses
POST /add-address               - Add new address
GET  /orders/{user_id}          - Get user orders
POST /add-order                 - Create new order
```

---

## Part 3: Python Admin Dashboard Setup

### Step 1: Setup Flask Admin

```bash
# Navigate to admin directory
cd e:\Just1Shop\just1shop-admin

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Configure Environment

Create/edit `.env` file:
```
BACKEND_URL=http://127.0.0.1:8000
FLASK_ENV=development
FLASK_DEBUG=1
```

### Step 3: Run Flask Admin

```bash
# From just1shop-admin directory with venv activated
python app.py

# Or using Flask CLI
flask run --port 5000
```

**Expected Output**:
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

**Access Admin Dashboard**: http://localhost:5000

---

## Part 4: Complete Testing Flow

### Test Scenario: End-to-End Order Flow

#### 1. **Backend Running** ✓
```bash
# Terminal 1
cd just1shop-backend
venv\Scripts\activate
python run_server.py
```

#### 2. **Admin Dashboard Running** ✓
```bash
# Terminal 2
cd just1shop-admin
venv\Scripts\activate
python app.py
```

#### 3. **Flutter App Running** ✓
```bash
# Terminal 3
cd .
flutter run
```

#### 4. **Test User Flow**
1. Launch app → See Splash Screen
2. Go to Auth Screen → Enter phone number
3. Verify OTP (Firebase auth)
4. See Home Screen with products from backend
5. Add items to cart
6. Proceed to checkout
7. Select delivery address
8. Choose payment method (COD or Razorpay with test key)
9. Place order
10. See order confirmation
11. Check order history

---

## Part 5: Firebase Configuration Checklist

### ✅ Firestore Collections Required
- `users` - User profiles
- `products` - Product catalog
- `categories` - Product categories
- `sub_categories` - Sub-categories
- `addresses` - Delivery addresses
- `orders` - Order history
- `banners` - Promotional banners
- `offers` - Special offers
- `festival_offers` - Festival promotions
- `coupons` - Coupon codes

### ✅ Authentication Methods
- Phone Authentication (enabled)
- Firebase Phone Auth provider configured

### ✅ Security Rules
Update Firestore rules to:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Part 6: Environment Variables

### Backend (.env)
```
FIREBASE_CREDENTIALS_PATH=serviceAccountKey.json
API_HOST=0.0.0.0
API_PORT=8000
ENVIRONMENT=development
```

### Admin Dashboard (.env)
```
BACKEND_URL=http://127.0.0.1:8000
FLASK_ENV=development
FLASK_DEBUG=1
```

---

## Part 7: Troubleshooting

### Flutter App Issues

**Error: ServiceAccountKey not found**
- Solution: Copy your Firebase service account JSON to project root

**Error: Phone authentication failed**
- Check Firebase Authentication is enabled
- Verify phone number format (+91XXXXXXXXXX for India)

**Error: Products not loading**
- Ensure backend is running on localhost:8000
- Check Firestore has products collection
- Verify Firebase credentials in backend

### Backend Issues

**Error: Firebase credentials file not found**
```bash
# Download from Firebase Console and place in:
just1shop-backend/serviceAccountKey.json
```

**Error: Port 8000 already in use**
```bash
# Use different port
uvicorn main:app --port 8001
```

**Error: Import products failed**
- Check product_spices.json exists
- Verify JSON format is correct
- Check Firestore write permissions

### Admin Dashboard Issues

**Error: Cannot connect to backend**
- Ensure backend is running on http://127.0.0.1:8000
- Check BACKEND_URL in .env file
- Verify no firewall blocking port 8000

---

## Part 8: Deployment Checklist

### Before Production:
- [ ] Replace Razorpay test key with production key
- [ ] Update Firebase security rules
- [ ] Configure CORS properly in backend
- [ ] Enable Firebase App Check
- [ ] Setup CI/CD pipeline (optional)
- [ ] Configure proper database backups
- [ ] Setup monitoring and analytics
- [ ] Test all payment flows
- [ ] Load test backend API

### Production Deployment:
```bash
# Build APK for Android
flutter build apk --release

# Build AAB for Play Store
flutter build appbundle --release

# Deploy backend (use proper hosting like Cloud Run, AWS, etc)
# Deploy admin dashboard (use proper web hosting)
```

---

## Part 9: Architecture Overview

```
Just1Shop/
├── lib/                        # Flutter frontend
│   ├── core/                   # Services, utilities, constants
│   ├── data/                   # Models, repositories
│   ├── presentation/           # BLoCs, screens, widgets
│   └── routes/                 # App routing
├── just1shop-backend/          # Python FastAPI backend
│   ├── main.py                 # API endpoints
│   ├── import_product.py       # Data import utilities
│   ├── serviceAccountKey.json  # Firebase credentials
│   └── requirements.txt        # Python dependencies
├── just1shop-admin/            # Python Flask admin
│   ├── app.py                  # Admin server
│   ├── templates/              # HTML templates
│   ├── static/                 # CSS, JS
│   └── requirements.txt        # Python dependencies
└── google-services.json        # Firebase config
```

---

## Quick Start Commands

### Complete Setup in 5 Minutes:

```bash
# 1. Backend
cd just1shop-backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
# Place serviceAccountKey.json here
python run_server.py

# 2. Admin (new terminal)
cd just1shop-admin
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app.py

# 3. App (new terminal)
cd .
flutter pub get
flutter run
```

---

## Need Help?

- **Firebase Issues**: Check Google Cloud Console IAM
- **Backend Issues**: Check http://localhost:8000/docs
- **Flutter Issues**: Run `flutter doctor -v`
- **Port Issues**: Use different ports or kill process using port

---

**Status**: ✅ **Project Ready for Testing**
- Flutter: No compilation errors
- Backend: All APIs ready
- Admin: Dashboard ready
- Firebase: Configuration required

**Next Steps**: Place Firebase credentials and run all three components!
