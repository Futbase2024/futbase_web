import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Crear AuthBloc una sola vez
  late final AuthBloc _authBloc;
  // Crear GoRouter una sola vez
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080), // Diseño base desktop
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            // ========== CONFIGURACIÓN BÁSICA ==========
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // ========== TEMA ==========
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            // ========== ROUTING CON AUTH GUARDS ==========
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
