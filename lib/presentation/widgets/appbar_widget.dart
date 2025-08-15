import 'package:alfred/src/core/configs/assets_constants.dart';
import 'package:alfred/presentation/widgets/battery_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../view_models/battery_view_model.dart';
import '../../view_models/timer_view_model.dart';
import 'timer_widget.dart';

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(40.h);

  AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryVMProvider);
    final timerState = ref.watch(timerProvider);
    return Container(
      height: preferredSize.height,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ───── Left side: logo + timer ─────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // company logo
              Image.asset(
                AssetsConstants.companyLogo,
                width: 15.w,
                height: 20.h,
                fit: BoxFit.contain,
              ),

              SizedBox(width: 12.w),

              // allow the timer to shrink under tight space
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TimerWidget(timerState: timerState),
                ),
              ),
            ],
          ),
          // ───── Right side: wifi + battery ─────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AssetsConstants.iconWifi,
                width: 24.w,
                height: 24.h,
                fit: BoxFit.contain,
              ),

              SizedBox(width: 12.w),

              BatteryWidget(batteryStatus: batteryState),
            ],
          ),
        ],
      ),
    );
  }
}
