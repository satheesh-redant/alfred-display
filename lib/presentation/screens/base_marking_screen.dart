import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/custom_appbar.dart';

class BasePointMarkerScreen extends ConsumerWidget {
  const BasePointMarkerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    // Navigation after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) context.go(AlfredConstants.routeTableScreen);
      });
    });

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scaling factor while maintaining original proportions
          final scaleFactor = isMobile
              ? screenSize.width / 743 // Base on original text width
              : 1.0;

          return Stack(
            children: [
              // Text with exact proportions but scaled for mobile
              Positioned(
                left: 268 * scaleFactor,
                top: 128 * scaleFactor,
                child: SizedBox(
                  width: 743 * scaleFactor,
                  height: 25 * scaleFactor,
                  child: Text(
                    "You are at your Base Point, please move Alfred towards the table to start marking",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.w400,
                      height: 24.2 / 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Image with exact proportions but scaled for mobile
              Positioned(
                left: (screenSize.width - (600 * scaleFactor)) / 2, // Center horizontally
                top: 250* scaleFactor,
                child: SizedBox(
                  width: 600 * scaleFactor,
                  height: 600 * scaleFactor,
                  child: Image.asset(
                    'assets/images/alfred_basepoint_marking.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}