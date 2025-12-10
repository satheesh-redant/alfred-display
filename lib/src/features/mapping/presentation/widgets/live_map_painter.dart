import 'package:alfred/src/features/mapping/model/map_model.dart';
import 'package:alfred/src/features/mapping/model/robot_pose.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class LiveMapPainter extends CustomPainter {
  final MapData mapData;
  final RobotPose? robotPose;

  LiveMapPainter(this.mapData, this.robotPose);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    _drawOccupancyGrid(canvas, size);

    if (robotPose != null) {
      _drawRobot(canvas, size);
    }
  }

  /// Draws the grid with ROS-style axes:
  ///   +x (forward)  -> up on the screen
  ///   +y (left)     -> left on the screen
  void _drawOccupancyGrid(Canvas canvas, Size size) {
    // mapData.width  : number of cells in +x (forward) direction
    // mapData.height : number of cells in +y (left) direction

    // Horizontal screen extent corresponds to +y (left-right)
    final scaleX = size.width / mapData.height;
    // Vertical screen extent corresponds to +x (front-back)
    final scaleY = size.height / mapData.width;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - mapData.height * scale) / 2.0;
    final offsetY = (size.height - mapData.width * scale) / 2.0;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int cellY = 0; cellY < mapData.height; cellY++) {
      for (int cellX = 0; cellX < mapData.width; cellX++) {
        final occupancy = mapData.occupancyGrid[cellY][cellX];

        Color color;
        if (occupancy == -1) {
          // Unknown
          color = const Color(0xFF808080);
        } else if (occupancy >= 0 && occupancy < 25) {
          final intensity = 255 - (occupancy * 0.4).round();
          color = Color.fromRGBO(intensity, intensity, intensity, 1.0);
        } else if (occupancy >= 25 && occupancy < 65) {
          final grayValue = 200 - ((occupancy - 25) * 3).round();
          color = Color.fromRGBO(grayValue, grayValue, grayValue, 1.0);
        } else {
          final intensity = 100 - (occupancy - 65).round();
          final clampedIntensity = math.max(0, intensity);
          color = Color.fromRGBO(
            clampedIntensity,
            clampedIntensity,
            clampedIntensity,
            1.0,
          );
        }

        paint.color = color;

        // cellX : index along +x (forward)
        // cellY : index along +y (left)
        //
        // We want:
        //   +x (forward) -> up (smaller screen Y)
        //   +y (left)    -> left (smaller screen X)
        final screenX = offsetX + (mapData.height - 1 - cellY) * scale;
        final screenY = offsetY + (mapData.width - 1 - cellX) * scale;

        final rect = Rect.fromLTWH(
          screenX,
          screenY,
          scale,
          scale,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawRobot(Canvas canvas, Size size) {
    // Same scaling as occupancy grid
    final scaleX = size.width / mapData.height;
    final scaleY = size.height / mapData.width;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - mapData.height * scale) / 2.0;
    final offsetY = (size.height - mapData.width * scale) / 2.0;

    // World (ROS) -> grid coordinates (in cells)
    // ROS: x = forward, y = left
    final gridX = (robotPose!.x - mapData.originX) / mapData.resolution;
    final gridY = (robotPose!.y - mapData.originY) / mapData.resolution;

    // Same mapping as cells:
    //   +x (forward) -> up
    //   +y (left) -> left
    final robotPixelX = offsetX + (mapData.height - 1 - gridY) * scale;
    final robotPixelY = offsetY + (mapData.width - 1 - gridX) * scale;

    // Yaw in ROS: 0 = +x (forward). We draw the base arrow pointing up,
    // so yaw=0 should mean "up". Positive yaw in ROS is CCW, but canvas
    // rotation is clockwise for positive angles, so we use -yaw.
    final screenYaw = -robotPose!.yaw;

    _drawRobotIcon(
      canvas,
      Offset(robotPixelX, robotPixelY),
      screenYaw,
      scale,
    );
  }

  /// Draws a robot icon similar to your SVG:
  /// - Glowing outer circle
  /// - Solid blue inner circle
  /// - Light blue arrow tab in the heading direction
  void _drawRobotIcon(Canvas canvas, Offset center, double yaw, double scale) {
    // Fix the visible size; don't let it shrink too much on large maps
    const double outerRadius = 18.0;
    const double innerRadius = 11.0;

    final paint = Paint()..isAntiAlias = true;

    // === Outer glow (radial gradient) ===
    final gradient = const RadialGradient(
      colors: [
        Color(0xFF6FBEFF), // inner
        Color(0xFFF2F9FF), // outer
      ],
      stops: [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    paint
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, outerRadius, paint);

    // === Inner solid circle ===
    paint
      ..shader = null
      ..color = const Color(0xFF37A5FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, paint);

    // === Direction arrow (front) ===
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // IMPORTANT: for yaw = 0, arrow points "front".
    // If you feel it's 90° off, change to (yaw + math.pi / 2) or similar.
    canvas.rotate(yaw);

    // Arrow shape: tip in front (negative Y), base attached near circle border
    final double tipDistance = outerRadius + 6.0;
    final double baseDistance = innerRadius;
    const double halfWidth = 6.0;

    final arrowPath = Path()
      ..moveTo(0, -tipDistance)             // tip
      ..lineTo(-halfWidth, -baseDistance)   // left base
      ..lineTo(halfWidth, -baseDistance)    // right base
      ..close();

    paint
      ..color = const Color(0xFFDCEFFF)
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;
    canvas.drawPath(arrowPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LiveMapPainter oldDelegate) {
    return oldDelegate.mapData != mapData ||
        oldDelegate.robotPose != robotPose;
  }
}
