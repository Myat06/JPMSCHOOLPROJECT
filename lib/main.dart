import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'data/config/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Food Delivery App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                tertiary: AppColors.accent,
                surface: AppColors.background,
                background: AppColors.background,
                onPrimary: AppColors.textLight,
                onSecondary: AppColors.textDark,
                onTertiary: AppColors.textLight,
                onSurface: AppColors.textDark,
                onBackground: AppColors.textDark,
                error: AppColors.danger,
                onError: AppColors.textLight,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
              ).copyWith(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.muted.withOpacity(0.4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.muted.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                actionTextColor: AppColors.textLight,
              ),
              progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: AppColors.primary,
              ),
              iconTheme: const IconThemeData(color: AppColors.textDark),
              textTheme: Typography.blackMountainView.apply(
                bodyColor: AppColors.textDark,
                displayColor: AppColors.textDark,
              ),
            ),
            routerConfig: AppRouter.router(authProvider),
          );
        },
      ),
    );
  }
}
