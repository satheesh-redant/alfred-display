import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SoftShutdownAlertScreen extends ConsumerStatefulWidget {
  const SoftShutdownAlertScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SoftShutdownAlertScreen> createState() =>
      _SoftShutdownAlertScreenState();
}

class _SoftShutdownAlertScreenState
    extends ConsumerState<SoftShutdownAlertScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151414),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/icon_laptop.svg',
                  width: 93,
                  height: 61,
                  semanticsLabel: 'Laptop Icon',
                ),
                const SizedBox(height: 24),
                Text(
                  'Alfred is shutting down ...',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
