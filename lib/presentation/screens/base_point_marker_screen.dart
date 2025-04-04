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
      Future.delayed(const Duration(seconds: 6), () {
        if (context.mounted) {
          context.go(AlfredConstants.routeAlfredTrainingScreen);
        }
      });
    });

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AlfredAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20.0 : 40.0,
                vertical: 20.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - kToolbarHeight,
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

                    /// **Alfred Image**
                    SizedBox(
                      width: isMobile ? screenWidth * 0.9 : 600,
                      height: isMobile ? screenWidth * 0.9 : 600,
                      child: Image.asset(
                        'assets/images/alfred_basepoint_marking.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
