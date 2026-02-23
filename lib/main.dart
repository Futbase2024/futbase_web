import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/config/supabase_config.dart';
import 'core/config/app_config_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await initializeDateFormatting('es', null);
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
  // Crear AppConfigCubit una sola vez (global para toda la app)
  late final AppConfigCubit _appConfigCubit;
  // Crear GoRouter una sola vez
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _appConfigCubit = AppConfigCubit()..loadConfig(); // Cargar config al inicio
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _authBloc.close();
    _appConfigCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _appConfigCubit),
      ],
      child: ScreenUtilInit(
        designSize: const Size(1920, 1080), // Diseño base desktop
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            // ========== CONFIGURACIÓN BÁSICA ==========
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // ========== LOCALIZACIONES ==========
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
            ],
            locale: const Locale('es', 'ES'),

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
