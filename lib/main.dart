import 'package:alfred/core/routes.dart';
import 'package:alfred/core/themes.dart';
import 'package:alfred/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:loader_overlay/loader_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale(); // For localization

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Force Landscape Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, // Left-side Landscape
    DeviceOrientation.landscapeRight, // Right-side Landscape
  ]);

  runApp(
    TranslationProvider(
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return GlobalLoaderOverlay(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Alfred',
        theme: AlfredTheme.lightTheme,
        routerConfig: router,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        // ✅ Updated responsive builder
        builder: (context, child) {
          return ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1000, name: TABLET),
              const Breakpoint(start: 1001, end: 1200, name: DESKTOP),
              const Breakpoint(start: 1201, end: 2460, name: '4K'),
            ],
          );
        },
      )
    );

  }
}
