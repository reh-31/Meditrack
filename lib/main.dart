import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'database/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/medicine_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_medicine_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MediTrack — Medicine Reminder & Tracker App
/// Entry point: initializes Hive, notifications, then launches the app.
/// ─────────────────────────────────────────────────────────────────────────────
Future<void> main() async {
  // Ensure Flutter bindings are initialised before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar so the gradient app bar bleeds through
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local database
  await HiveService.init();

  // Initialize notification service
  await NotificationService.init();
  await NotificationService.requestPermission();

  runApp(const MediTrackApp());
}

class MediTrackApp extends StatelessWidget {
  const MediTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicineProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// AppShell — root widget with FAB that navigates to AddMedicineScreen
/// ─────────────────────────────────────────────────────────────────────────────
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) => FadeTransition(
                opacity: animation,
                child: const AddMedicineScreen(),
              ),
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          AppStrings.addMedicine,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
