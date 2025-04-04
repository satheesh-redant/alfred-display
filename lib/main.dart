import 'package:alfred/core/routes.dart';
import 'package:alfred/core/themes.dart';
import 'package:alfred/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale(); //LocaleSettings.setLocale(AppLocale.hi);

  runApp(TranslationProvider(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Alfred',
      theme: AlfredTheme.lightTheme,
      // darkTheme: AlfredTheme.darkTheme,
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );
      },
    );
  }
}




// import 'package:alfred/core/routes.dart';
// import 'package:alfred/core/themes.dart';
// import 'package:alfred/gen/strings.g.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   LocaleSettings.useDeviceLocale(); //LocaleSettings.setLocale(AppLocale.hi);
//
//   runApp(TranslationProvider(child: const ProviderScope(child: MyApp())));
// }
//
// class MyApp extends ConsumerWidget {
//
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final router = ref.watch(routerProvider);
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       title: 'Alfred',
//       theme: AlfredTheme.lightTheme,
//       // darkTheme: AlfredTheme.darkTheme,
//       routerConfig: router,
//       locale: TranslationProvider.of(context).flutterLocale,
//       supportedLocales: AppLocaleUtils.supportedLocales,
//       localizationsDelegates: GlobalMaterialLocalizations.delegates,
//     );
//   }
// }


