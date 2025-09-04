import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/battery_status.dart';

class WidgetBattery extends ConsumerWidget {
  WidgetBattery({
    super.key,
    this.trackHeight = 12.0,
    this.trackAspectRatio = 2.0,
    this.borderRadius,
    this.fillChargeDuration = const Duration(seconds: 1),
    this.fillChargeCurve = Curves.ease,
    required this.batteryStatus,
  });

  final BatteryStatus batteryStatus;
  final double trackHeight;

  // Aspect ratio = width / height. the width is twice the height.
  final double trackAspectRatio;
  final BorderRadius? borderRadius;

  final Duration fillChargeDuration;
  final Curve fillChargeCurve;

  double get _trackWidth => trackHeight * trackAspectRatio;

  double get _trackBorderWidth => trackHeight / 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        batteryStatus.batteryState == BatteryState.charging
            ? _chargingAnimation(context)
            : const SizedBox.shrink(key: ValueKey("empty")),
        _batteryTrack(context),
        _batteryKnob(context),
        _batteryPercentage(context),
      ],
    );
  }

  Widget _batteryKnob(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: trackHeight / 15, right: 3),
      child: Container(
        height: trackHeight / 3,
        width: trackHeight / 6,
        decoration: BoxDecoration(
          color: batteryStatus.batteryColor,
          borderRadius: BorderRadius.circular(trackHeight / 18),
        ),
      ),
    );
  }

  Widget _batteryPercentage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 15, top: 9, bottom: 9),
      child: Text(
        batteryStatus.batteryPercentage.toString() + "%",
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _batteryTrack(BuildContext context) {
    return Container(
      height: trackHeight,
      width: _trackWidth,
      decoration: BoxDecoration(
        border: Border.all(
            color: batteryStatus.batteryColor, width: _trackBorderWidth),
        borderRadius: borderRadius ?? BorderRadius.circular(trackHeight / 4),
      ),
      child: Stack(
        children: [
          _batteryBar(context),
        ],
      ),
    );
  }

  Widget _batteryBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_trackBorderWidth),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(trackHeight / 6),
        child: Stack(
          children: [
            const SizedBox.expand(),
            AnimatedContainer(
              duration: fillChargeDuration,
              curve: fillChargeCurve,
              width: (_trackWidth - _trackBorderWidth * 4) *
                  batteryStatus.batteryPercentage /
                  100,
              height: double.infinity,
              decoration: BoxDecoration(color: batteryStatus.batteryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chargingAnimation(BuildContext context) {
    return Icon(
      Icons.bolt,
      key: const ValueKey("bolt"),
      size: 48.0 / 4,
      color: Colors.green,
    );
  }

  Widget _lowBatteryAnimation(BuildContext context) {
    return Container();
  }
}
