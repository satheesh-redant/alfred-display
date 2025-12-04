// import 'package:flutter/material.dart';
//
// class CommonButtonWidget extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//
//   const CommonButtonWidget({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.isLoading = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: isLoading
//             ? const SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : Text(
//           text,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

//
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isActive;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final TextStyle? textStyle;

  const ButtonWidget({
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
          backgroundColor: backgroundColor ?? (isActive ? Colors.black : Colors.grey.shade400),
          side: borderSide ?? BorderSide.none,
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
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

