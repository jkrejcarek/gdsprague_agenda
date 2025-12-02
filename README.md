# GDS Prague Agenda App

A Flutter Android app for viewing and managing the GDS Prague conference agenda.

## Features

### 📱 Five Main Views

1. **Overview Tab**
   - Shows currently happening sessions
   - Displays the next upcoming sessions (all sessions starting at the same time)
   - Lists all sessions for today, organized by time blocks
   - Pull to refresh to reload the agenda
   - Visual time block headers with session counts

2. **By Day Tab**
   - Browse sessions organized by conference days
   - Expandable day sections showing all sessions for each day
   - Sessions grouped by time blocks for easy navigation
   - **Smart expansion**: Past days automatically collapsed, current and future days expanded
   - Sessions sorted by start time with clear visual separation

3. **By Room Tab**
   - View sessions by conference room
   - Expandable room sections showing all sessions in each room
   - Sessions chronologically ordered
   - Useful for finding what's happening in a specific location

4. **Timeline Tab** ⭐ NEW
   - Visual grid-based schedule view
   - **Time on Y-axis**: Hour-based time slots from first to last session
   - **Rooms on X-axis**: All conference rooms in standard order (Hangar 13 Hall, Panorama Hall, Lecture Hall, Summit Hall, Creative Hall, Indie Hall)
   - **Color-coded sessions**: Each session displayed with its level color
   - **Proportional sizing**: Session cards sized based on actual duration
   - **Day selector**: Switch between conference days with segmented button
   - **Synchronized scrolling**: Time column and session grid scroll together vertically
   - **Horizontal scrolling**: Pan across rooms to see full schedule
   - **Interactive cards**: Tap any session to view full details
   - **Duration display**: Each card shows session length in minutes
   - Perfect for visualizing the entire conference schedule at a glance

5. **My Schedule Tab**
   - View all sessions you've starred
   - Organized by day and time blocks
   - Helps identify scheduling conflicts (overlapping sessions)
   - Quick access to your personalized agenda

### ⭐ Key Features

- **Star Sessions**: Tap the star icon to add sessions to your personal schedule
- **Level Filtering**: 
  - Filter sessions by one or more levels (Business, Technical, Industry Support, etc.)
  - Multi-select capability for viewing multiple tracks
  - Filter badge shows active filter count
  - Filter banner displays which levels are active
  - Filters persist between app launches
  - Quick clear options available
- **Session Details**: Tap any session to view full details including:
  - Complete abstract
  - Speaker information and bios
  - Time with day of week (e.g., "Fri 11:00 - 11:50")
  - Room, language, and level in compact 2x2 grid layout
- **Real-time Status**: Sessions currently happening are highlighted with "HAPPENING NOW" badge and special background color
- **Persistent Storage**: Your starred sessions and filter preferences are saved locally and persist between app launches
- **Dark Mode Support**: Automatically follows your phone's system dark mode setting for comfortable viewing in any lighting condition
- **Color-Coded Levels**: Each session level has a distinct color for quick identification:
  - Industry Support: Red (#C03232)
  - Legal Summit: Orange (#C66F40)
  - Game/Design: Yellow (#E7AD2F)
  - Technical: Blue (#009EE2)
  - Art/Audio: Green (#9BBA33)
  - Business: Pink (#DE6E81)

### 📊 Session Information

Each session card displays:
- Session title
- Day of week and time (e.g., "Fri 11:00 - 11:50")
- Room location
- Color-coded session level chip
- Language
- Speaker names
- Real-time status indicator for current sessions

### 🎨 Time Block Grouping

Sessions that start at the same time are visually grouped together with:
- Time block header showing start time and session count
- Colored left border accent
- Clear spacing between different time blocks
- Makes it easy to see what's happening simultaneously across different rooms

### 🔍 Level Filtering System

The app includes a powerful filtering system to help you focus on relevant content:

**Features:**
- **Multi-Level Selection**: Choose one or more session levels to view
- **Visual Indicators**: 
  - Filter badge on toolbar shows number of active filters
  - Banner at top of each tab displays which levels are selected
  - Color-coded checkboxes in filter dialog
- **Persistence**: Filter selections are saved and restored between app sessions
- **Cross-View Application**: Filters apply to all tabs (Overview, By Day, By Room, Timeline, My Schedule)
- **Quick Access**: Tap the filter icon in the app bar to open the filter dialog
- **Easy Clearing**: 
  - "Clear All" button in filter dialog
  - X button on the filter banner
  - "Show All" option when no filters selected

**How to Use:**
1. Tap the filter icon (☰) in the app bar
2. Check/uncheck session levels in the dialog
3. Tap "Apply" to see filtered results
4. Filter badge shows count of active filters
5. Filter banner displays selected levels
6. Tap X on banner or "Clear All" in dialog to remove filters

**Available Levels:**
- Industry Support (Red)
- Legal Summit (Orange)
- Game/Design (Yellow)
- Technical (Blue)
- Art/Audio (Green)
- Business (Pink)

## Technical Details

### Built With
- **Flutter**: Cross-platform mobile framework
- **Material Design 3**: Modern UI design system with automatic dark mode support
- **shared_preferences**: Local storage for starred sessions and filter preferences
- **intl**: Date and time formatting

### UI/UX Features
- **Responsive Design**: Optimized for various Android screen sizes
- **Material 3 Theming**: Modern, colorful interface with indigo accents
- **Dark Mode**: Automatic theme switching based on system settings
  - Optimized color schemes for both light and dark themes
  - Reduced eye strain in low-light conditions
  - Battery saving on OLED screens
- **Visual Hierarchy**: Clear time blocks and session grouping
- **Smart Defaults**: Past days auto-collapse, current/future days expanded
- **Filter Indicators**: Badge and banner show active filters
- **Theme-Aware Colors**: All UI elements adapt to light/dark mode

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
        "company": "Company Name",
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
├── main.dart                      # App entry point, splash screen, and theme configuration
├── models/
│   ├── session.dart              # Session data model with color mapping
│   └── speaker.dart              # Speaker data model
├── services/
│   └── agenda_service.dart       # Agenda data management and filtering logic
├── screens/
│   ├── home_screen.dart          # Main screen with tabs and filter UI
│   └── session_detail_screen.dart # Session details view
└── widgets/
    ├── session_card.dart         # Reusable session card widget
    └── level_filter_dialog.dart  # Filter selection dialog
```

## Future Enhancements

Potential features to add:
- Search functionality across all sessions
- Calendar integration for adding sessions to device calendar
- Push notifications for starred sessions (15 minutes before start)
- Conflict warning when starring overlapping sessions
- Export personal schedule to PDF or ICS format
- Offline mode with cached agenda data
- Speaker profile pages with full bios and social links
- Session feedback and rating system
- Map integration for room locations

## License

This is a private project for conference attendance.

