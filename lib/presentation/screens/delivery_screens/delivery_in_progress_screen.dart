
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/appbar_widget.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DeliveryInProgressScreen extends ConsumerStatefulWidget {
  const DeliveryInProgressScreen({super.key});

  @override
  ConsumerState<DeliveryInProgressScreen> createState() => _DeliveryInProgressScreenState();
}

class _DeliveryInProgressScreenState extends ConsumerState<DeliveryInProgressScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule navigation after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.replace(AlfredConstants.routeDeliveryCompleteScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableNumber = GoRouterState.of(context).pathParameters['tableNumber'] ?? '0';
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factor while maintaining original dimensions
          final scaleFactor = isMobile
              ? min(screenWidth / 375, 1.0) // Now using the imported min() function
              : 1.0;

          return Stack(
            children: [
              // Background content
              Column(
                children: [
                  AppBarWidget(),
                  Expanded(
                    child: Container(), // Empty expanded to push content down
                  ),
                ],
              ),

              // Centered Content with scaled dimensions
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 77),
                  child: Transform.scale(
                    scale: scaleFactor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Table Number Text
                        SizedBox(
                          width: 114,
                          height: 38,
                          child: Text(
                            "Table $tableNumber",
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

                        // "Alfred is on the move..." Text
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 217,
                          height: 29,
                          child: Text(
                            "Alfred is on move...",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0.02,
                              color: Colors.black54,
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
              ),
            ],
          );
        },
      ),
    );
  }
}
