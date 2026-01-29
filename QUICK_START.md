# Quick Start Guide - Flutter Healthcare App

## ✅ Clean Setup Complete!

All React Native/Expo files have been removed. Your project is now a pure Flutter app!

## 📱 Running on Android Emulator

### Option 1: Using Android Studio

1. **Open Android Studio**
2. **Start your emulator** from AVD Manager
3. **In your terminal, run:**
   ```bash
   flutter run
   ```

### Option 2: Using Command Line

1. **List available emulators:**
   ```bash
   flutter emulators
   ```

2. **Launch an emulator** (e.g., Pixel_4):
   ```bash
   flutter emulators --launch Pixel_4
   ```

3. **Wait 30-60 seconds** for emulator to fully boot

4. **Verify device is connected:**
   ```bash
   flutter devices
   ```
   You should see your Android emulator listed

5. **Run the app:**
   ```bash
   flutter run
   ```

## 🚀 Quick Commands

```bash
# Run on any available device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode (optimized)
flutter run --release

# Run on Chrome (web)
flutter run -d chrome

# Run on Windows
flutter run -d windows
```

## 🔄 Development Workflow

1. **Start the app** with `flutter run`
2. **Edit code** in your IDE (VS Code, Android Studio, etc.)
3. **Press 'r'** in terminal for hot reload (instant updates)
4. **Press 'R'** for hot restart (full app restart)
5. **Press 'q'** to quit

## 📂 Project Structure

```
healthcare-app/
├── lib/                      # All Flutter code
│   ├── main.dart            # App entry point
│   ├── router.dart          # Navigation
│   ├── models/              # Data models
│   ├── providers/           # State management (Riverpod)
│   ├── screens/             # All screens
│   ├── services/            # Business logic
│   ├── theme/               # Colors, spacing, theme
│   └── widgets/             # Reusable widgets
├── pubspec.yaml             # Dependencies
├── README.md                # Main documentation
└── CONVERSION_GUIDE.md      # React Native → Flutter guide
```

## 🎯 First Time Setup Checklist

- ✅ All React Native files deleted
- ✅ Flutter dependencies installed (`flutter pub get`)
- ✅ Project ready to run
- ⏳ Waiting for Android emulator to start

## 🔧 Troubleshooting

### Emulator not detected?
```bash
# Check if emulator is running
flutter devices

# If not listed, restart emulator from Android Studio
# or use: flutter emulators --launch <emulator_id>
```

### Build errors?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Hot reload not working?
```bash
# Do a hot restart instead
# Press 'R' in the terminal where flutter run is active
```

### Dependencies issues?
```bash
# Update dependencies
flutter pub upgrade

# Or reinstall
flutter pub get
```

## 🎨 Features Ready to Use

- ✅ **Authentication** - Login/Signup with local storage
- ✅ **Dashboard** - Stats, quick actions, health tips
- ✅ **Family Management** - Add/remove family members
- ✅ **Report Scanner** - UI ready (camera integration pending)
- ✅ **Profile** - User info, theme toggle, logout
- ✅ **Dark Mode** - Full light/dark theme support
- ✅ **Bottom Navigation** - 4 tabs with smooth transitions

## 📝 Default Test Credentials

The app uses local storage. You can:
1. Sign up with any email/password
2. Or use credentials you create

All data is stored locally on the device using SharedPreferences.

## 🔐 User ID Format

- User IDs: `U-<timestamp>-<random>`
- Family Member IDs: `F-<timestamp>-<random>`

## 📱 Tested Platforms

- ✅ Android (via emulator)
- ✅ Windows (desktop)
- ✅ Web (Chrome/Edge)
- 🔄 iOS (requires Mac)

## 🎯 Next Steps

1. **Run the app** on your Android emulator
2. **Test all features** (signup, login, family, profile)
3. **Try dark mode** from the profile screen
4. **Explore the code** in the `lib/` directory

## 💡 Tips

- Use **hot reload** ('r' key) for instant UI updates
- Use **hot restart** ('R' key) if state gets messy
- Check **DevTools** for debugging: `flutter run` will show the URL
- Use **Android Studio** or **VS Code** with Flutter extensions

## 📚 Documentation

- [README.md](README.md) - Full app documentation
- [CONVERSION_GUIDE.md](CONVERSION_GUIDE.md) - React Native comparison

## 🆘 Need Help?

1. Check `flutter doctor` for setup issues
2. View logs in the terminal where you ran `flutter run`
3. Use Flutter DevTools for debugging
4. Check the README.md for more details

---

**Ready to start?** Run `flutter run` once your emulator is up! 🚀
