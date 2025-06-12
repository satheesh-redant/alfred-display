
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/appbar_widget.dart';

class DeliveryReturningBaseScreen extends ConsumerStatefulWidget {
  const DeliveryReturningBaseScreen({super.key});

  @override
  ConsumerState<DeliveryReturningBaseScreen> createState() =>
      _DeliveryReturningBaseScreenState();
}

class _DeliveryReturningBaseScreenState extends ConsumerState<DeliveryReturningBaseScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarWidget(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 77.h),
                SizedBox(
                  width: 279.w,
                  height: 38.h,
                  child: Text(
                    "Returning to Base",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.02,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: 217.w,
                  height: 29.h,
                  child: Text(
                    "Alfred is on move..",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.02,
                      color: const Color(0xFF797977),
                    ),
                  ),
                ),
                SizedBox(height: 64.h),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 209.w,
                      height: 439.h,
                      child: Image.asset(
                        "assets/images/alfred_moving.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



