# Liquid Galaxy Controller

A Flutter application for controlling Liquid Galaxy rigs via SSH. Created for the Liquid Galaxy organization task.

## Features

- 🌍 **Send LG Logo to Left Screen** - Display the Liquid Galaxy logo persistently
- 🔺 **Send 3D Colored Pyramid KML** - Custom-created 3D pyramid with 5 colored faces
- ✈️ **Fly to Indore (Home City)** - Smooth animation to Indore, India
- 🛫 **Fly to Delhi** - Smooth animation to Delhi, India  
- 🧹 **Clean Logos** - Remove all logos from screens
- 🗑️ **Clean KMLs** - Clear all KML files

## Home City

**Indore, Madhya Pradesh, India**
- Coordinates: 22.7196° N, 75.8577° E

**Delhi (Additional City)**
- Coordinates: 28.6139° N, 77.2090° E

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Physical Android device or emulator
- Access to a Liquid Galaxy rig (for full testing)

### Installation

1. Clone or extract the project
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building Release APK

To build a release APK for testing on Liquid Galaxy:

```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Installing on Device

```bash
flutter install
```

Or manually install the APK:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Usage

1. **Open the app** - You'll see an animated home screen with Earth orbit
2. **Click "OPEN LG MENU"** - Navigate to the control interface
3. **Configure SSH** - Click menu (⋮) → "SSH Settings"
   - Enter your LG IP address
   - Set port (default: 22)
   - Enter username (default: lg)
   - Enter password
   - Set number of screens (default: 3)
4. **Connect** - Click menu (⋮) → "Connect to LG"
5. **Use features**:
   - Send LG Logo to Left Screen
   - Send 3D Pyramid KML
   - Fly to Indore (Home City)
   - Fly to Delhi
   - Clean Logos
   - Clean KMLs

## Project Structure

```
lib/
├── main.dart                    # Main UI and app entry
├── services/
│   └── lg_service.dart         # SSH and LG communication
└── utils/
    └── kml_helper.dart         # KML generation utilities

assets/
├── kml/
│   └── pyramid.kml             # 3D colored pyramid (original creation)
└── images/                      # Future assets
```

## KML Attribution

### Pyramid KML
- **File**: `assets/kml/pyramid.kml`
- **Created by**: Goutam
- **Source**: Original work created specifically for this task
- **Description**: 3D pyramid with 5 colored faces (Red, Green, Blue, Yellow, Magenta) centered at Indore, India

### LG Logo
- **Source**: Official Liquid Galaxy GitHub repository
- **URL**: https://raw.githubusercontent.com/LiquidGalaxyLAB/liquid-galaxy/master/gnu_linux/home/lg/tools/earth/Image_lg.jpg

## Dependencies

- **dartssh2** (^2.9.0) - SSH client for Dart/Flutter

## Technical Details

- **SSH Connection**: Uses dartssh2 package for secure SSH communication
- **KML Generation**: Dynamic KML generation for logos, pyramids, and fly-to commands
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Status Feedback**: Real-time status updates via snackbars and status display
- **Connection Management**: Persistent SSH connection with manual connect/disconnect

## Testing

The app has been tested with:
- Flutter 3.x
- Dart 3.x
- Android SDK 21+
- dartssh2 2.9.0

## Video Demonstration

When recording the demonstration video:
1. Show face and screen simultaneously (to avoid cheating)
2. Explain the code architecture
3. Walk through each feature
4. Demonstrate on actual LG rig if available
5. Keep under 5 minutes

## Submission Checklist

- ✅ App with all 5 features implemented
- ✅ 3D pyramid KML file (original creation)
- ✅ Source code attribution documented
- ✅ README with instructions
- ✅ DOCUMENTATION.md with technical details
- ⏳ Video demonstration (to be recorded)
- ⏳ Released APK (build command provided above)

## Contact

Created for: Liquid Galaxy Organization
Developer: Goutam
Location: Indore, India
Date: January 2026

## License

Created as part of Liquid Galaxy task submission.
