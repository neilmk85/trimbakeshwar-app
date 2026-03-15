import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/constants.dart';
import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TrimbakeshwarApp());
}

class TrimbakeshwarApp extends StatelessWidget {
  const TrimbakeshwarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navyDeep,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
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
      home: const SplashScreen(),
    );
  }
}
