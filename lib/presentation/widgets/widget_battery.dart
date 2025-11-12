import 'package:alfred/models/battery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetBattery extends ConsumerWidget {
  const WidgetBattery({
    super.key,
    this.trackHeight = 12.0,
    this.trackAspectRatio = 2.0,
    this.borderRadius,
    this.fillChargeDuration = const Duration(seconds: 1),
    this.fillChargeCurve = Curves.ease,
    required this.batteryState,
  });

  final BatteryState? batteryState;
  final double trackHeight;
  final double trackAspectRatio;
  final BorderRadius? borderRadius;
  final Duration fillChargeDuration;
  final Curve fillChargeCurve;

  double get _trackWidth => trackHeight * trackAspectRatio;
  double get _trackBorderWidth => trackHeight / 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical centering
      children: [
        _batteryTrack(context),
        _batteryKnob(context),
        _batteryPercentage(context),
        if (batteryState?.statusEnum == BatteryStatus.charging)
          _chargingAnimation(context)
        else
          const SizedBox.shrink(key: ValueKey("empty")),
      ],
    );
  }

  Widget _batteryKnob(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: trackHeight / 15, right: 5),
      child: Container(
        height: trackHeight / 3,
        width: trackHeight / 6,
        decoration: BoxDecoration(
          color: Colors.black /*batteryState?.percentageColor*/,
          borderRadius: BorderRadius.circular(trackHeight / 18),
        ),
      ),
    );
  }

  Widget _batteryPercentage(BuildContext context) {
    // Convert percentage to integer for display
    final percentageValue = ((batteryState?.percentage ?? 0) * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Text(
        "$percentageValue%",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF000000),
          height: 1.0, // Ensures text doesn't add extra vertical space
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
          color: Colors.black /*batteryState!.percentageColor*/,
          width: _trackBorderWidth,
        ),
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
    // Convert percentage (0.0 to 1.0) to actual percentage value
    final percentage = (batteryState?.percentage ?? 0) * 100;

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
              width: (_trackWidth - _trackBorderWidth * 4) * percentage / 100,
              height: double.infinity,
              decoration: BoxDecoration(color: batteryState?.percentageColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chargingAnimation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: SizedBox(
        width: 7,
        height: 13,
        child: SvgPicture.asset(
          'assets/images/icon_charging.svg',
          width: 7,
          height: 13,
          fit: BoxFit.contain,
          semanticsLabel: 'Estimated Charging Icon',
        ),
      ),
    );
  }
}
