import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/battery_status.dart';

class WidgetBattery extends ConsumerWidget {
  WidgetBattery({
    super.key,
    this.trackHeight = 12.0, // design px
    this.trackAspectRatio = 2.0, // ratio
    this.borderRadius,
    this.fillChargeDuration = const Duration(seconds: 1),
    this.fillChargeCurve = Curves.ease,
    required this.batteryStatus,
  });

  final BatteryStatus batteryStatus;
  final double trackHeight; // in design px
  final double trackAspectRatio;
  final BorderRadius? borderRadius;
  final Duration fillChargeDuration;
  final Curve fillChargeCurve;

  double get _trackWidthPx => trackHeight * trackAspectRatio;

  double get _trackBorderWidthPx => trackHeight / 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,  // align to the right edge
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (batteryStatus.batteryState == BatteryState.charging)
            _chargingAnimation(),
          _batteryTrack(),
          _batteryKnob(),
          _batteryPercentage(),
        ],
      ),
    );
  }

  Widget _batteryTrack() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: _trackWidthPx.w,   // design max
        minWidth: 0,                  // allow it to go to zero if needed
      ),
      height: trackHeight.h,
      decoration: BoxDecoration(
        border: Border.all(
          color: batteryStatus.batteryColor,
          width: _trackBorderWidthPx.w,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular((trackHeight/4).r),
      ),
      child: Padding(
        padding: EdgeInsets.all(_trackBorderWidthPx.w),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular((trackHeight/6).r),
          child: Stack(
            children: [
              const SizedBox.expand(),
              AnimatedContainer(
                duration: fillChargeDuration,
                curve: fillChargeCurve,
                width: (_trackWidthPx - _trackBorderWidthPx*4).w * batteryStatus.batteryPercentage/100,
                height: double.infinity,
                color: batteryStatus.batteryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _batteryKnob() {
    return Padding(
      padding: EdgeInsets.only(
        left: (trackHeight / 15).w,
        right: 3.w,
      ),
      child: Container(
        height: (trackHeight / 3).h,
        width: (trackHeight / 6).w,
        decoration: BoxDecoration(
          color: batteryStatus.batteryColor,
          borderRadius: BorderRadius.circular((trackHeight / 18).r),
        ),
      ),
    );
  }

  Widget _batteryPercentage() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 30.w), // “up to” 30.w wide
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          '${batteryStatus.batteryPercentage}%',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF757575),
            // optional: fix digit widths
            // fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _chargingAnimation() {
    return Icon(
      Icons.bolt,
      key: const ValueKey("bolt"),
      size: (48 / 2).r,  // = 12 px in design → scaled appropriately
      color: Colors.green,
    );
  }
}
