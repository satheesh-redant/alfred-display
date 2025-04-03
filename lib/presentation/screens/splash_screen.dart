
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../config/alfred_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger navigation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).mounted) {
        context.go(AlfredConstants.routeLoadingScreen);
      }
    });

    return Container(
      width: 1280,
      height: 800,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Positioned(
            left: 598,
            top: 232,
            child: Container(
              width: 84,
              height: 126,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/company_logo.png"),
                  fit: BoxFit.contain, // Changed to contain to preserve aspect ratio
                ),
              ),
            ),
          ),
          Positioned(
            left: 341,
            top: 421,
            child: SizedBox(
              width: 598,
              child: Container(
                color: Colors.white, // Ensures no background color affects text
                child: Text(
                  'Redant Technology',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 64,
                    fontWeight: FontWeight.w600,
                    height: 0.38,
                    decoration: TextDecoration.none, // Ensures no underline
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
