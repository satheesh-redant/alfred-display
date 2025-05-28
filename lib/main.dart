import 'package:alfred/core/routes.dart';
import 'package:alfred/core/themes.dart';
import 'package:alfred/gen/strings.g.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale(); // For localization


  // await windowManager.ensureInitialized();
  // /* For Linux  */
  // WindowOptions windowOptions = const WindowOptions(
  //   fullScreen: true,
  //   titleBarStyle: TitleBarStyle.hidden,
  //   alwaysOnTop: true,
  //   skipTaskbar: true,
  //   windowButtonVisibility: false,
  //   backgroundColor: Colors.black,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.setResizable(false);
  //   await windowManager.setFullScreen(true);
  // });

  /*  For Android */
  /*SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft, // Left-side Landscape
    DeviceOrientation.landscapeRight, // Right-side Landscape
  ]);*/

  runApp(DevicePreview(
      enabled: false/*kReleaseMode*/,
      builder: (context) => TranslationProvider(
            child: const ProviderScope(child: MyApp()),
          )));
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
      builder: (context, child) {
        return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: ResponsiveBreakpoints.builder(
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
              child: Builder(builder: (context) {
                return ResponsiveScaledBox(
                  width: ResponsiveValue<double>(
                    context,
                    conditionalValues: [
                      //Scale:- the application will scale and maintain ratio of designScreenWidth pixels in any resolution by scaling.
                      Condition.largerThan(
                        breakpoint: 0,
                        value: 1200,
                      ),
                    ],
                    defaultValue: 0,
                  ).value,
                  child: ClampingScrollWrapper.builder(
                    dragWithMouse: true,
                    context,
                    child!,
                  ),
                );
              }),
            ));
      },
    ));
  }
}
