
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/appbar_widget.dart';
import 'package:alfred/config/alfred_constants.dart';

class DeliveryInProgressScreen extends ConsumerStatefulWidget {
  const DeliveryInProgressScreen({super.key});

  @override
  ConsumerState<DeliveryInProgressScreen> createState() =>
      _DeliveryInProgressScreenState();
}

class _DeliveryInProgressScreenState
    extends ConsumerState<DeliveryInProgressScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.replace(AlfredConstants.routeDeliveryCompleteScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableNumber =
        GoRouterState.of(context).pathParameters['tableNumber'] ?? '0';

    return Scaffold(
      body: Column(
        children: [
          AppBarWidget(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 114.w,
                      maxHeight: 38.h,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Table $tableNumber",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2, // Line height multiplier, not scaled
                          letterSpacing: 0.02.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 217.w,
                      maxHeight: 29.h,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Alfred is on move...",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2, // Line height multiplier, not scaled
                          letterSpacing: 0.02.w,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 64.h),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 209.w,
                        maxHeight: 439.h,
                      ),
                      child: Image.asset(
                        "assets/images/alfred_moving.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
