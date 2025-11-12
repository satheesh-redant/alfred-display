import 'package:alfred/core/routes.dart';
import 'package:alfred/core/themes.dart';
import 'package:alfred/gen/strings.g.dart';
import 'package:alfred/presentation/screens/battery_screens/battery_alert_listener.dart';
import 'package:alfred/view_models/ros_connection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LocaleSettings.useDeviceLocale(); // For localization

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(TranslationProvider(
    child: const ProviderScope(child: ToastificationWrapper(child: MyApp())),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize ROS connection when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rosConnectionVMProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return ToastificationConfigProvider(
        config: const ToastificationConfig().copyWith(
          itemWidth: double.infinity, // full-width toasts
        ),
        child: GlobalLoaderOverlay(
            child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Alfred',
          theme: AlfredTheme.lightTheme,
          routerConfig: router,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) {
            return BatteryAlertListener(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: ResponsiveBreakpoints.builder(
                      breakpoints: [
                        const Breakpoint(start: 0, end: 450, name: MOBILE),
                        const Breakpoint(start: 451, end: 800, name: TABLET),
                        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                        const Breakpoint(
                            start: 1921, end: double.infinity, name: '4K'),
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
                    )));
          },
        )));
  }
}
