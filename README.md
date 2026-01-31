# Healthcare App - Flutter Version

This is a Flutter conversion of the React Native/Expo Healthcare application.

## Features

✅ **Authentication**
- Login with email/user ID and password
- Sign up with name, email, and password
- Password strength indicator
- Local storage for user data
- Session management

✅ **Dashboard (Home)**
- Welcome header with user name
- Quick stats (Reports, Family, Upcoming appointments)
- Quick action cards (Scan Report, Family Tree, Medications, Health Trends)
- Health tips carousel
- Upcoming appointments list
- Health metrics card

✅ **Family Management**
- Add family members with name, relation, and age
- View all family members
- Remove family members
- Generate unique member IDs
- Color-coded avatars
- Quick actions for each member (View Profile, View Reports)

✅ **Report Scanner**
- Scanner placeholder UI
- Features grid showing supported report types
- How it works section with step-by-step guide
- Recent scans section

✅ **Profile**
- User account information
- Theme toggle (Light/Dark mode)
- Health profile placeholder
- App information
- Logout functionality

✅ **Theme System**
- Full Material Design 3 theming
- Light and dark themes
- Consistent design tokens (colors, spacing, border radius)
- Persistent theme preference

✅ **State Management**
- Riverpod for state management
- Auth provider for authentication state
- Theme provider for theme mode
- Family provider for family members

✅ **Navigation**
- GoRouter with auth guards
- Bottom tab navigation
- Deep linking support
- Proper back navigation

## Tech Stack

- **Framework**: Flutter SDK 3.5+
- **State Management**: Riverpod 2.6+
- **Navigation**: GoRouter 14.6+
- **Local Storage**: SharedPreferences 2.3+
- **Date Formatting**: Intl 0.19+

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── router.dart                # GoRouter configuration
├── models/                    # Data models
│   ├── user.dart
│   └── family_member.dart
├── providers/                 # Riverpod providers
│   ├── auth_provider.dart
│   ├── family_provider.dart
│   └── theme_provider.dart
├── screens/                   # Screen widgets
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── reset_password_screen.dart
│   └── tabs/
│       ├── tabs_screen.dart
│       ├── home_screen.dart
│       ├── family_screen.dart
│       ├── family_member_screen.dart
│       ├── scan_screen.dart
│       ├── profile_screen.dart
│       └── donation_screen.dart
├── services/                  # Business logic
│   ├── auth_storage.dart
│   └── family_storage.dart
├── theme/                     # Theme configuration
│   ├── app_theme.dart
│   ├── app_colors.dart
│   └── app_spacing.dart
└── widgets/                   # Reusable widgets
    ├── appointments_list.dart
    └── health_tips.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.5 or higher
- Dart SDK 3.5 or higher

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   # For debug mode
   flutter run

   # For specific device
   flutter run -d <device_id>

   # For web
   flutter run -d chrome
   ```

### Build

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web
```

## Key Differences from React Native Version

### Architecture
- **State Management**: Changed from React hooks to Riverpod providers
- **Navigation**: Changed from Expo Router to GoRouter
- **Storage**: Changed from AsyncStorage to SharedPreferences

### UI Components
- **Material Design 3**: Using Flutter's Material 3 components
- **Cards**: Using Card widget with consistent styling
- **Buttons**: ElevatedButton and OutlinedButton with theme configuration
- **Inputs**: TextField with InputDecoration theme

### Styling
- **Theme System**: Using ThemeData with light and dark themes
- **Design Tokens**: Centralized in theme files (colors, spacing, radius)
- **Typography**: Using TextTheme from Material Design

### Data Flow
- **Providers**: Using StateNotifier for mutable state
- **AsyncValue**: Handling loading, data, and error states
- **Auto-refresh**: Router automatically rebuilds on auth state changes

## Features Not Yet Implemented

The following features from the original app are placeholders:
- Camera/file upload functionality
- Actual report scanning and OCR
- Health metrics tracking
- Google/Email sign-in (buttons present but not functional)
- Medication tracking
- Health trends analytics

## Development Notes

### Adding New Screens

1. Create screen widget in `lib/screens/`
2. Add route in `lib/router.dart`
3. Update navigation logic

### Adding New State

1. Create provider in `lib/providers/`
2. Watch provider in screen widgets
3. Call notifier methods to update state

### Updating Theme

1. Modify colors in `lib/theme/app_colors.dart`
2. Update spacing in `lib/theme/app_spacing.dart`
3. Adjust theme configuration in `lib/theme/app_theme.dart`

## Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Contributing

When contributing to this Flutter version:
1. Follow Flutter/Dart style guide
2. Use Riverpod for state management
3. Maintain consistency with existing theme
4. Add tests for new features
5. Update this README as needed

## License

Same as the original React Native version.
