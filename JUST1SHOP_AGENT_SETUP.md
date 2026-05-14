# Just1Shop DevOps & QA Agent - Setup & Usage Guide

## ✅ Installation Complete!

Your custom Just1Shop Agent is ready to use. This agent performs comprehensive automated checks and bug fixing for your Flutter app across all user roles.

---

## 🚀 Quick Start

### Using the Agent

**In VS Code Chat**, type:
```
/just1shop-devops
```

**Or simply ask:**
```
Check for bugs in the app
Run Android build diagnostics  
Is Firebase configured correctly?
Why is the admin panel failing?
```

The agent will:
1. ✅ Ask for your role context (owner/admin/delivery/user)
2. ✅ Run appropriate automated checks
3. ✅ Detect bugs and issues
4. ✅ Suggest fixes with code examples
5. ✅ Ask permission before applying changes
6. ✅ Commit fixes with proper git messages (if approved)

---

## 📋 What the Agent Can Do

### 🔍 Automated Checks (Every Run)
- **Bug Detection** → Scans all code for common bugs
- **Firebase Integration** → Validates Firestore, auth, storage
- **Android Build Health** → Checks gradle, dependencies, manifests
- **Code Quality** → Finds unused imports, formatting issues
- **Dependencies** → Verifies versions and compatibility
- **Test Execution** → Runs tests and reports failures

### 🔧 Interactive Fixes (Asks Before Acting)
- Auto-fix bugs with your approval
- Format code and clean up
- Update dependencies safely
- Create git commits for changes
- Optionally push to remote repository

### 👥 Role-Based Intelligence
- **Owner**: System health, business metrics, all roles
- **Admin**: User management, products, orders, database
- **Delivery Boy**: Tracking, orders, notifications, routes
- **Customer**: Shopping, payments, orders, account

---

## 💬 Example Commands

### General Health Check
```
Check the entire app for bugs
```
→ Agent scans Dart/Flutter, Python backend, Android config

### Role-Specific
```
I'm an admin. Are orders processing correctly?
```
→ Agent focuses on order pipeline, user management, database

### Feature-Specific
```
Fix Firebase authentication issues
```
→ Agent validates Firebase setup, suggests auth fixes

### Build-Specific
```
Why is the Android build failing?
```
→ Agent checks gradle, dependencies, google-services.json

### Interactive Fixes
```
Find all bugs and fix them
```
→ Agent detects issues, shows fixes, asks approval for each

---

## 📁 Agent Files Created

The following files were created in your workspace:

```
.github/
├── agents/
│   └── just1shop-devops.agent.md              # Main agent definition
└── instructions/
    ├── just1shop-general.instructions.md      # Project context & conventions
    ├── just1shop-bug-fixing.instructions.md   # Bug detection & fixing
    ├── just1shop-role-based-workflows.instructions.md  # Role routing
    └── just1shop-firebase-android-checks.instructions.md  # Firebase & Android
```

**These files are now part of your workspace** and will be automatically used whenever you interact with the agent.

---

## 🎯 Use Cases by Role

### 👑 For OWNER
```
"What's broken in the system?"
→ Agent checks all code, database, backend health

"Is the database secure?"
→ Agent reviews Firestore security rules

"Build status for release?"
→ Agent checks Android build, dependencies, tests

"User analytics—any issues?"
→ Agent checks user-facing code, payment flows
```

### 🔧 For ADMIN
```
"Can I add new products?"
→ Agent checks admin panel, product upload, database schema

"Is order processing working?"
→ Agent checks order routes, Firestore, status tracking

"Fix database consistency issues"
→ Agent validates schema, identifies mismatches

"Export user data"
→ Agent checks data models, export functionality
```

### 🚗 For DELIVERY BOY
```
"Why is my location not updating?"
→ Agent checks real-time tracking, permissions, Firebase

"Are new orders appearing?"
→ Agent checks order assignment, notifications, sync

"Can't contact customer"
→ Agent checks messaging feature, contact sync

"Route optimization"
→ Agent checks location accuracy, map integration
```

### 👤 For CUSTOMER
```
"Why can't I sign up?"
→ Agent checks auth, input validation, error messages

"Payment is failing"
→ Agent checks Razorpay integration, error handling

"Where's my order?"
→ Agent checks order tracking, status updates, Firestore

"App keeps crashing on login"
→ Agent checks crashes, null pointers, async issues
```

---

## ⚙️ Configuration

The agent is configured to:

✅ **Automatically detect:**
- Your role in the system
- Relevant code areas for your task
- Common bug patterns
- Missing configuration

✅ **Always ask before:**
- Making code changes
- Creating commits
- Pushing to git
- Updating dependencies

✅ **Scan these areas:**
- `lib/**/*.dart` — Flutter/Dart code
- `just1shop-backend/*.py` — Backend API
- `just1shop-admin/*.py` — Admin panel
- `android/**/*.gradle` — Android config
- `pubspec.yaml` — Dependencies
- `google-services.json` — Firebase config
- `*.md` — Documentation

---

## 🔒 Safety Features

- **Interactive Mode**: Agent asks before applying any changes
- **Git Integration**: Creates commits for audit trail
- **Approval Gates**: Large changes require confirmation
- **Rollback Ready**: Commits can be reverted if needed
- **Sensitive Files**: Won't commit keys, credentials

---

## 📊 Sample Agent Responses

### Bug Detection Report
```
🔴 BUGS FOUND (3 issues)

1. Null pointer in lib/presentation/screens/login.dart:45
   Issue: User object accessed before null check
   Fix: Add null check before accessing user.email
   Severity: 🔴 HIGH
   
2. Missing error handling in just1shop-backend/main.py:102
   Issue: Firebase exception not caught in /api/products
   Fix: Wrap in try-except block
   Severity: 🟡 MEDIUM
   
3. Deprecated Firebase API in lib/core/firestore/user_service.dart:30
   Issue: Using deprecated getDocuments() instead of get()
   Fix: Replace getDocuments() with get()
   Severity: 🟡 MEDIUM

Apply fixes? (yes/no/review)
```

### Role-Based Context
```
👥 Detected Role: ADMIN

Prioritizing checks for:
✅ User management features
✅ Product/category operations
✅ Order processing
✅ Admin panel functionality
✅ Database operations

Scanning relevant code areas...
```

### Firebase Health Report
```
✅ Firebase Configuration
├── ✅ google-services.json valid
├── ✅ Project ID matches: "just1shop-prod"
├── ⚠️  Security rules: 2 issues found
│   └── Match clause allows overly broad access
├── ✅ Collections structure correct
└── ⚠️  3 unused indexes found

Detailed recommendations provided below...
```

---

## 🛠️ Advanced Usage

### Continuous Monitoring
Run weekly checks:
```
Check app health and report issues
```

### Before Each Release
```
Owner role. Run full system checks before release build
```

### Debugging Specific Feature
```
I'm in admin. Orders won't process. Debug this feature
```

### Code Review Assistance
```
Review lib/presentation/screens/checkout.dart for bugs and improvements
```

### Dependency Management
```
Check for deprecated packages and suggest updates
```

---

## 📞 Troubleshooting

### Agent not responding?
- Make sure you're in the correct workspace (`e:\Just1Shop`)
- Agent files created in `.github/agents/` and `.github/instructions/`
- Reload VS Code if changes don't appear

### Want to edit instructions?
Edit files in `.github/instructions/`:
- `just1shop-general.instructions.md` — Project conventions
- `just1shop-bug-fixing.instructions.md` — Bug detection
- `just1shop-role-based-workflows.instructions.md` — Role routing
- `just1shop-firebase-android-checks.instructions.md` — Firebase/Android

### Want to disable the agent?
Simply don't use `/just1shop-devops` command, or remove `.github/agents/just1shop-devops.agent.md`

---

## 📝 Tips & Best Practices

1. **State Your Role** — Agent works better when you say "I'm an admin" first
2. **Be Specific** — "Fix payment bugs" is better than "check app"
3. **Review Fixes** — Always review suggested changes before approval
4. **Use Git** — Agent creates commits with clear messages for audit trail
5. **Run Regularly** — Weekly health checks catch issues early
6. **Document Changes** — Agent updates `.md` files with findings

---

## 🎓 Next Steps

1. **Try the agent**: Type `/just1shop-devops` in chat
2. **Specify your role**: Tell agent your role (owner/admin/delivery/user)
3. **Request a check**: Ask for "bug detection" or "health check"
4. **Review suggestions**: Look at detected issues and fixes
5. **Apply fixes**: Approve changes one by one
6. **Monitor progress**: Check git commits for applied fixes

---

## 📚 Related Documentation

- [Firestore Database Structure.js](./Firestore%20Database%20Structure.js) — Schema docs
- [Firestore Security Rules.js](./Firestore%20Security%20Rules.js) — Access rules
- [PROJECT_SETUP_GUIDE.md](./PROJECT_SETUP_GUIDE.md) — Initial setup
- [SYSTEM_ARCHITECTURE.md](./SYSTEM_ARCHITECTURE.md) — Architecture overview
- [pubspec.yaml](./pubspec.yaml) — Dart dependencies

---

## ✨ Features Included

✅ Bug detection & fix suggestions  
✅ Test execution & failure analysis  
✅ Code formatting & cleanup  
✅ Firebase integration checks  
✅ Android build diagnostics  
✅ Role-based task routing  
✅ Documentation updates  
✅ Git integration (commits with approval)  
✅ Interactive mode (asks before changes)  
✅ Multi-role support (owner/admin/delivery/user)  

---

**Happy coding! 🚀** Your Just1Shop app is now monitored by an intelligent DevOps agent.

For questions about the agent, check the `.github/` directory or contact your development team.
