import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/appbar_widget.dart';
import 'package:alfred/config/alfred_constants.dart';

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
        context.go(AlfredConstants.routeDeliveryCompleteScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableNumber = GoRouterState.of(context).pathParameters['tableNumber'] ?? '0';

    return Scaffold(
      body: Stack(
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

          // Centered Content Column
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 77), // Maintain top spacing
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
                  const SizedBox(height: 20), // 135 - 77 - 38 ≈ 20
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
                  const SizedBox(height: 64), // 228 - 135 - 29 ≈ 64
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
      ),
    );
  }
}


