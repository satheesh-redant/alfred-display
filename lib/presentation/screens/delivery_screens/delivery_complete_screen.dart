import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../config/ros_constants.dart';
import '../../../view_models/base_point_view_model.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/button_widget.dart';

class DeliveryCompleteScreen extends ConsumerWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      basePointVMProvider,
          (previous, next) {
        if (next.isNotEmpty) {
          if (next.toUpperCase() == ROSConstants.success) {
            ref.context.loaderOverlay.hide();
            ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
            context.pop();
          }
        }
      },
    );

    return Scaffold(
      body: Column(
        children: [
          AppBarWidget(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 426.w,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Alfred is ready to serve",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: 0.02.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 536.w,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Once task is complete, please click Go to Base",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0.02.w,
                          color: const Color(0xFF797977),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 178.23.w,
                        maxHeight: 410.h,
                        minHeight: 200.h,
                      ),
                      child: Image.asset(
                        "assets/images/alfred_base_point.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: ButtonWidget(
                      text: "Go to Base",
                      onPressed: () {
                        ref.context.loaderOverlay.show();
                        ref.read(basePointVMProvider.notifier).getReturnToBaseAck();
                        ref.read(basePointVMProvider.notifier).triggerReturnToBase();
                      },
                      isActive: true,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
