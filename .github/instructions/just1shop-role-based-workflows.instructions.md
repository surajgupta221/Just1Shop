---
name: just1shop-role-based-workflows
applyTo: "**/*"
description: "Role-based task routing for Just1Shop. Automatically detects user role (owner/admin/delivery/user) and prioritizes relevant features, code areas, and bug categories. Use when: working on role-specific features or asking agent to scope work to your role."
---

# Just1Shop Role-Based Workflow Instructions

## Role Detection & Prioritization

When user indicates their role or context suggests it, agent prioritizes relevant code areas and checks.

### 👑 **OWNER Role**
**Focus**: Business metrics, system health, all user roles

**Key Areas**:
- `just1shop-backend/` — Backend API & database
- `just1shop-admin/` — Admin dashboard
- `Firestore Database Structure.js` — Data schema
- `Firestore Security Rules.js` — Access control
- Build & deployment status
- Error logs and crash reports

**Priority Checks**:
1. Backend API health (all endpoints)
2. Database integrity (collections, documents)
3. Firebase security & auth rules
4. Admin panel functionality
5. Performance metrics (response times)
6. User analytics bugs

**Typical Questions**:
- "What's broken in the system?"
- "Is the backend healthy?"
- "Any security issues?"
- "Admin panel status?"

---

### 🔧 **ADMIN Role**
**Focus**: User management, content, transactions, database

**Key Areas**:
- `just1shop-admin/` — Admin panel code
- `just1shop-backend/main.py` — API routes
- `lib/data/` — Data models
- Firebase users collection
- Category, products, offers management

**Priority Checks**:
1. User management features
2. Product/category CRUD operations
3. Order processing pipeline
4. Firebase user authentication
5. Admin dashboard UI (if Dart)
6. Database consistency

**Typical Questions**:
- "Is user management working?"
- "Can I add/remove products?"
- "Are orders processing correctly?"
- "Database looks okay?"

---

### 🚗 **DELIVERY BOY Role**
**Focus**: Real-time tracking, location, orders, notifications

**Key Areas**:
- `lib/presentation/` — UI screens
- `lib/core/` — Location & tracking logic
- Real-time order updates
- Push notifications (firebase_messaging)
- Google Maps integration
- Customer communication

**Priority Checks**:
1. Real-time location tracking
2. Order assignment & delivery flow
3. Push notifications working
4. Route optimization
5. Customer contact features
6. Payment settlement system

**Typical Questions**:
- "Is my location tracking accurate?"
- "Can I see new orders?"
- "Are notifications working?"
- "Can I contact customer?"

---

### 👤 **USER/CUSTOMER Role**
**Focus**: Shopping, ordering, payment, account

**Key Areas**:
- `lib/presentation/screens/` — Customer UI
- `Customer Home Screen.dart` — Main interface
- Payment integration (Razorpay)
- Order tracking
- User account features
- Product browsing

**Priority Checks**:
1. Product search & browse
2. Shopping cart & checkout
3. Payment processing (Razorpay)
4. Order history & tracking
5. Account management
6. Review & rating system
7. Notifications of order status

**Typical Questions**:
- "Can I place an order?"
- "Payment failing, why?"
- "Where's my order?"
- "App crashing on home screen?"

---

## Workflow for Multi-Role Scenarios

**If user role unclear:**
```
Agent: "What's your role in the system?"
Options:
- Owner (system overview)
- Admin (user/content management)
- Delivery Boy (tracking & orders)
- Customer/User (shopping)
- Multiple roles / Not sure

User selects → Agent scopes all checks accordingly
```

**If user working on specific feature:**
```
User: "Fix login bugs"
Agent: Detects 'login' → applies to Owner/Admin/User
      → checks: Firebase Auth, auth screens, password reset
      → ignores: Delivery route, admin only features
```

**If multiple roles affected:**
```
User: "Product upload broken"
Agent: Detects product upload → Involves Admin & Users
      → checks: Admin panel upload, product display in customer app
      → checks: Firebase storage, image upload, price sync
      → suggests fixes for both code areas
```

## Automated Recommendations by Role

### Owner
- "Backend down time: 2 calls failed in last 5min"
- "High error rate in [endpoint]"
- "Security rule issue: [specific rule]"
- "Recommend database backup due to [change]"

### Admin  
- "User upload failing: missing validation in [file]"
- "Product sync issue detected in [API]"
- "Database field mismatch: [collection] vs code"

### Delivery Boy
- "Real-time updates delayed >5 seconds"
- "Push notification delivery rate: [%]"
- "GPS accuracy issue: [location_permission missing]?"

### User/Customer
- "Payment declined: [likely reason]"
- "Order stuck at: [status]"
- "App crash on [screen]: [error]"

---

## Context Preservation

Agent remembers user's stated role throughout conversation:

```
User: "I'm an admin"
Agent: (remembers for future messages in same session)

User: "Check for bugs"
Agent: (auto-applies admin-scoped checks without asking again)

User: (later) "Also check customer features"
Agent: (adds customer scope, keeps admin scope active)
```
