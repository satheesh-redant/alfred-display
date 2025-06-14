import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';

class TableGridButtonWidget extends StatelessWidget {
  final String label;
  final bool isDashed;
  final int? tableNumber;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isDisabled;
  final bool isMarked;
  final bool ignoreMarkedBackground;

  const TableGridButtonWidget({
    super.key,
    required this.label,
    this.isDashed = false,
    this.tableNumber,
    this.onPressed,
    this.isSelected = false,
    this.isDisabled = false,
    this.isMarked = false,
    this.ignoreMarkedBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? Colors.black
        : (isMarked && !ignoreMarkedBackground)
        ? Colors.grey[100]!
        : Colors.transparent;

    final textColor = isSelected
        ? Colors.white
        : isMarked
        ? Colors.grey[400]!
        : isDisabled
        ? Colors.grey[300]!
        : const Color(0xFF757575);

    final borderColor = isSelected
        ? Colors.white
        : isMarked
        ? Colors.grey[400]!
        : isDisabled
        ? Colors.grey[300]!
        : const Color(0xFF757575);

    final buttonContent = SizedBox(
      width: 138.w,
      height: 60.h,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 20.sp,
            fontWeight: isMarked ? FontWeight.w300 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );

    if (isDashed) {
      return DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(8.r),
        dashPattern: [4.w, 4.w],
        color: borderColor,
        strokeWidth: 1.w,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(8.r),
            child: buttonContent,
          ),
        ),
      );
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8.r),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: 0.5.w,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
