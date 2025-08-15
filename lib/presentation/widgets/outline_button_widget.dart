import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OutlineButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final TextStyle? textStyle;

  const OutlineButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isActive,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderSide,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultWidth = 697.w; // Matches 697 pixels in 1280x800 design
    final defaultHeight = 80.h; // Matches 100 pixels in 1280x800 design

    return SizedBox(
      width: width?.w ?? defaultWidth,
      height: height?.h ?? defaultHeight,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? (isActive ? Colors.white : Colors.grey.shade400),
          side: borderSide ?? BorderSide(color: isActive ? Colors.black : Colors.grey.shade400, width: 1.5.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: isActive ? 6 : 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: Text(
          text,
          style: textStyle ??
              GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.black : Colors.grey.shade500,
              ),
        ),
      ),
    );
  }
}