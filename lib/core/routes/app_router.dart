import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_mvvm/features/splash/presentation/pages/splash_page.dart';
import 'package:news_app_mvvm/features/auth/presentation/pages/login_page.dart';
import 'package:news_app_mvvm/features/auth/presentation/pages/register_page.dart';
import 'package:news_app_mvvm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:news_app_mvvm/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:news_app_mvvm/injection_container.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: sl<AuthViewModel>(),
    
    redirect: (context, state) {
      final authViewModel = sl<AuthViewModel>();
      final isInitialized = authViewModel.isInitialized;
      final isAuthenticated = authViewModel.isAuthenticated;
      
      final isSplash = state.uri.toString() == '/splash';
      final isLoggingInOrRegistering = state.uri.toString() == '/login' || state.uri.toString() == '/register';

      // Skenario 1: Aplikasi baru nyala (Splash Screen), biarkan di splash
      if (!isInitialized) {
        return isSplash ? null : '/splash';
      }

      // Skenario 2: Sudah inisialisasi, tapi belum login, dan mau akses halaman tertutup
      // Tendang ke login.
      if (!isAuthenticated && !isLoggingInOrRegistering) {
        return '/login';
      }

      // Skenario 3: Sudah login, tapi iseng buka halaman login/register atau splash
      // Lempar langsung ke dashboard.
      if (isAuthenticated && (isLoggingInOrRegistering || isSplash)) {
        return '/dashboard';
      }

      // Biarkan berjalan normal
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
  );
}
