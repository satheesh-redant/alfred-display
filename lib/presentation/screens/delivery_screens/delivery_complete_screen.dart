import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/alfred_constants.dart';
import '../../../models/route_state.dart';
import '../../../view_models/delivery_view_model.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/button_widget.dart';
import 'delivery_main_screen.dart';

class DeliveryCompleteScreen extends ConsumerStatefulWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  ConsumerState<DeliveryCompleteScreen> createState() =>
      _DeliveryCompleteScreenState();
}

class _DeliveryCompleteScreenState
    extends ConsumerState<DeliveryCompleteScreen> {

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final defaultWidth = screenWidth >= 1024 ? 697.0 : screenWidth * 0.55;
    final defaultHeight = 80.0;

    final screenHeight = MediaQuery.of(context).size.height;

    final selectedTable = ref.watch(deliveryScreenTableProvider);

    // ref.listen(
    //   basePointVMProvider,
    //   (previous, next) {
    //     if (next.isNotEmpty) {
    //       if (next.toUpperCase() == ROSConstants.success) {
    //         ref.context.loaderOverlay.hide();
    //         ref.read(basePointVMProvider.notifier).stopTimer();
    //         context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
    //       }
    //     }
    //   },
    // );

    ref.listen(
      deliveryVMProvider,
      (previous, next) {
        if (next.toLowerCase() == "moving") {
          context
              .pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
        }
      },
    );

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
                        AppBarWidget(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: max(
                                  20, (screenWidth - 540 * scaleFactor) / 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 75 * scaleFactor),
                                // "Alfred is ready to serve" Text
                                Text(
                                  selectedTable?.route == 0
                                      ? "Alfred is ready to serve"
                                      : "Reached washing area",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 36 * scaleFactor,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                    letterSpacing: 0.02,
                                    color: Colors.black,
                                  ),
                                ),

                                // Instruction Text
                                SizedBox(height: 17 * scaleFactor),
                                Text(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: defaultWidth,
                                height: defaultHeight,
                                child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(deliveryScreenTableProvider.notifier)
                                    .state = RouteState(tableNumber: 3, route: -1);
                                ref
                                    .read(deliveryVMProvider.notifier)
                                    .moveTable(table: 3, route: -1);
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: selectedTable?.route != -1 ? 6 : 0,
                              ),
                              child: Text(
                                "Go to Washing Area",
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            )),
                            // ButtonWidget(
                            //   text: "Go to Washing Area",
                            //   onPressed: () {
                            //     ref
                            //         .read(deliveryScreenTableProvider.notifier)
                            //         .state =
                            //         RouteState(
                            //             tableNumber: 3,
                            //             route: -1);
                            //     ref
                            //         .read(deliveryVMProvider.notifier)
                            //         .moveTable(table: 3, route: -1);
                            //   },
                            //   isActive: selectedTable?.route != -1,
                            //   width: MediaQuery.of(context).size.width * 0.25,
                            // ),
                            SizedBox(width: 40),
                            ButtonWidget(
                              text: "Go to Base",
                              onPressed: () {
                                ref
                                    .read(deliveryScreenTableProvider.notifier)
                                    .state = RouteState(tableNumber: 0, route: 1);
                                ref
                                    .read(deliveryVMProvider.notifier)
                                    .moveTable(table: 0, route: 1);
                                // ref.read(basePointVMProvider.notifier).triggerReturnToBase();
                              },
                              isActive: true,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ],
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
