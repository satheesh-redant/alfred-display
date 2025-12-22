import 'dart:math';
import 'package:alfred/src/features/delivery/state/delivery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../../../core/configs/alfred_constants.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../providers/delivery_providers.dart';

class DeliveryInProgressScreen extends ConsumerStatefulWidget {
  const DeliveryInProgressScreen({super.key});

  @override
  ConsumerState<DeliveryInProgressScreen> createState() =>
      _DeliveryInProgressScreenState();
}

class _DeliveryInProgressScreenState
    extends ConsumerState<DeliveryInProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final screenWidth = MediaQuery.of(context).size.width;

    final deliveryState = ref.watch(deliveryViewModelProvider);
    final viewModel = ref.read(deliveryViewModelProvider.notifier);

    ref.listen(deliveryViewModelProvider, (previous, next) {
      if (next.state == DeliveryStatus.delivered) {
        if (next.isBaseToTable) {
          context.pushReplacement(AlfredConstants.routeDeliveryCompleteScreen);
        } else {
          context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar:   AlfredAppBarWidget(),               // ← updated based on your new app bar
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scaleFactor =
          isMobile ? min(screenWidth / 375, 1.0) : 1.0;

          return Stack(
            children: [
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
                        Text(
                          deliveryState.isBaseToTable
                              ? "Table ${deliveryState.selectedTable}"
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

                        const SizedBox(height: 20),

                        Text(
                          deliveryState.isBaseToTable
                              ? "Alfred is on the move..."
                              : "Alfred is returning...",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: 0.02,
                            color: const Color(0xFF797977),
                          ),
                        ),

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
