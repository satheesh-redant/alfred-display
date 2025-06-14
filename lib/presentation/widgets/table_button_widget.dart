import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';

class TableButtonWidget extends StatelessWidget {
  final int tableNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const TableButtonWidget({
    super.key,
    required this.tableNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: isSelected ? Colors.blue : Colors.grey,
        dashPattern: [6.w, 3.w],
        strokeWidth: 2.w,
        child: Container(
          width: 100.w,
          height: 60.h,
          alignment: Alignment.center,
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          child: Text(
            'Table $tableNumber',
            style: GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: isSelected ? Colors.blue[900] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
