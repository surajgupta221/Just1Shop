rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Everyone can read categories and products
    match /categories/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
    
    match /products/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
    
    // Orders - users can read their own, owners and delivery can read all
    match /orders/{orderId} {
      allow read: if request.auth != null && (
        resource.data.userId == request.auth.uid ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['owner', 'delivery']
      );
      allow create: if request.auth != null && request.data.userId == request.auth.uid;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['owner', 'delivery'];
    }
    
    // Banners - read all, write only owners
    match /banners/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
    
    // Coupons - read all, write only owners
    match /coupons/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'owner';
    }
  }
}
