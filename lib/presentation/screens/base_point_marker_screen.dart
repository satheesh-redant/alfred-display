
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';

class BasePointMarkerScreen extends ConsumerWidget {
  const BasePointMarkerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// **Navigation after delay**
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          context.go(AlfredConstants.routeAlfredTrainingScreen);
        }
      });
    });

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions with explicit double conversion
            final imageWidth = (isMobile
                ? screenWidth * 0.9
                : isTablet
                ? 500.0
                : 600.0).toDouble();

            final imageHeight = imageWidth; // Maintain square aspect ratio

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - kToolbarHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20.0 : 40.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// **Instruction Text**
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "You are at your Base Point, please move Alfred towards the table to start marking",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 16.0 : 20.0,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        /// **Alfred Image with proper constraints**
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: imageWidth,
                            maxHeight: imageHeight,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0, // Explicit double value
                            child: Image.asset(
                              'assets/images/alfred_basepoint_marking.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
