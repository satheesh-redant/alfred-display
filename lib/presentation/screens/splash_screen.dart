
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/alfred_constants.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger navigation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (ref.context.mounted) {
        context.go(AlfredConstants.routeLoadingScreen);
      }
    });

    // Responsive values using the correct API
    final logoSize = _getResponsiveValue(
      context,
      mobile: 80.0,
      tablet: 100.0,
      desktop: 126.0,
    );


    final fontSize = _getResponsiveValue(
      context,
      mobile: 32.0,
      tablet: 48.0,
      desktop: 64.0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: logoSize * 0.67, // Maintain aspect ratio
                height: logoSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/company_logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: logoSize * 0.5),
              // Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Redant Technology',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get responsive values
  double _getResponsiveValue(
      BuildContext context, {
        required double mobile,
        required double tablet,
        required double desktop,
      }) {
    if (ResponsiveBreakpoints.of(context).isMobile) return mobile;
    if (ResponsiveBreakpoints.of(context).isTablet) return tablet;
    return desktop;
  }
}

