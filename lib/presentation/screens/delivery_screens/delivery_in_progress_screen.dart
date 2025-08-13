import 'dart:math';
import 'package:alfred/view_models/delivery_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/appbar_widget.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'delivery_main_screen.dart';

class DeliveryInProgressScreen extends ConsumerStatefulWidget {
  const DeliveryInProgressScreen({super.key});

  @override
  ConsumerState<DeliveryInProgressScreen> createState() =>
      _DeliveryInProgressScreenState();
}

class _DeliveryInProgressScreenState
    extends ConsumerState<DeliveryInProgressScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedTable = ref.watch(deliveryScreenTableProvider);

    ref.listen(
      deliveryVMProvider,
      (previous, next) {
        if (next == "delivered" && selectedTable!.route == 0) {
          context.replace(AlfredConstants.routeDeliveryCompleteScreen);
        }
      },
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale factor while maintaining original dimensions
          final scaleFactor = isMobile
              ? min(screenWidth / 375,
                  1.0) // Now using the imported min() function
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
                  padding: const EdgeInsets.only(top: 50),
                  child: Transform.scale(
                    scale: scaleFactor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Table Number Text
                        Text(
                          selectedTable?.route == 0
                              ? "Table ${selectedTable?.tableNumber}"
                              : "Returning to Base",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: Colors.black,
                          ),
                        ),

                        // "Alfred is on the move..." Text
                        const SizedBox(height: 20),
                        Text(
                          "Alfred is on the move...",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: const Color(0xFF797977),
                          ),
                        ),

                        // Alfred Moving Image
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 209,
                          height: 400,
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
