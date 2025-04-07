import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/appbar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
                        child: Container(
                          width: min(697 * scaleFactor, screenWidth * 0.9),
                          height: 80 * scaleFactor,
                          margin: EdgeInsets.symmetric(
                            horizontal: max(20, (screenWidth - 697 * scaleFactor) / 2),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000),
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF000000).withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 3 * scaleFactor,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: const Color(0xFF000000).withOpacity(0.15),
                                offset: const Offset(0, 4),
                                blurRadius: 8 * scaleFactor,
                                spreadRadius: 3 * scaleFactor,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.go(AlfredConstants.routeDeliveryReturningBaseScreen);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 35 * scaleFactor,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Go to Base",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 22 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                  height: 24.2 / 22,
                                  letterSpacing: 0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
