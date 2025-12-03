import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class RobotPose {
  final double x;
  final double y;
  final double yaw;
  final DateTime timestamp;

  RobotPose({
    required this.x,
    required this.y,
    required this.yaw,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory RobotPose.fromTfTransform(Map<dynamic, dynamic> transform) {
    final translation = transform['transform']['translation'];
    final rotation = transform['transform']['rotation'];

    final x = (translation['x'] as num).toDouble();
    final y = (translation['y'] as num).toDouble();

    // Convert quaternion to yaw (rotation around Z-axis for 2D)
    final qx = (rotation['x'] as num).toDouble();
    final qy = (rotation['y'] as num).toDouble();
    final qz = (rotation['z'] as num).toDouble();
    final qw = (rotation['w'] as num).toDouble();

    final yaw = math.atan2(2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz));

    return RobotPose(x: x, y: y, yaw: yaw);
  }

  @override
  String toString() {
    return 'X: ${x.toStringAsFixed(2)}m Y: ${y.toStringAsFixed(2)}m '
        'Yaw: ${(yaw * 180 / math.pi).toStringAsFixed(1)}°';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RobotPose &&
              runtimeType == other.runtimeType &&
              x == other.x &&
              y == other.y &&
              yaw == other.yaw;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ yaw.hashCode;
}

// Add to robot_pose_provider.dart
class RobotPoseNotifier extends StateNotifier<RobotPose?> {
  RobotPoseNotifier() : super(null);

  void updatePose(RobotPose pose) {
    print('\n📍 ROBOT POSE PROVIDER UPDATE');
    print('Previous pose: $state');
    print('New pose: $pose');
    state = pose;
    print('State updated successfully');
  }

  void clearPose() {
    print('🗑️ Clearing robot pose');
    state = null;
  }

  // Add a test method
  void testPose() {
    print('🧪 Testing robot pose with dummy data');
    final testPose = RobotPose(
      x: 2.0,
      y: 1.5,
      yaw: 0.785, // 45 degrees
    );
    updatePose(testPose);
  }
}

final robotPoseProvider = StateNotifierProvider<RobotPoseNotifier, RobotPose?>((ref) {
  return RobotPoseNotifier();
});
