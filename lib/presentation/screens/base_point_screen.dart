import 'package:alfred/presentation/screens/save_starting_point_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/custom_appbar.dart';

class BasePointScreen extends ConsumerStatefulWidget {

  const BasePointScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BasePointScreenState();

}

class _BasePointScreenState extends ConsumerState<BasePointScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(), // Using the updated CustomAppBar
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 79), // Moved title up

          // Title
          Text(
            "Mark Base Point",
            style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 30),

          // Subtitle
          Text(
            "Place Alfred at the Base point to start marking",
            style: GoogleFonts.inter(textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          ),
          const SizedBox(height: 60),

          // Larger Image
          const Center(
            child: Image(
              image: AssetImage("assets/images/base_point.png"),
              height: 320,
              width: 610,// Increased size
            ),
          ),
          const SizedBox(height: 100),

          // Button
          SizedBox(
            width: 697,
            height: 80,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SaveStartingPointDialog(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: Text(
                "I am at the Base Point",
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
