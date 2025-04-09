import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;
  final double? height;

  const BottomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isActive,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final defaultWidth = screenWidth >= 1024 ? 697.0 : screenWidth * 0.55;
    final defaultHeight = 80.0;

    return SizedBox(
      width: width ?? defaultWidth,
      height: height ?? defaultHeight,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.black : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: isActive ? 6 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

