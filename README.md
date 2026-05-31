# MediTrack 💊

**A professional Flutter medicine reminder and tracking application.**

> College Project — Built with Flutter, Hive, flutter_local_notifications, and Provider.

---

## 📱 Features

| Feature | Details |
|---|---|
| **Medicine List** | View all medicines with type, dosage, time, and frequency |
| **Add / Edit** | Full form with validation, time picker, type & frequency selectors |
| **Mark as Taken** | One-tap daily dose tracking |
| **Notifications** | Scheduled local reminders (daily / twice / thrice / weekly) |
| **History** | Grouped intake log with date filter and stats dashboard |
| **Search** | Live search through medicine name, type, and dosage |
| **Offline First** | All data stored locally via Hive — no internet required |

---

## 🏗️ Folder Structure

```
meditrack/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── constants/
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_strings.dart         # All text strings
│   │   └── app_theme.dart           # Material 3 theme
│   ├── models/
│   │   ├── medicine.dart            # Hive model (TypeId 0)
│   │   ├── medicine.g.dart          # Generated adapter
│   │   ├── medicine_history.dart    # History model (TypeId 1)
│   │   └── medicine_history.g.dart  # Generated adapter
│   ├── database/
│   │   └── hive_service.dart        # All DB operations
│   ├── services/
│   │   └── notification_service.dart # Notification scheduling
│   ├── providers/
│   │   └── medicine_provider.dart   # State management (Provider)
│   ├── screens/
│   │   ├── home_screen.dart         # Main screen
│   │   ├── add_medicine_screen.dart # Add / Edit form
│   │   ├── medicine_detail_screen.dart
│   │   └── history_screen.dart      # Intake history
│   ├── widgets/
│   │   ├── medicine_card.dart       # List tile card
│   │   ├── empty_state.dart         # No-data placeholder
│   │   ├── stat_card.dart           # Stats display
│   │   └── medicine_type_chip.dart  # Type badge
│   └── utils/
│       └── date_utils.dart          # Date/time helpers
├── android/                         # Android platform files
├── assets/
│   ├── animations/                  # Lottie files (optional)
│   └── images/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## 🚀 Setup Instructions

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | ≥ 3.16 (stable) |
| Dart | ≥ 3.0 |
| Android SDK | API 21+ |
| Java | 17 |

### Steps

```bash
# 1. Navigate to project
cd C:\Users\rehan\Desktop\MediTrack

# 2. Install dependencies
flutter pub get

# 3. The .g.dart adapter files are already pre-generated.
#    If you ever change the Hive models, re-run:
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run on connected device / emulator
flutter run

# 5. Check for issues
flutter analyze
```

---

## 📦 APK Build Instructions

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for submission)
flutter build apk --release

# Output location:
# build\app\outputs\flutter-apk\app-release.apk
```

---

## 📚 Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| `hive` | ^2.2.3 | Local NoSQL database |
| `hive_flutter` | ^1.1.0 | Flutter Hive integration |
| `flutter_local_notifications` | ^17.2.2 | Scheduled notifications |
| `timezone` | ^0.9.4 | Timezone-aware scheduling |
| `provider` | ^6.1.2 | Reactive state management |
| `google_fonts` | ^6.2.1 | Poppins typography |
| `flutter_animate` | ^4.5.0 | Micro-animations |
| `intl` | ^0.19.0 | Date/time formatting |
| `uuid` | ^4.4.2 | Unique IDs for records |
| `permission_handler` | ^11.3.1 | Runtime permissions |

---

## 🏛️ Architecture

```
UI Layer (Screens / Widgets)
        ↕ Provider (ChangeNotifier)
Business Logic (MedicineProvider)
        ↕
Data Layer (HiveService + NotificationService)
        ↕
Local Storage (Hive Boxes)
```

- **Clean Architecture** — screens never talk to Hive directly
- **Provider Pattern** — single source of truth via `MedicineProvider`
- **Reactive UI** — `Consumer<MedicineProvider>` rebuilds on data changes
- **Null Safety** — fully null-safe Dart 3 code

---

## 🎨 Design System

- **Primary**: `#1565C0` (deep medical blue)
- **Accent**: `#00ACC1` (teal)
- **Font**: Poppins (Google Fonts)
- **Design System**: Material Design 3 (`useMaterial3: true`)
- **Cards**: 16px radius, soft shadows, coloured accent bars
- **Animations**: `flutter_animate` fade + slide entries

---

## 👤 Developer Notes

- The `.g.dart` files are **pre-generated** — no need to run `build_runner` for a fresh build.
- Notifications require **exact alarm permission** on Android 12+ — the app requests it at launch.
- All medicine data is stored **100% offline** in Hive — no backend needed.
- Swipe left on any medicine card to reveal the delete action.

---

*Built for college project submission — MediTrack v1.0.0*
