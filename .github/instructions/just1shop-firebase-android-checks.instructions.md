---
name: just1shop-firebase-android-checks
applyTo: "Firestore Database Structure.js,Firestore Security Rules.js,google-services.json,android/**/*.gradle,pubspec.yaml"
description: "Firebase integration and Android build health checks for Just1Shop. Validates Firestore rules, Google services config, dependency versions, and build configuration. Use when: setting up Firebase, debugging auth/database issues, or checking Android builds."
---

# Firebase & Android Build Health Checks

## Firebase Integration Checks

### 1. Google Services Configuration
**File**: `google-services.json` (root & `android/app/`)

Checks:
- ✅ Valid JSON syntax
- ✅ Has required fields: `project_id`, `api_key`, `client` 
- ✅ Matches current Firebase project
- ✅ Present in both root and Android folders
- ✅ No sensitive keys exposed in version control

**Common Issues**:
```
❌ "Invalid JSON in google-services.json"
   → Fix: Re-download from Firebase Console
   
❌ "Project ID mismatch"
   → Fix: Ensure config matches Firebase project
   
❌ "API key contains invalid characters"
   → Fix: Regenerate key from Firebase Console
```

### 2. Firestore Database Structure
**File**: `Firestore Database Structure.js`

Validates:
- ✅ Collections match code references
- ✅ Document fields align with data models in `lib/data/`
- ✅ Indexes for common queries
- ✅ No deprecated field names
- ✅ Storage paths defined correctly

**Collections to Verify**:
```javascript
users/           // Customer accounts
  - uid (doc id)
  - email, phone, address
  - createdAt, updatedAt
  
orders/          // Customer orders
  - orderId (doc id)
  - userId, items, total, status
  - createdAt, deliveryDate
  
products/        // Product catalog
  - productId (doc id)
  - name, category, price, image
  - stock, rating
  
deliveryBoys/    // Delivery personnel
  - uid (doc id)
  - name, phone, location
  - assignedOrders, status
  
categories/      // Product categories
  - catId (doc id)
  - name, image, subCategories
  
orders_status/   // Order tracking
  - orderId (doc id)
  - status, timestamp, location
```

### 3. Firestore Security Rules
**File**: `Firestore Security Rules.js`

Validates:
- ✅ Allows authenticated reads/writes for users
- ✅ Restricts admin operations to admin role
- ✅ Delivery boys can only access assigned orders
- ✅ Users can only access their own data
- ✅ No overly permissive rules (allow read/write if true)
- ✅ Rules match authentication setup

**Common Issues**:
```javascript
// ❌ BAD: Everyone can read/write everything
match /{document=**} {
  allow read, write: if true;
}

// ✅ GOOD: Authenticated users can read their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
  allow read, write: if hasAdminRole();
}

match /orders/{orderId} {
  allow read: if request.auth.uid == resource.data.userId
            || hasAdminRole()
            || isDeliveryBoyAssigned(orderId);
}
```

### 4. Firebase Authentication Setup
**Files**: `lib/core/`, `pubspec.yaml`

Checks:
- ✅ `firebase_auth` package in pubspec.yaml
- ✅ Email/password auth enabled
- ✅ Phone auth configured (if delivery boys use it)
- ✅ Error handling for auth failures
- ✅ Token refresh mechanism working
- ✅ Session persistence enabled

---

## Android Build Health

### 1. Gradle Configuration
**File**: `android/build.gradle`

Checks:
- ✅ Gradle version compatible with Flutter version
- ✅ Min SDK version >= 21
- ✅ Target SDK version >= 31 (Play Store requirement)
- ✅ All plugins have versions specified
- ✅ No duplicate repositories

**Example Configuration**:
```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
        compileSdkVersion 33
    }
    
    // ✅ GOOD: Explicit versions
    dependencies {
        implementation 'com.google.android.gms:play-services-auth:20.4.0'
        implementation 'com.firebase:firebase-common:20.3.0'
    }
}
```

### 2. Dependencies & Plugins
**Files**: `android/build.gradle`, `android/app/build.gradle`, `pubspec.yaml`

Checks:
- ✅ Firebase plugins pinned to compatible versions
- ✅ Google Play Services versions match
- ✅ No conflicting dependency versions
- ✅ Kotlin version compatible with Gradle
- ✅ All plugins in pubspec.yaml have corresponding Android deps

**Common Issues**:
```
❌ "Firebase version mismatch"
   → Fix: Align all Firebase libraries to same major version
   → Check: firebase_core, firebase_auth, cloud_firestore versions
   
❌ "Google Play Services conflict"
   → Fix: Use com.google.android.gms:play-services-base:18.0.0
   → Avoid: Multiple different GMS versions
   
❌ "Missing plugin declaration"
   → Fix: Add plugin to android/app/build.gradle
   → Example: id 'com.google.gms.google-services'
```

### 3. Android Manifest & Permissions
**File**: `android/app/src/AndroidManifest.xml`

Checks:
- ✅ Internet permission declared
- ✅ Location permissions for delivery tracking
- ✅ Camera/gallery permissions for image upload
- ✅ Firebase Cloud Messaging (FCM) permissions
- ✅ Correct minSdkVersion in manifest

**Required Permissions**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 4. Build Issues Diagnostic
**When build fails:**

1. **Check Gradle wrapper**: `./gradlew wrapper` → update if outdated
2. **Clean build**: `./gradlew clean && flutter clean`
3. **Get latest deps**: `./gradlew dependencies`
4. **Check AndroidX**: `android.useAndroidX=true` in gradle.properties
5. **Verify Java version**: Must be Java 11 or later

---

## Automated Check Workflow

When user requests Firebase/Android health check:

```
1. Scan google-services.json → validity
2. Validate Firestore structure → completeness
3. Review security rules → safety level
4. Check pubspec.yaml → Firebase versions
5. Analyze android/build.gradle → compatibility
6. Check AndroidManifest → permissions
7. Detect dependency conflicts
8. Report findings with severity level
9. Suggest fixes with code examples
10. Ask for permission to apply fixes
```

---

## Git Integration for Infrastructure Changes

**Infrastructure changes require approval before commit:**

```
Agent: "Found Firebase security rule issue in [location]"
       "This is a CRITICAL change—suggest fix?"

User: "Review fix" → Shows exact changes
    → "Apply fix" → Commits with message:
      "security(firebase): fix overly permissive rules in [collection]"
    → "Push?" → Asks before git push
```

---

## Role-Specific Recommendations

### Owner/Admin
- "Firestore security rules issue: [details]" (blocking)
- "Firebase API quota exceeded: [metric]"
- "Build failing in CI/CD: [error]"

### Developer/Admin
- "Dependency version mismatch detected"
- "Android minSdk < 21 on 2 devices"
- "Firebase emulator needs setup"

### Delivery Boy
- "Real-time updates via Firestore: latency [ms]"
- "Location tracking permissions: [status]"

### User/Customer
- "App crashes on sign-up: [error]"
- "Orders not syncing with Firestore"
