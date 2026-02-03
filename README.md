# Healthcare App - Flutter Version

This is a Flutter conversion of the React Native/Expo Healthcare application.

## Features

✅ **Authentication**
- Login with email/phone and password (database accounts)
- Legacy signup with name, email, and password (SharedPreferences)
- Join existing family member profile (one-time claim per profile)
- Password strength indicator
- Session management with member tracking
- BCrypt password hashing
- Fallback to legacy authentication for backward compatibility

✅ **Join Existing Family**
- Lookup family members by phone or email
- Claim profile with password creation
- One account per family member enforced
- Profile-only members (no phone/email) cannot create accounts
- Clear error messages for each scenario

✅ **Family Management**
- Add family members with name, relation, phone, and email
- View all family members in tree view
- Delete family members with validation rules
- Cannot delete logged-in user
- Cannot delete members with children
- Warn before deletion if member has active account
- Enforce one "Self" profile per account
- Generate unique member IDs
- Color-coded avatars
- Quick actions for each member (View Profile, View Reports)

✅ **Local Database (sqflite)**
- Persistent family member storage
- Account/authentication data storage
- Foreign key constraints with cascading deletes
- Transaction support for atomic operations
- Device-level data isolation

✅ **Dashboard (Home)**
- Welcome header with user name
- Quick stats (Reports, Family, Upcoming appointments)
- Quick action cards (Scan Report, Family Tree, Medications, Health Trends)
- Health tips carousel
- Upcoming appointments list
- Health metrics card

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
- Auth provider for authentication state with memberId tracking
- Account provider for join family operations
- Theme provider for theme mode
- Family provider for family members with permission checks

✅ **Navigation**
- GoRouter with auth guards
- Bottom tab navigation
- Deep linking support
- Proper back navigation
- Permission onboarding (one-time per device)

## Tech Stack

- **Framework**: Flutter SDK 3.5+
- **State Management**: Riverpod 2.6+
- **Navigation**: GoRouter 14.6+
- **Database**: sqflite 2.3+
- **Local Storage**: SharedPreferences 2.3+
- **Password Hashing**: BCrypt
- **Date Formatting**: Intl 0.19+

## Project Structure

```
lib/
├── main.dart                          # App entry point & initialization
├── router.dart                        # GoRouter configuration with auth guards
├── models/                            # Data models
│   ├── user.dart                      # Session & User models
│   ├── family_member.dart             # FamilyMember with memberId, hasAccount
│   ├── account.dart                   # Account with passwordHash
│   ├── health_profile.dart
│   └── report_item.dart
├── providers/                         # Riverpod providers
│   ├── auth_provider.dart             # Login, signup, session management
│   ├── account_provider.dart          # Join family, password verification
│   ├── family_provider.dart           # Family tree state, add/remove with checks
│   ├── health_provider.dart
│   ├── report_provider.dart
│   └── theme_provider.dart            # Theme mode (light/dark)
├── screens/                           # Screen widgets
│   ├── splash_screen.dart             # Splash/loading
│   ├── auth/
│   │   ├── login_screen.dart          # Email/phone + password login
│   │   ├── signup_screen.dart         # Legacy signup
│   │   ├── join_family_screen.dart    # Join existing family (3-state UI)
│   │   └── reset_password_screen.dart
│   ├── permissions/
│   │   └── permissions_screen.dart    # Camera, contacts, files permissions
│   └── tabs/
│       ├── tabs_screen.dart           # Bottom tab navigation
│       ├── home_screen.dart           # Dashboard
│       ├── family_screen.dart         # Family tree with add/delete
│       ├── family_member_screen.dart  # Member profile detail
│       ├── scan_screen.dart           # Report scanner UI
│       ├── profile_screen.dart        # User profile & settings
│       └── donation_screen.dart
├── services/                          # Business logic
│   ├── local_database.dart            # sqflite: accounts & family_members tables
│   ├── family_storage.dart            # FamilyStorage interface → LocalDatabase
│   ├── auth_storage.dart              # Legacy user storage in SharedPreferences
│   ├── local_auth_service.dart        # Local auth service
│   ├── health_storage.dart
│   ├── report_storage.dart
│   ├── report_storage_io.dart
│   ├── report_storage_web.dart
│   └── report_storage_stub.dart
├── theme/                             # Theme configuration
│   ├── app_theme.dart                 # Light/dark theme definitions
│   ├── app_colors.dart                # Color palette
│   └── app_spacing.dart               # Spacing/padding constants
└── widgets/                           # Reusable widgets
    ├── appointments_list.dart
    └── health_tips.dart
```

### Database Schema

**family_members table:**
```sql
CREATE TABLE family_members (
  memberId TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  relation TEXT NOT NULL,
  parentId TEXT,                      -- FK: family_members(memberId) ON DELETE SET NULL
  phone TEXT,
  email TEXT,
  hasAccount INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY(parentId) REFERENCES family_members(memberId) ON DELETE SET NULL
)
```

**accounts table:**
```sql
CREATE TABLE accounts (
  accountId TEXT PRIMARY KEY,
  memberId TEXT UNIQUE NOT NULL,     -- FK: family_members(memberId) ON DELETE CASCADE
  emailOrPhone TEXT NOT NULL,
  passwordHash TEXT NOT NULL,
  FOREIGN KEY(memberId) REFERENCES family_members(memberId) ON DELETE CASCADE
)
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

## Key Features & Implementation Details

### Database Integration
- **sqflite** for persistent local storage
- Two tables: `family_members` and `accounts`
- Foreign key constraints with cascading deletes
- Transaction support for atomic operations
- Device-level data isolation (no cloud sync)

### Password Security
- BCrypt hashing with gensalt()
- Minimum 6 characters enforced
- Never stored plain text
- Proper verification with BCrypt.checkpw()

### Session Management
- Tracks both legacy users and database accounts
- Includes `memberId` for permission checks
- Prevents self-deletion while logged in
- Supports both email and phone authentication

### Family Member Management
- Hierarchical relationships (parent-child)
- Unique IDs for each member
- hasAccount flag to track claimed profiles
- Profile-only members remain view-only
- Children validation before deletion

### State Management with Riverpod
- `authProvider`: Auth state with session
- `accountProvider`: Account operations (join family, login)
- `familyMembersProvider`: Family tree with permission checks
- `themeModeProvider`: Theme preference
- AsyncValue handling for loading/error states

## Key Differences from React Native Version

### Architecture
- **State Management**: Changed from React hooks to Riverpod providers
- **Navigation**: Changed from Expo Router to GoRouter
- **Database**: Added sqflite for accounts/family member persistence
- **Storage**: SharedPreferences for sessions + sqflite for domain data

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
- **Database Operations**: Async/await with proper error handling

## Authentication Overview

### Three Authentication Pathways:

1. **Legacy Signup/Login**
   - Creates User in SharedPreferences (`localdb.users.v1`)
   - Uses BCrypt password hashing
   - Session stored in `localdb.session.v1`
   - No family member linking

2. **Join Existing Family**
   - Phone/email lookup in LocalDatabase
   - Creates Account + links to existing FamilyMember
   - Password created at point-of-claim (not reset)
   - One account per family member enforced
   - Requires phone OR email on profile

3. **Login**
   - Attempts database account login first (phone/email + password)
   - Falls back to legacy user login
   - Supports both email and phone number as identifier
   - Session includes `memberId` for database-linked accounts
   - BCrypt password verification

### Edge Cases Handled:

| Scenario | Prevention |
|----------|-----------|
| Multiple accounts per member | UNIQUE FK constraint + validation |
| Delete logged-in user | memberId check before deletion |
| Multiple "Self" profiles | Validation in addMember() |
| Profile without phone/email claiming | Required phone OR email check |
| Duplicate claims | hasAccount flag enforcement |

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
3. Use `ref.watch(provider)` to access state
4. Call `ref.read(provider.notifier).method()` to update state

### Adding Database Operations

1. Add query/insert/update/delete methods to `LocalDatabase`
2. Create or update storage layer (e.g., `FamilyStorage`)
3. Update provider methods to use new storage layer
4. Handle errors with try/catch and user-friendly messages

### Adding New State

1. Create provider in `lib/providers/`
2. Extend `StateNotifier` for mutable state
3. Watch provider in screen widgets using `ref.watch()`
4. Call notifier methods using `ref.read(provider.notifier).method()`

### Updating Theme

1. Modify colors in `lib/theme/app_colors.dart`
2. Update spacing in `lib/theme/app_spacing.dart`
3. Adjust theme configuration in `lib/theme/app_theme.dart`
4. Use theme values in widgets: `theme.textTheme.bodyLarge`, `AppColors.primary`

### Password Security

- Always hash passwords with BCrypt before storage
- Never log or expose password hashes
- Verify with `BCrypt.checkpw(plaintext, hash)`
- Enforce minimum length (6+ characters recommended)

### Database Best Practices

- Use transactions for multi-step operations (e.g., createAccount updates hasAccount)
- Enable foreign key constraints: `PRAGMA foreign_keys = ON`
- Use UNIQUE constraints for single-instance fields (e.g., memberId in accounts)
- Cascade deletes to maintain data integrity

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
