
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../model/battery_model.dart';
import '../../provider/battery_provider.dart';


class _BatteryCirclePainter extends CustomPainter {
  final int batteryPercentage;
  final Color baseColor;

  _BatteryCirclePainter(
      {required this.batteryPercentage, required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 150.0;
    const dashRadius = 110.0;

    // Define colors
    const dashedLineColor = Color(0xFFC8E6C9);
    final solidGreenPaint = Paint()
      ..color = baseColor // A bright green like in the image
      ..style = PaintingStyle.fill;

    // Draw the main solid green circle
    canvas.drawCircle(center, radius, solidGreenPaint);

    // 2. Draw the dashed progress border
    const dashLength = 4.0;
    const spaceLength = 4.0;
    const totalSegment = dashLength + spaceLength;
    const dashes = 100; // Number of dash/space pairs (for a smooth effect)
    const angleIncrement = (2 * 3.14159) / dashes;

    final dashPaint = Paint()
      ..color = dashedLineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw all dashes
    for (int i = 0; i < dashes; i++) {
      final startAngle = i * angleIncrement - (3.14159 / 2); // Start from top

      // Draw the dash segment
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: dashRadius),
          startAngle,
          angleIncrement * (dashLength / totalSegment), // Length of the dash
          false,
          dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BatteryCirclePainter oldDelegate) {
    return oldDelegate.batteryPercentage != batteryPercentage;
  }
}

// ============================================================================
// CHARGING ANIMATION (MATCHING YOUR GREEN DESIGN)
// ============================================================================
class ChargingAnimation extends StatefulWidget {
  final double size;
  final Duration duration;
  final int batteryPercentage;

  const ChargingAnimation({
    Key? key,
    this.size = 280.0,
    this.duration = const Duration(milliseconds: 1500),
    required this.batteryPercentage,
  }) : super(key: key);

  @override
  State<ChargingAnimation> createState() => _ChargingAnimationState();
}

class _ChargingAnimationState extends State<ChargingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer gray dashed circle (static)
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: GradientDashedCirclePainter(),
          ),

          // Outer Solid gradient green
          CustomPaint(
            size: Size(widget.size * 0.80, widget.size * 0.80),
            painter: SolidBackgroundPainter(),
          ),

          // Rotating yellow-green arc
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size * 0.75, widget.size * 0.75),
                  painter: RotatingArcPainter(),
                ),
              );
            },
          ),

          // Rotating green-white arc
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: CustomPaint(
                  size: Size(widget.size * 0.75, widget.size * 0.75),
                  painter: RotatingArcPainter1(),
                ),
              );
            },
          ),

          // Inner Static green circle
          CustomPaint(
            size: Size(widget.size * 0.75, widget.size * 0.75),
            painter: GreenBatteryBackgroundPainter(),
          ),

          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bolt,
                color: Colors.white,
                size: widget.size * 0.1,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.batteryPercentage}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.size * 0.16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'BATTERY',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: widget.size * 0.048,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Gradient dashed circle painter
class GradientDashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    const dashCount = 60;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapRatio = 0.5;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapRatio);

      // Calculate position for gradient
      final gradientAngle = startAngle + sweepAngle / 2;

      // Create individual gradient for each dash
      final dashPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0x6E2F2F2F), // Medium gray
            const Color(0x00FFFFFF), // Light gray
            // const Color(0xFFE0E0E0), // Light gray
            // const Color(0xFF9E9E9E), // Medium gray
            // const Color(0xFF757575), // Dark gray
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              center.dx + radius * math.cos(gradientAngle),
              center.dy + radius * math.sin(gradientAngle),
            ),
            radius: 10,
          ),
        )
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SolidBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final solidGreenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0, 0.0),
        end: Alignment(1.0, 0.0),
        colors: [
          const Color(0xFF007B25),
          const Color(0xFF00D932),
        ],
        transform: GradientRotation(math.pi / 4),
      ).createShader(Rect.fromCircle(center: center, radius: radius + 10))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 10, solidGreenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Green background painter (matching your design)
class GreenBatteryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Inner bright green circle (filled)
    final innerGreenPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF28A745), // Center green
          const Color(0xFF00B72A), // Edge darker green
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 30))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 30, innerGreenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Rotating arc painter (yellow-green gradient)
class RotatingArcPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // // Outer dark gray/green border
    final middleGreenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0, 0.0),
        end: Alignment(1.0, 0.0),
        colors: [
          const Color(0x00FFFFFF),
          const Color(0xFF009923),
        ],
        transform: GradientRotation(math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius - 18))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 18, middleGreenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RotatingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // // Outer dark gray/green border
    final outerBorderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0, 0.0),
        end: Alignment(1.0, 0.0),
        colors: [
          const Color(0xFFD9FF00),
          const Color(0x2F2FD54A),
        ],
        transform: GradientRotation(math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius - 10))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// BATTERY CHARGING SCREEN
// ============================================================================

class BatteryChargingScreen extends ConsumerStatefulWidget {
  const BatteryChargingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BatteryChargingScreen> createState() =>
      _BatteryChargingScreenState();
}

class _BatteryChargingScreenState extends ConsumerState<BatteryChargingScreen> {
  @override
  Widget build(BuildContext context) {
    final batteryState = ref.watch(batteryViewModelProvider);

    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar:   AlfredAppBarWidget(),
        body: batteryState.when(
          data: (battery) => _buildChargingView(battery),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Battery Error: $error',
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChargingView(BatteryState battery) {
    final percentage = ref.read(batteryPercentageProvider).round();
    final estimatedRunTime = _calculateEstimatedRunTime(battery);
    final estimatedChargingTime = _calculateChargingTime(battery);
    final fullChargeTime = _calculateFullChargeTime(estimatedChargingTime);

    const primaryGreen = Color(0xFF4CAF50);
    const brightGreen = Color(0xFF43A047);
    const notificationTextColor = Color(0xFF1B5E20);
    final isFullyCharged = percentage >= 100;

    return Column(
      children: [
        const SizedBox(height: 30),

        // Full charge notification or charging chip
        if (isFullyCharged)
          _buildFullChargeNotification(notificationTextColor)
        else
          Image.asset(
            'assets/images/icon_charging_mode.png',
            height: 40,
            width: 250,
            fit: BoxFit.contain,
          ),

        const SizedBox(height: 60),

        Expanded(
          child: SizedBox(
            width: 1080,
            height: 350,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ANIMATED CHARGING CIRCLE - THIS IS THE KEY!
                Container(
                  child: ChargingAnimation(
                    size: 420,
                    duration: const Duration(milliseconds: 1500),
                    batteryPercentage: percentage,
                  ),
                ),

                // Left: Estimated Run Time
                // Positioned(
                //   left: 20,
                //   child: _buildEstimatedRunTime(estimatedRunTime),
                // ),

                // Right: Estimated Charging Time
                // Positioned(
                //   right: 20,
                //   child: _buildEstimatedChargingTime(
                //     estimatedChargingTime,
                //     fullChargeTime,
                //   ),
                // ),
              ],
            ),
          ),
          // Center(
          //   child: ,
          // ),
        ),

        // 7. Small icon and bottom message
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon_power_plug.png',
                height: 35,
                width: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                'Alfred is charging, please disconnect charger to use.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF70727C),
                  fontWeight: FontWeight.w600,
                  height: 1.0, // Removes extra vertical space from text
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedRunTime(String runTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.watch_later_outlined, color: Colors.red, size: 25),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated Run Time',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${runTime} left', // Added "left" word
              style: GoogleFonts.inter(
                fontSize: 32,
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w600,
                height: 1.0, // Removes extra vertical space from text
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstimatedChargingTime(String chargingTime, String fullTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/images/icon_estimated_charging_time.svg',
          // Path to your SVG file
          width: 25,
          height: 13,
        ),
        SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimated Charging Time',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$chargingTime to full',
              style: GoogleFonts.inter(
                fontSize: 32,
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w600,
                height: 1.0, // Removes extra vertical space from text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '($fullTime)',
              style: GoogleFonts.inter(
                fontSize: 20,
                color: const Color(0xFF151414),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullChargeNotification(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 26),
          const SizedBox(width: 10),
          Text(
            'Battery at 100%. You can disconnect the charger.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w600,
              height: 1.0, // Removes extra vertical space from text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargingModeChip(Color primaryGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flash_on, color: primaryGreen, size: 26),
          const SizedBox(width: 10),
          Text(
            'Charging Mode',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateEstimatedRunTime(BatteryState battery) {
    if (battery.current == null || battery.charge == null) return '-- m';
    const avgDischargeCurrent = 5.0;
    final runTimeHours = battery.charge! / avgDischargeCurrent;
    final runTimeMinutes = (runTimeHours * 60).toInt();
    return _formatTime(runTimeMinutes);
  }

  String _calculateChargingTime(BatteryState battery) {
    final viewModel = ref.read(batteryViewModelProvider.notifier);
    final minutes = viewModel.estimatedMinutesLeft;
    if (minutes == null || minutes <= 0) return '0h 0m';
    return _formatTime(minutes);
  }

  String _calculateFullChargeTime(String chargingTime) {
    try {
      final now = DateTime.now();
      final parts = chargingTime.trim().split(' ');
      int totalMinutes = 0;
      for (final part in parts) {
        if (part.endsWith('h')) {
          totalMinutes += int.parse(part.replaceAll('h', '')) * 60;
        } else if (part.endsWith('m')) {
          totalMinutes += int.parse(part.replaceAll('m', ''));
        }
      }
      final fullChargeTime = now.add(Duration(minutes: totalMinutes));
      return DateFormat('h:mm a').format(fullChargeTime);
    } catch (e) {
      return 'Calculating...';
    }
  }

  String _formatTime(int minutes) {
    if (minutes <= 0) return '0 m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  void _showChargingErrorBanner() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Colors.red.shade100,
        leading: const Icon(Icons.error, color: Colors.red, size: 28),
        content: const Text(
          'Charging error detected. Please check power connection.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          ),
        ],
      ),
    );
  }
}
