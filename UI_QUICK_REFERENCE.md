# JUST1SHOP UI - Quick Reference Guide

## 🎯 Color Palette Quick Copy

```dart
// Primary Colors
Color primaryColor = Color(0xFF10B981);      // Fresh Green
Color primaryDark = Color(0xFF059669);       // Dark Green  
Color primaryLight = Color(0xFFD0F8E3);      // Light Green

// Accent Colors
Color accentRed = Color(0xFFFF6B6B);         // Discount/Alert
Color backgroundColor = Color(0xFFFAFAFA);   // Light Gray
Color surfaceColor = Color(0xFFFFFFFF);      // White

// Text Colors
Color textPrimary = Color(0xFF1F2937);       // Dark Gray
Color textSecondary = Color(0xFF6B7280);     // Medium Gray
Color textTertiary = Color(0xFF9CA3AF);      // Light Gray

// Status Colors
Color successColor = Color(0xFF10B981);      // Green
Color errorColor = Color(0xFFEF4444);        // Red
Color warningColor = Color(0xFFF59E0B);      // Orange
```

## 📏 Spacing Constants Quick Copy

```dart
// All available spacing values (use UIConstants.padding*)
paddingXXS = 4px
paddingXS = 8px
paddingS = 12px
paddingM = 16px
paddingL = 24px
paddingXL = 32px
paddingXXL = 40px
```

## 🎨 Text Style Quick Copy

```dart
// Use UITextStyles.* for any text in app
UITextStyles.displayLarge      // 32px bold
UITextStyles.displayMedium     // 28px bold
UITextStyles.displaySmall      // 24px bold
UITextStyles.headlineLarge     // 20px semi-bold
UITextStyles.headlineMedium    // 18px semi-bold
UITextStyles.headlineSmall     // 16px semi-bold
UITextStyles.bodyLarge         // 16px regular
UITextStyles.bodyMedium        // 14px regular
UITextStyles.bodySmall         // 12px regular
UITextStyles.labelLarge        // 14px semi-bold
UITextStyles.labelMedium       // 12px semi-bold
UITextStyles.labelSmall        // 11px semi-bold
```

## 🔘 Border Radius Quick Copy

```dart
radiusS = 6px
radiusM = 8px
radiusL = 12px
radiusXL = 16px
radiusXXL = 20px
radiusRound = 100px
```

## 📦 Common Component Patterns

### Button (Primary - Green)
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: UIConstants.primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
    ),
  ),
  child: Text('Button Text', style: UITextStyles.headlineSmall),
)
```

### Button (Secondary - Outlined)
```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: UIConstants.dividerColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
    ),
  ),
  child: Text('Button Text'),
)
```

### Card
```dart
Container(
  padding: EdgeInsets.all(UIConstants.paddingM),
  decoration: BoxDecoration(
    color: UIConstants.surfaceColor,
    borderRadius: BorderRadius.circular(UIConstants.radiusL),
    boxShadow: UIConstants.shadowsM,
  ),
  child: // Your content here
)
```

### Input Field
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: UIConstants.paddingM,
      vertical: UIConstants.paddingS,
    ),
  ),
)
```

### List Item
```dart
Container(
  padding: EdgeInsets.all(UIConstants.paddingM),
  decoration: BoxDecoration(
    color: UIConstants.surfaceColor,
    borderRadius: BorderRadius.circular(UIConstants.radiusL),
    boxShadow: UIConstants.shadowsM,
  ),
  margin: EdgeInsets.only(bottom: UIConstants.paddingM),
  child: Row(
    children: [
      Icon(Icons.icon_name, color: UIConstants.primaryColor),
      SizedBox(width: UIConstants.paddingM),
      Expanded(child: Text('Item Title', style: UITextStyles.labelLarge)),
      Icon(Icons.arrow_forward_ios_rounded, size: 16),
    ],
  ),
)
```

### Badge/Tag
```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: UIConstants.paddingS,
    vertical: 2,
  ),
  decoration: BoxDecoration(
    color: UIConstants.primaryLight,
    borderRadius: BorderRadius.circular(UIConstants.radiusS),
  ),
  child: Text('Badge', style: UITextStyles.labelSmall),
)
```

## 🖼️ Icon Usage
```dart
// Primary color icons
Icon(Icons.icon_name, color: UIConstants.primaryColor)

// Large icons (headers)
Icon(Icons.icon_name, size: 40, color: UIConstants.primaryColor)

// Small icons (labels)
Icon(Icons.icon_name, size: 16, color: UIConstants.textSecondary)
```

## 🎬 Common Animations

### Fade In
```dart
FadeTransition(
  opacity: Tween<double>(begin: 0, end: 1).animate(controller),
  child: YourWidget(),
)
```

### Slide In
```dart
SlideTransition(
  position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
    .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
  child: YourWidget(),
)
```

### Scale
```dart
ScaleTransition(
  scale: Tween<double>(begin: 0, end: 1).animate(controller),
  child: YourWidget(),
)
```

## 🎨 Gradient Background (Optional)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [UIConstants.primaryColor, UIConstants.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
)
```

## 📊 Shadow Effects

### Small Shadow (elevation 2)
```dart
boxShadow: UIConstants.shadowsS
```

### Medium Shadow (elevation 4) - Most Common
```dart
boxShadow: UIConstants.shadowsM
```

### Large Shadow (elevation 8)
```dart
boxShadow: UIConstants.shadowsL
```

## 🎯 Common Layouts

### Header + Content + Footer
```dart
Column(
  children: [
    // Header
    Container(/* ... */),
    // Content
    Expanded(
      child: ListView(
        padding: EdgeInsets.all(UIConstants.paddingM),
        children: [/* items */],
      ),
    ),
    // Footer/Action
    Container(/* ... */),
  ],
)
```

### Custom Scroll with Sliver Header
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 180,
      flexibleSpace: FlexibleSpaceBar(/* ... */),
    ),
    SliverToBoxAdapter(child: /* content */),
  ],
)
```

### Section with Title + Cards
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Section Title', style: UITextStyles.headlineSmall),
    SizedBox(height: UIConstants.paddingM),
    // Your cards here
  ],
)
```

## 🔄 BLoC Integration Examples

### Listen to State Changes
```dart
BlocListener<CartBloc, CartState>(
  listener: (context, state) {
    if (state is CartLoaded) {
      // Do something
    }
  },
  child: // UI
)
```

### Build Based on State
```dart
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    if (state is ProductLoading) return LoadingWidget();
    if (state is ProductsLoaded) return ProductList(state.products);
    if (state is ProductError) return ErrorWidget(state.message);
    return SizedBox.shrink();
  },
)
```

### Consumer (Listen + Build)
```dart
BlocConsumer<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  },
  builder: (context, state) {
    // Build UI based on state
  },
)
```

## 🚀 New Screen Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/ui_constants.dart';

class MyScreenName extends StatefulWidget {
  const MyScreenName({Key? key}) : super(key: key);

  @override
  State<MyScreenName> createState() => _MyScreenNameState();
}

class _MyScreenNameState extends State<MyScreenName> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Screen Title', style: UITextStyles.headlineLarge),
        backgroundColor: UIConstants.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UIConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your content here
          ],
        ),
      ),
    );
  }
}
```

## 📱 Import Statements (Always Copy These)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/your_bloc/your_bloc.dart';
```

## ✅ Design Checklist for Every Screen

- [ ] Uses UIConstants for all colors
- [ ] Uses UITextStyles for all text
- [ ] Uses UIConstants.padding* for spacing
- [ ] Uses UIConstants.radius* for borders
- [ ] Has proper AppBar styling
- [ ] Has safe top/bottom padding
- [ ] Background color set
- [ ] Cards have shadows (UIConstants.shadows*)
- [ ] Buttons are properly styled
- [ ] Text hierarchy is clear
- [ ] Icons use primary color
- [ ] Loading state handled
- [ ] Error state handled
- [ ] Empty state has message + CTA

## 🎨 Quick Color Reference

| Use | Color | Code |
|-----|-------|------|
| Buttons | Green | #10B981 |
| Links | Green | #10B981 |
| Icons | Green | #10B981 |
| Active State | Green | #10B981 |
| Discount Badge | Red | #FF6B6B |
| Error Message | Red | #EF4444 |
| Text Primary | Dark Gray | #1F2937 |
| Text Secondary | Medium Gray | #6B7280 |
| Dividers | Light Gray | #E5E7EB |
| Background | Light Gray | #FAFAFA |
| Cards | White | #FFFFFF |

## 💡 Pro Tips

1. **Always import UIConstants** - Ensures consistency
2. **Use UITextStyles** - Maintains typography hierarchy
3. **Reuse spacing values** - Don't hardcode numbers
4. **Test on multiple devices** - Check responsive design
5. **Use SizedBox for spacing** - Better than Padding
6. **Group related widgets** - Easier to maintain
7. **Add loading states** - Better UX
8. **Show error messages** - User-friendly
9. **Use const constructors** - Better performance
10. **Follow naming conventions** - Easy to understand

---

**Happy Coding! 🚀**

Use this guide as your quick reference for all UI development in Just1Shop.
