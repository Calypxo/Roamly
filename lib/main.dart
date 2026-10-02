import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/itinerary_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RoamlyApp());
}

class RoamlyApp extends StatelessWidget {
  const RoamlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            return AuthProvider();
          },
        ),
        ChangeNotifierProvider<TripProvider>(
          create: (context) {
            return TripProvider();
          },
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (context) {
            return ExpenseProvider();
          },
        ),
        ChangeNotifierProvider<ItineraryProvider>(
          create: (context) {
            return ItineraryProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Roamly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.brown,
            primary: AppColors.brown,
            secondary: AppColors.sage,
            tertiary: AppColors.honey,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.brown,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}