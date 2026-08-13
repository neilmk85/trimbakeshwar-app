import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/constants.dart';
import 'firebase_options.dart';
import 'screens/screens.dart';
import 'services/language_service.dart';
import 'services/notification_service.dart';

const bool kTestMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.init();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      await NotificationService.init();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TrimbakeshwarApp());
}

class TrimbakeshwarApp extends StatelessWidget {
  const TrimbakeshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.isHindi,
      builder: (context, _) => MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.navyDeep,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.navyDeep,
            foregroundColor: AppColors.white,
            elevation: 0,
            centerTitle: true,
          ),
          drawerTheme: const DrawerThemeData(
            backgroundColor: AppColors.white,
          ),
        ),
        navigatorKey: NotificationService.navigatorKey,
        builder: null,
        home: const SplashScreen(),
      ),
    );
  }
}
