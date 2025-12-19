

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TableGridButtonWidget extends StatelessWidget {
  final String label;
  final int tableNumber;
  final bool isSelected;
  final bool isMarked;
  final VoidCallback onPressed;

  const TableGridButtonWidget({
    super.key,
    required this.label,
    required this.tableNumber,
    required this.isSelected,
    required this.isMarked,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isMarked ? onPressed : null,         // <<< Only logic change
      child: Container(
        width: 138.w,
        height: 60.h,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : isMarked
              ? Colors.grey.shade200
              : Colors.grey.shade300,        // dim if not marked
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade700
                : isMarked
                ? Colors.grey.shade400
                : Colors.grey.shade500,      // border dim if not marked
            width: 2.w,
          ),
        ),
        child: Center(
          child: Text(
            '$label',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : isMarked
                  ? Colors.black
                  : Colors.grey.shade600,    // text dim if not marked
            ),
          ),
        ),
      ),
    );
  }
}
