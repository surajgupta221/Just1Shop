---
name: just1shop-bug-fixing
applyTo: "lib/**/*.dart,just1shop-backend/**/*.py,just1shop-admin/**/*.py,android/**/*.gradle"
description: "Automated bug detection and fix suggestions for Just1Shop. Scans Dart/Flutter, Python backend, and Android code for common bugs. Use when: reviewing code, running QA checks, or asking for bug fixes."
---

# Just1Shop Bug Fixing Instructions

## Bug Categories Handled

### Flutter/Dart Bugs
- ❌ Null pointer exceptions (uninitialized variables)
- ❌ Async/await issues (missing await, improper futures)
- ❌ Build context misuse (context after dispose)
- ❌ Missing error handling (try-catch blocks)
- ❌ Firebase connection failures
- ❌ Memory leaks (listeners not unsubscribed)
- ❌ State management issues (notifyListeners, Provider misuse)

### Python Backend Bugs
- ❌ Missing error handling (Flask routes without try-catch)
- ❌ Database connection issues
- ❌ Firebase auth/Firestore config problems
- ❌ Missing input validation
- ❌ Unhandled exceptions in API endpoints
- ❌ Missing CORS/security headers
- ❌ Import errors or missing dependencies

### Android/Gradle Issues
- ❌ Incompatible dependency versions
- ❌ Missing permissions in AndroidManifest
- ❌ Build configuration errors
- ❌ Google services config issues
- ❌ Gradle version mismatches

## Detection Workflow

1. **Scan** — Read all applicable files in category
2. **Analyze** — Use grep for common error patterns
3. **Report** — Create structured list of found issues
4. **Suggest** — Provide exact code fixes with context
5. **Apply** — Ask user before making changes
6. **Test** — Re-run compilation checks after fixes

## Common Fixes

### For Dart/Flutter:
```dart
// ❌ BAD: No error handling
final user = await auth.signInWithEmail(email, password);

// ✅ GOOD: With error handling
try {
  final user = await auth.signInWithEmail(email, password);
} on FirebaseAuthException catch (e) {
  print('Auth error: ${e.message}');
  rethrow;
}
```

### For Python:
```python
# ❌ BAD: No error handling
@app.route('/api/users')
def get_users():
    return db.collection('users').get()

# ✅ GOOD: With error handling
@app.route('/api/users')
def get_users():
    try:
        docs = db.collection('users').get()
        return jsonify([doc.to_dict() for doc in docs])
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

## Interactive Fix Mode

When bug detected:
1. Show problematic code snippet
2. Explain the issue in plain English
3. Suggest fix with before/after
4. Ask: "Apply this fix? (yes/no/review)"
5. If yes: Apply fix + add comment
6. If review: Show full context + ask again
7. Commit fix with message: "Fix: [issue name]"

## Role-Specific Bug Contexts

**Owner/Admin**: System-wide, database, security bugs  
**Delivery Boy**: Real-time tracking, location, notification bugs  
**Customer**: UI/UX, payment, order status bugs
