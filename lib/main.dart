import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cosmetics_catalog/firebase_options.dart';
import 'package:cosmetics_catalog/core/di/injection_container.dart';
import 'package:cosmetics_catalog/core/router/app_router.dart';
import 'package:cosmetics_catalog/core/theme/app_theme.dart';
import 'package:cosmetics_catalog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cosmetics_catalog/features/products/presentation/bloc/products_bloc.dart';
import 'package:cosmetics_catalog/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cosmetics_catalog/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:cosmetics_catalog/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Устанавливаем язык Firebase на русский по умолчанию
    FirebaseAuth.instance.setLanguageCode('ru');
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
    // Try to initialize without options as fallback
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized (fallback mode)');
    } catch (e2) {
      print('❌ Firebase initialization failed: $e2');
    }
  }
  
  // Initialize dependency injection
  await initializeDependencies();
  
  // Initialize notification service
  await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => getIt<ProductsBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<FavoritesBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDark = themeState is ThemeLoaded ? themeState.isDark : false;
          return MaterialApp.router(
            title: 'Каталог Косметики',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

