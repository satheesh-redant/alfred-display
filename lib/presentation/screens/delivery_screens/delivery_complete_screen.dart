import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/alfred_appbar.dart';

class DeliveryCompleteScreen extends ConsumerWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          // Centered Content with proper visibility
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 75), // Maintain top spacing
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "Alfred is ready to serve" Text
                  SizedBox(
                    width: 426,
                    height: 43,
                    child: Text(
                      "Alfred is ready to serve",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: 0.02,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Instruction Text
                  const SizedBox(height: 17),
                  SizedBox(
                    width: 536,
                    height: 29,
                    child: Text(
                      "Once task is complete, please click Go to Base",
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

                  // Alfred Ready Image
                  const SizedBox(height: 55),
                  SizedBox(
                    width: 178.23,
                    height: 410,
                    child: Image.asset(
                      "assets/images/alfred_ready.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  // "Go to Base" Button
                  const SizedBox(height: 55),
                  Container(
                    width: 697,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.15),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                          spreadRadius: 3,
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
                        minimumSize: const Size(697, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Go to Base",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 24.2 / 22,
                            letterSpacing: 0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Extra space at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



