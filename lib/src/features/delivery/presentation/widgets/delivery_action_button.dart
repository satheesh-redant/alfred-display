import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryActionButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double? width;

  const DeliveryActionButton({
    super.key,
    required this.text,
    required this.isEnabled,
    this.isLoading = false,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : (isEnabled ? onPressed : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue : Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
          height: 20.h,
          width: 20.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
