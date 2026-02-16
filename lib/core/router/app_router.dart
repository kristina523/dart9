import 'package:go_router/go_router.dart';
import 'package:cosmetics_catalog/features/auth/presentation/pages/login_page.dart';
import 'package:cosmetics_catalog/features/auth/presentation/pages/register_page.dart';
import 'package:cosmetics_catalog/features/auth/presentation/pages/reset_password_page.dart';
import 'package:cosmetics_catalog/features/home/presentation/pages/home_page.dart';
import 'package:cosmetics_catalog/features/products/presentation/pages/product_detail_page.dart';
import 'package:cosmetics_catalog/features/products/presentation/pages/add_product_page.dart';
import 'package:cosmetics_catalog/features/products/domain/entities/product_entity.dart';
import 'package:cosmetics_catalog/features/favorites/presentation/pages/favorites_page.dart';
import 'package:cosmetics_catalog/features/profile/presentation/pages/profile_page.dart';
import 'package:cosmetics_catalog/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cosmetics_catalog/features/settings/presentation/pages/settings_page.dart';
import 'package:cosmetics_catalog/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      try {
        final authBloc = context.read<AuthBloc>();
        final isLoggedIn = authBloc.state is AuthAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register' ||
                            state.matchedLocation == '/reset-password' ||
                            state.matchedLocation == '/';
        
        if (!isLoggedIn && !isLoginRoute) {
          return '/login';
        }
        if (isLoggedIn && isLoginRoute) {
          return '/home';
        }
        return null;
      } catch (e) {
        return '/login';
      }
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(productId: id);
        },
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/add-product',
        builder: (context, state) => const AddProductPage(),
      ),
      GoRoute(
        path: '/edit-product',
        builder: (context, state) {
          final product = state.extra as ProductEntity;
          return AddProductPage(product: product);
        },
      ),
    ],
  );
}

