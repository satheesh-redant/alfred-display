import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class RobotPose {
  final double x;
  final double y;
  final double z;
  final double roll;
  final double pitch;
  final double yaw;
  final String frameId;
  final DateTime timestamp;

  RobotPose({
    required this.x,
    required this.y,
    required this.z,
    required this.roll,
    required this.pitch,
    required this.yaw,
    required this.frameId,
    required this.timestamp,
  });

  factory RobotPose.fromTfTransform(Map<String, dynamic> transformMsg) {
    final transform = transformMsg['transform'];
    final translation = transform['translation'];
    final rotation = transform['rotation'];

    // Convert quaternion to euler angles
    final qx = (rotation['x'] as num).toDouble();
    final qy = (rotation['y'] as num).toDouble();
    final qz = (rotation['z'] as num).toDouble();
    final qw = (rotation['w'] as num).toDouble();

    // Convert quaternion to euler angles (roll, pitch, yaw)
    final roll = math.atan2(2.0 * (qw * qx + qy * qz), 1.0 - 2.0 * (qx * qx + qy * qy));
    final pitch = math.asin(2.0 * (qw * qy - qz * qx));
    final yaw = math.atan2(2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz));

    return RobotPose(
      x: (translation['x'] as num).toDouble(),
      y: (translation['y'] as num).toDouble(),
      z: (translation['z'] as num).toDouble(),
      roll: roll,
      pitch: pitch,
      yaw: yaw,
      frameId: transformMsg['header']['frame_id'],
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Robot(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${(yaw * 180 / math.pi).toStringAsFixed(1)}°)';
  }
}

class RobotPoseNotifier extends StateNotifier<RobotPose?> {
  RobotPoseNotifier() : super(null);

  void updatePose(RobotPose pose) {
    state = pose;
  }

  void clearPose() {
    state = null;
  }
}

final robotPoseProvider = StateNotifierProvider<RobotPoseNotifier, RobotPose?>((ref) {
  return RobotPoseNotifier();
});
