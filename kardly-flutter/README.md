# Kardly - K-Pop Photocard Collection App

A Flutter application for K-Pop fans to collect and track photocards.

## Features

### Free Tier
- **Collection Tracking**: Mark cards as "owned" or "wishlist"
- **Album-Style Views**: Digital photo albums organized by group/era
- **User Profiles**: View others' public collections
- **Limitations**: 100 photocards max, 2 albums/lists max

### Premium Tier (£3.99/month or £29.99/year)
- **Unlimited Collections**: No limits on photocards and albums/lists
- **Valuation Tools**: Display estimated resale prices
- **Customization**: Themes, backgrounds, stickers for album layouts
- **Upload Cards**: Add new photocards (pending admin approval)
- **Social Features**: Follow, like, comment on profiles

## Design System

### Color Palette
- **Primary Purple**: `#B19CD9` - Main brand color
- **Light Purple**: `#E6D7FF` - Backgrounds and accents
- **Dark Purple**: `#8B5FBF` - Darker elements
- **Accent Pink**: `#FFB3E6` - Secondary actions
- **Soft Lavender**: `#F0E6FF` - Light backgrounds
- **Mint Accent**: `#B3FFE6` - Success states

### Typography
- **Font Family**: Pretendard (Korean-optimized)
- **Weights**: Regular (400), Medium (500), SemiBold (600), Bold (700)

## Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── providers/
│       └── app_providers.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── home/
│   │   └── presentation/
│   │       └── pages/
│   ├── collection/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── profile/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── photocard/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── premium/
│   │   └── presentation/
│   │       └── pages/
│   └── onboarding/
│       └── presentation/
│           └── pages/
├── shared/
│   └── presentation/
│       └── widgets/
└── main.dart
```

## Key Components

### Navigation
- **Bottom Navigation**: 3 main tabs (Home, Collection, Profile)
- **Go Router**: Declarative routing with deep linking support

### Reusable Widgets
- **CustomCard**: Consistent card design with shadows
- **PhotocardWidget**: Photocard display with actions
- **PrimaryButton/SecondaryButton**: Themed buttons
- **FilterChip**: Filter selection chips
- **PremiumBadge**: Premium feature indicators

### State Management
- **Provider**: State management for all features
- **Providers**: Auth, Collection, Profile

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd kardly-flutter
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Development Notes

### Design Principles
- **Mobile-First**: Optimized for mobile devices
- **Pastel Aesthetic**: Soft, trendy colors appealing to young K-Pop fans
- **User-Friendly**: Intuitive navigation and clear visual hierarchy
- **Premium Integration**: Clear distinction between free and premium features

### Target Audience
- **Age**: 14-30 years old
- **Interest**: K-Pop fans, photocard collectors
- **Behavior**: Social, community-oriented, mobile-native

### Monetization
- **Freemium Model**: Free tier with limitations
- **Premium Subscription**: £3.99/month or £29.99/year
- **Value Proposition**: Unlimited features, trading, valuation tools

## Future Enhancements

### Phase 1 (Current)
- ✅ UI Framework and Design System
- ✅ Core Navigation Structure
- ✅ Main Feature Screens
- ✅ Premium Upgrade Flow

### Phase 2 (Next)
- [ ] Backend Integration
- [ ] Real Authentication
- [ ] Database Connection
- [ ] Image Upload/Storage
- [ ] Push Notifications

### Phase 3 (Future)
- [ ] Social Features
- [ ] Market Analytics
- [ ] Community Features

## Contributing

1. Follow the established code structure
2. Use the design system components
3. Maintain responsive design principles
4. Test on multiple device sizes
5. Follow Flutter best practices

## License

This project is proprietary software for Kardly.
