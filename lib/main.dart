import 'package:dummy_epod/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  // Load environment variables safely
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Graceful fallback when .env is not bundled in web production
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://urukjhknsjupknviuxgn.supabase.co',
      );

  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'sb_publishable_bANydNxGW1OerFUgSJvxgg_ReeYL9Gl',
      );

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl.isNotEmpty
        ? supabaseUrl
        : 'https://urukjhknsjupknviuxgn.supabase.co',
    publishableKey: supabaseAnonKey.isNotEmpty
        ? supabaseAnonKey
        : 'sb_publishable_bANydNxGW1OerFUgSJvxgg_ReeYL9Gl',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: goRouter,
    );
  }
}
