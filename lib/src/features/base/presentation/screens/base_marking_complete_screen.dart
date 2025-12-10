
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BasePointMarkingCompleteScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const BasePointMarkingCompleteScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) onComplete();
      });
    });

    return Scaffold(
      appBar:  AlfredAppBarWidget(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
          child: Column(
            children: [
              Text(
                "You are at your Base Point, please move Alfred towards the table to start marking",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/alfred_base_point.png',
                    width: 868.w,
                    height: 442.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
