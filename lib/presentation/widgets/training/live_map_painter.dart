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
    _drawOccupancyGrid(canvas, size);
    if (robotPose != null) {
      _drawRobot(canvas, size);
    }
  }

  void _drawOccupancyGrid(Canvas canvas, Size size) {
    final paint = Paint();

    // Calculate scale to fit map in widget
    final scaleX = size.width / mapData.width;
    final scaleY = size.height / mapData.height;
    final scale = math.min(scaleX, scaleY);

    // Center the map
    final offsetX = (size.width - mapData.width * scale) / 2;
    final offsetY = (size.height - mapData.height * scale) / 2;

    for (int y = 0; y < mapData.height; y++) {
      for (int x = 0; x < mapData.width; x++) {
        final occupancy = mapData.occupancyGrid[y][x];

        // Color based on occupancy value
        // -1 = unknown (gray), 0 = free (white), 100 = occupied (black)
        Color color;
        if (occupancy == -1) {
          color = Colors.grey.shade400; // Unknown
        } else if (occupancy == 0) {
          color = Colors.white; // Free space
        } else if (occupancy >= 50) {
          color = Colors.black; // Occupied
        } else {
          // Probabilistic occupancy (gray scale)
          final grayValue = 255 - (occupancy * 2.55).round();
          color = Color.fromRGBO(grayValue, grayValue, grayValue, 1.0);
        }

        paint.color = color;

        final rect = Rect.fromLTWH(
          offsetX + x * scale,
          offsetY + y * scale,
          scale,
          scale,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawRobot(Canvas canvas, Size size) {
    final scaleX = size.width / mapData.width;
    final scaleY = size.height / mapData.height;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - mapData.width * scale) / 2;
    final offsetY = (size.height - mapData.height * scale) / 2;

    // Convert robot pose from world coordinates to pixel coordinates
    final robotPixelX = offsetX + ((robotPose!.x - mapData.originX) / mapData.resolution) * scale;
    final robotPixelY = offsetY + ((robotPose!.y - mapData.originY) / mapData.resolution) * scale;

    final paint = Paint();

    // Draw robot base (circle)
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(robotPixelX, robotPixelY),
      8.0,
      paint,
    );

    // Draw robot orientation (arrow)
    paint.color = Colors.red;
    paint.strokeWidth = 3.0;
    paint.style = PaintingStyle.stroke;

    final arrowLength = 20.0;
    final endX = robotPixelX + arrowLength * math.cos(robotPose!.yaw);
    final endY = robotPixelY + arrowLength * math.sin(robotPose!.yaw);

    canvas.drawLine(
      Offset(robotPixelX, robotPixelY),
      Offset(endX, endY),
      paint,
    );

    // Draw arrowhead
    final arrowHeadLength = 8.0;
    final arrowAngle = math.pi / 6; // 30 degrees

    final leftArrowX = endX - arrowHeadLength * math.cos(robotPose!.yaw - arrowAngle);
    final leftArrowY = endY - arrowHeadLength * math.sin(robotPose!.yaw - arrowAngle);

    final rightArrowX = endX - arrowHeadLength * math.cos(robotPose!.yaw + arrowAngle);
    final rightArrowY = endY - arrowHeadLength * math.sin(robotPose!.yaw + arrowAngle);

    canvas.drawLine(Offset(endX, endY), Offset(leftArrowX, leftArrowY), paint);
    canvas.drawLine(Offset(endX, endY), Offset(rightArrowX, rightArrowY), paint);

    // Draw robot footprint (optional - shows robot size)
    paint.color = Colors.red.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(robotPixelX, robotPixelY),
      15.0, // Approximate robot radius in pixels
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
