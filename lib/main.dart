import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:news_app_mvvm/core/routes/app_router.dart';
import 'package:news_app_mvvm/core/theme/app_theme.dart';
import 'package:news_app_mvvm/core/utils/ui_helpers.dart';
import 'package:news_app_mvvm/core/viewmodels/global_alert_viewmodel.dart';
import 'package:news_app_mvvm/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:news_app_mvvm/injection_container.dart';

void main() async {
  // ── 1. INISIALISASI FLUTTER ───────────────────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── 2. ORIENTASI & STATUS BAR ─────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── 3. INISIALISASI GET_IT (DEPENDENCY INJECTION) ─────────────────────────
  await initDependencies();

  // ── 4. GLOBAL ERROR HANDLING (SINKRON) ────────────────────────────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO: Tambahkan FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      debugPrint('🔴 UI/Widget Error: ${details.exception}');
      debugPrint(details.stack?.toString());
    }
  };

  // ── 5. GLOBAL ERROR HANDLING (ASINKRON / ISOLATE) ─────────────────────────
  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kReleaseMode) {
      debugPrint('🔴 Asynchronous Error: $error');
      debugPrint(stack.toString());
    }
    // TODO: Tambahkan FirebaseCrashlytics.instance.recordError(error, stack);
    return true; 
  };

  // ── 6. RUN APP ──────────────────────────────────────────────────────────
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<GlobalAlertViewModel>()),
      ],
      child: GlobalAlertWrapper(
        child: MaterialApp.router(
          title: 'News App MVVM',
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class GlobalAlertWrapper extends StatefulWidget {
  final Widget child;
  const GlobalAlertWrapper({super.key, required this.child});

  @override
  State<GlobalAlertWrapper> createState() => _GlobalAlertWrapperState();
}

class _GlobalAlertWrapperState extends State<GlobalAlertWrapper> {
  late GlobalAlertViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Gunakan post frame callback untuk mengambil viewModel setelah di-inject
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = context.read<GlobalAlertViewModel>();
      _viewModel.addListener(_onAlertStateChanged);
    });
  }

  void _onAlertStateChanged() {
    if (_viewModel.hasNetworkError) {
      final navContext = AppRouter.rootNavigatorKey.currentContext;
      if (navContext != null) {
        UIHelpers.showNetworkBottomSheet(navContext, _viewModel.isTimeout);
      }
      // Reset state agar tidak terus-menerus muncul
      _viewModel.clearNetworkError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onAlertStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
