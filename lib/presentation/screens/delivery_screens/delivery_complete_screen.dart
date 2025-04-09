import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/appbar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../widgets/bottom_button_widget.dart';  // Import the BottomActionButton widget

class DeliveryCompleteScreen extends ConsumerWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate responsive scaling while maintaining original proportions
          final widthScale = min(screenWidth / 540, 1.0);
          final heightScale = min(screenHeight / 960, 1.0);
          final scaleFactor = min(widthScale, heightScale);

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    // Background content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AlfredAppBar(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: max(20, (screenWidth - 540 * scaleFactor) / 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 75 * scaleFactor),
                                // "Alfred is ready to serve" Text
                                SizedBox(
                                  width: 426 * scaleFactor,
                                  child: Text(
                                    "Alfred is ready to serve",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 36 * scaleFactor,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                      letterSpacing: 0.02,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                // Instruction Text
                                SizedBox(height: 17 * scaleFactor),
                                SizedBox(
                                  width: 536 * scaleFactor,
                                  child: Text(
                                    "Once task is complete, please click Go to Base",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 24 * scaleFactor,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                      letterSpacing: 0.02,
                                      color: const Color(0xFF797977),
                                    ),
                                  ),
                                ),
                                // Alfred Ready Image
                                SizedBox(height: 55 * scaleFactor),
                                SizedBox(
                                  width: 178.23 * scaleFactor,
                                  height: 410 * scaleFactor,
                                  child: Image.asset(
                                    "assets/images/alfred_ready.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Spacer to push content up (accounts for button height)
                                SizedBox(height: 80 * scaleFactor + 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // "Go to Base" Button positioned at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Center(
                        child: BottomActionButton(
                          text: "Go to Base",
                          onPressed: () {
                            context.go(AlfredConstants.routeDeliveryReturningBaseScreen);
                          },
                          isActive: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}