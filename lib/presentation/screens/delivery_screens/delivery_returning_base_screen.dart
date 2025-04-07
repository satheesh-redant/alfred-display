import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/appbar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DeliveryReturningBaseScreen extends ConsumerWidget {
  const DeliveryReturningBaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factor based on screen size
          final scaleFactor = isMobile
              ? min(screenWidth / 375, 1.0)  // Base on iPhone 8 width
              : 1.0;

          return Stack(
            children: [
              // Background content
              Column(
                children: [
                  AlfredAppBar(),
                  Expanded(
                    child: Container(), // Empty expanded to push content down
                  ),
                ],
              ),

              // Centered Content with scaled dimensions
              Center(
                child: Transform.scale(
                  scale: scaleFactor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // "Returning to Base" Text
                      Padding(
                        padding: const EdgeInsets.only(top: 77),
                        child: SizedBox(
                          width: 279,
                          height: 38,
                          child: Text(
                            "Returning to Base",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0.02,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      // "Alfred is on move..." Text
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 217,
                        height: 29,
                        child: Text(
                          "Alfred is on move..",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: const Color(0xFF797977),
                          ),
                        ),
                      ),

                      // Alfred Moving Image
                      const SizedBox(height: 64),
                      SizedBox(
                        width: 209,
                        height: 439,
                        child: Image.asset(
                          "assets/images/alfred_moving.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
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

