# GDS Prague Agenda App

A Flutter Android app for viewing and managing the GDS Prague conference agenda.

## Features

### 📱 Four Main Views

1. **Overview Tab**
   - Shows currently happening sessions
   - Displays the next upcoming session
   - Lists all sessions for today
   - Pull to refresh to reload the agenda

2. **By Day Tab**
   - Browse sessions organized by conference days
   - Expandable day sections showing all sessions for each day
   - Sessions sorted by start time

3. **By Room Tab**
   - View sessions by conference room
   - Expandable room sections showing all sessions in each room
   - Useful for finding what's happening in a specific location

4. **My Schedule Tab**
   - View all sessions you've starred
   - Organized by day and sorted by time
   - Quick access to your personalized agenda

### ⭐ Key Features

- **Star Sessions**: Tap the star icon to add sessions to your personal schedule
- **Session Details**: Tap any session to view full details including:
  - Complete abstract
  - Speaker information and bios
  - Time, room, language, and level
- **Real-time Status**: Sessions currently happening are highlighted with "HAPPENING NOW" badge
- **Persistent Storage**: Your starred sessions are saved locally and persist between app launches

### 📊 Session Information

Each session card displays:
- Session title
- Time (start and end)
- Room location
- Session level (Business, Technical, Industry Support, etc.)
- Language
- Speaker names
- Real-time status indicator

## Technical Details

### Built With
- **Flutter**: Cross-platform mobile framework
- **Material Design 3**: Modern UI design system
- **shared_preferences**: Local storage for starred sessions
- **intl**: Date and time formatting

### Architecture
- **Models**: `Session` and `Speaker` classes with JSON serialization
- **Services**: `AgendaService` for loading and managing agenda data
- **Screens**: Modular screen components with state management
- **Widgets**: Reusable session card widget

### Data Source
The app loads agenda data from `agenda.json` file included as an asset. To update the agenda:
1. Edit the `agenda.json` file in the project root
2. Rebuild the app with `flutter build apk`

## Building the App

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

The APK will be located at:
`build/app/outputs/flutter-apk/app-debug.apk` (or `app-release.apk`)

## Installing on Android

1. Enable "Install from Unknown Sources" on your Android device
2. Transfer the APK to your device
3. Tap the APK to install

Or use ADB:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Running in Development

```bash
# Connect your Android device or start an emulator
flutter devices

# Run the app
flutter run
```

## Updating the Agenda

1. Edit `agenda.json` with the latest session data
2. The JSON format is:
```json
[
  {
    "title": "Session Title",
    "room": "Room Name",
    "day": "2025-12-05",
    "start_time": "11:00",
    "end_time": "11:50",
    "language": "English",
    "level": "Technical",
    "abstract": "Session description...",
    "speakers": [
      {
        "name": "Speaker Name",
        "bio": "Speaker bio..."
      }
    ]
  }
]
```
3. Rebuild and reinstall the app

## Project Structure

```
lib/
├── main.dart                      # App entry point and splash screen
├── models/
│   ├── session.dart              # Session data model
│   └── speaker.dart              # Speaker data model
├── services/
│   └── agenda_service.dart       # Agenda data management
├── screens/
│   ├── home_screen.dart          # Main screen with tabs
│   └── session_detail_screen.dart # Session details view
└── widgets/
    └── session_card.dart         # Reusable session card widget
```

## Future Enhancements

Potential features to add:
- Search functionality
- Filter by level, language, or track
- Calendar integration
- Notifications for starred sessions
- Conflict detection for overlapping starred sessions
- Dark mode support
- Export personal schedule

## License

This is a private project for conference attendance.

