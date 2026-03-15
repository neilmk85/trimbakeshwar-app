# Trimbakeshwar App

## How to Run

### Prerequisites
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Install VS Code + Flutter & Dart extensions
3. Have Android Emulator or physical device ready

### Steps
1. Open this folder (`trimbakeshwar_app`) in VS Code
2. Open terminal (Ctrl + `) and run:
   ```
   flutter pub get
   ```
3. Select a device from the bottom status bar in VS Code
4. Press F5 or run:
   ```
   flutter run
   ```

That's it! The app will build and launch.

## Project Structure

```
trimbakeshwar_app/
├── lib/
│   ├── main.dart                       # Entry point
│   ├── constants/
│   │   ├── constants.dart              # Barrel export
│   │   ├── app_colors.dart             # Colors & gradients
│   │   ├── app_strings.dart            # All text constants
│   │   └── app_data.dart               # Poojas, gallery, timings data
│   ├── screens/
│   │   ├── screens.dart                # Barrel export
│   │   ├── splash_screen.dart          # 6-sec launch screen
│   │   ├── home_screen.dart            # Scaffold + drawer
│   │   ├── trimbakeshwar_screen.dart   # Home content
│   │   ├── guruji_screen.dart          # Priest profile
│   │   ├── temple_screen.dart          # Temple info & timings
│   │   ├── pooja_screen.dart           # 8 pooja cards
│   │   ├── gallery_screen.dart         # Grid view gallery
│   │   ├── fullscreen_gallery.dart     # Fullscreen image viewer
│   │   └── contact_screen.dart         # Contact profile page
│   ├── widgets/
│   │   ├── widgets.dart                # Barrel export
│   │   ├── gradient_app_bar.dart       # Reusable AppBar
│   │   ├── section_title.dart          # Reusable heading
│   │   └── app_drawer.dart             # Navigation drawer
│   └── utils/
│       ├── utils.dart                  # Barrel export
│       └── url_helper.dart             # URL launcher helper
├── android/                            # Android platform files
├── ios/                                # iOS platform files
├── web/                                # Web platform files
├── test/                               # Tests
├── pubspec.yaml                        # Dependencies
└── analysis_options.yaml               # Lint rules
```
