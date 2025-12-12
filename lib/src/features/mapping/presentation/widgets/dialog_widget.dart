import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogWidget {
  static void showMarkingDialog({
    required BuildContext context,
    required int tableNumber,
    required VoidCallback onDialogClosed,
  }) {
    print('Showing dialog for Table $tableNumber');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        Timer(const Duration(seconds: 2), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
            print('Dialog dismissed for Table $tableNumber');
          } else {
            print('Dialog context not mounted, cannot dismiss');
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: 642.w,
            height: 368.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Table $tableNumber is marked successfully',
                  style: GoogleFonts.roboto(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      print('Dialog closed for Table $tableNumber');
      onDialogClosed();
    });
  }
}


