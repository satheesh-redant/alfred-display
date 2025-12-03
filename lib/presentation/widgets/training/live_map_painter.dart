import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../providers/map_provider.dart';
import '../../../providers/robot_pose_provider.dart';

class LiveMapPainter extends CustomPainter {
  final MapData mapData;
  final RobotPose? robotPose;

  LiveMapPainter(this.mapData, this.robotPose);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    _drawOccupancyGrid(canvas, size);

    if (robotPose != null) {
      _drawRobot(canvas, size);
    }
  }

  void _drawOccupancyGrid(Canvas canvas, Size size) {
    // SWAP width and height for 90-degree rotation
    final scaleX = size.width / mapData.height;  // Note: height for X
    final scaleY = size.height / mapData.width;  // Note: width for Y
    final scale = math.min(scaleX, scaleY);

    // Center the map
    final offsetX = (size.width - mapData.height * scale) / 2;
    final offsetY = (size.height - mapData.width * scale) / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    // Iterate through grid
    for (int y = 0; y < mapData.height; y++) {
      for (int x = 0; x < mapData.width; x++) {
        final occupancy = mapData.occupancyGrid[y][x];

        // Color scheme
        Color color;
        if (occupancy == -1) {
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
          color = Color.fromRGBO(clampedIntensity, clampedIntensity, clampedIntensity, 1.0);
        }

        paint.color = color;

        // ROTATE 90 DEGREES CLOCKWISE: (x, y) → (height - 1 - y, x)
        final rotatedX = mapData.height - 1 - y;
        final rotatedY = x;

        final rect = Rect.fromLTWH(
          offsetX + rotatedX * scale,
          offsetY + rotatedY * scale,
          scale.ceilToDouble(),
          scale.ceilToDouble(),
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawRobot(Canvas canvas, Size size) {
    // SWAP width and height for rotated coordinate system
    final scaleX = size.width / mapData.height;
    final scaleY = size.height / mapData.width;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - mapData.height * scale) / 2;
    final offsetY = (size.height - mapData.width * scale) / 2;

    // Convert robot world coordinates to grid coordinates
    final gridX = (robotPose!.x - mapData.originX) / mapData.resolution;
    final gridY = (robotPose!.y - mapData.originY) / mapData.resolution;

    // APPLY SAME 90-DEGREE CLOCKWISE ROTATION: (x, y) → (height - 1 - y, x)
    final rotatedGridX = mapData.height - 1 - gridY;
    final rotatedGridY = gridX;

    // Convert to pixel coordinates
    final robotPixelX = offsetX + rotatedGridX * scale;
    final robotPixelY = offsetY + rotatedGridY * scale;

    final paint = Paint();

    // Draw robot footprint
    paint.color = Colors.blue.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    final footprintRadius = math.max(20.0, scale * 0.5);
    canvas.drawCircle(
      Offset(robotPixelX, robotPixelY),
      footprintRadius,
      paint,
    );

    // Draw robot base
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(robotPixelX, robotPixelY),
      12.0,
      paint,
    );

    // Draw outline
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawCircle(
      Offset(robotPixelX, robotPixelY),
      12.0,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant LiveMapPainter oldDelegate) {
    return oldDelegate.mapData != mapData ||
        oldDelegate.robotPose != robotPose;
  }
}
