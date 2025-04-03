import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';

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

    return Scaffold(
      appBar: AlfredAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// **Instruction Text**
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  "You are at your Base Point, please move Alfred towards the table to start marking",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    height: 24.2 / 20,
                    color: Colors.black,
                  ),
                ),
              ),

              /// **Alfred Image**
              SizedBox(
                width: 600, // Adjust as needed
                height: 600, // Adjust as needed
                child: Image.asset(
                  'assets/images/alfred_basepoint_marking.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
