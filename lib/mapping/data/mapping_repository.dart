
import 'dart:async';
import 'dart:math' as math;

import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/services/ros_service.dart';
import 'package:rosbridge/core/topic.dart';

import '../models/map_data.dart';
import '../models/robot_pose.dart';

class MappingRepository {
  final ROSService _rosService;

  Topic? _mapTopic;
  Topic? _tfTopic;
  Topic? _saveMapTopic;
  Topic? _mapSavedAckTopic;

  bool _isInitialized = false;

  final Map<String, Map<dynamic, dynamic>> _transformCache = {};

  final _mapController = StreamController<MapData>.broadcast();
  final _poseController = StreamController<RobotPose>.broadcast();
  final _mapSavedAckController = StreamController<String>.broadcast();

  MappingRepository(this._rosService);

  Stream<MapData> get mapStream => _mapController.stream;
  Stream<RobotPose> get poseStream => _poseController.stream;
  Stream<String> get mapSavedAckStream => _mapSavedAckController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _mapTopic = _rosService.createTopic(
      '/map',
      'nav_msgs/OccupancyGrid',
      throttleRate: 500,
    );

    _tfTopic = _rosService.createTopic(
      '/tf',
      'tf2_msgs/TFMessage',
      throttleRate: 100,
    );

    _saveMapTopic = _rosService.createTopic(
      ROSConstants.topicSaveMap,
      ROSConstants.msgEmpty,
    );

    _mapSavedAckTopic = _rosService.createTopic(
      ROSConstants.topicMapSaved,
      ROSConstants.msgString,
      throttleRate: 2000,
    );

    _isInitialized = true;
  }

  Future<void> start() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _mapTopic?.subscribe(_handleMapUpdate);
    await _tfTopic?.subscribe(_handleTfUpdate);
    await _mapSavedAckTopic?.subscribe(_handleMapSavedAck);
  }

  Future<void> saveMap() async {
    if (!_isInitialized) {
      throw StateError('Mapping repository not initialized');
    }
    await _saveMapTopic?.publish({});
  }

  Future<void> stop() async {
    try {
      await _mapTopic?.unsubscribe();
      await _tfTopic?.unsubscribe();
      await _mapSavedAckTopic?.unsubscribe();
    } catch (_) {
      // ignore
    }

    _transformCache.clear();
  }

  void dispose() {
    stop();
    _mapController.close();
    _poseController.close();
    _mapSavedAckController.close();
  }

  // === Internal handlers ===
  Future<void> _handleMapUpdate(Map<dynamic, dynamic> mapMsg) async {
    try {
      final mapData = MapData.fromJson(mapMsg);
      _mapController.add(mapData);
    } catch (_) {
      // swallow map parse errors
    }
  }

  Future<void> _handleTfUpdate(Map<dynamic, dynamic> tfMsg) async {
    try {
      final transforms = tfMsg['transforms'] as List;

      for (final transform in transforms) {
        final frameId = _normalizeFrameId(transform['header']['frame_id']);
        final childFrameId = _normalizeFrameId(transform['child_frame_id']);

        final key = '$frameId->$childFrameId';
        _transformCache[key] = transform;

        if (_transformCache.length > 100) {
          _transformCache.remove(_transformCache.keys.first);
        }
      }

      final robotPose = _computeMapToBaseLinkTransform();
      if (robotPose != null) {
        _poseController.add(robotPose);
      }
    } catch (_) {
      // tf spam is expected; ignore
    }
  }

  Future<void> _handleMapSavedAck(Map<dynamic, dynamic> message) async {
    _mapSavedAckController.add(message['data'].toString());
  }

  // === Transform utilities ===
  String _normalizeFrameId(dynamic frameId) {
    String normalized = frameId.toString().trim();
    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  RobotPose? _computeMapToBaseLinkTransform() {
    final baseFrameNames = ['base_link', 'base_footprint', 'base'];
    final mapFrameName = 'map';

    // Try direct transform first (map -> base_link)
    for (final baseName in baseFrameNames) {
      final directKey = '$mapFrameName->$baseName';
      if (_transformCache.containsKey(directKey)) {
        return RobotPose.fromTfTransform(_transformCache[directKey]!);
      }
    }

    // Try to compute through odom (map -> odom -> base_link)
    final odomFrameNames = ['odom', 'odom_combined'];

    for (final odomName in odomFrameNames) {
      final mapToOdomKey = '$mapFrameName->$odomName';

      for (final baseName in baseFrameNames) {
        final odomToBaseKey = '$odomName->$baseName';

        if (_transformCache.containsKey(mapToOdomKey) &&
            _transformCache.containsKey(odomToBaseKey)) {
          return _composeTransforms(
            _transformCache[mapToOdomKey]!,
            _transformCache[odomToBaseKey]!,
          );
        }
      }
    }

    return null;
  }

  RobotPose _composeTransforms(
      Map<dynamic, dynamic> transform1,
      Map<dynamic, dynamic> transform2,
      ) {
    // Extract first transform (map -> odom)
    final t1 = transform1['transform']['translation'];
    final r1 = transform1['transform']['rotation'];
    final x1 = (t1['x'] as num).toDouble();
    final y1 = (t1['y'] as num).toDouble();
    final yaw1 = _quaternionToYaw(r1);

    // Extract second transform (odom -> base_link)
    final t2 = transform2['transform']['translation'];
    final r2 = transform2['transform']['rotation'];
    final x2 = (t2['x'] as num).toDouble();
    final y2 = (t2['y'] as num).toDouble();
    final yaw2 = _quaternionToYaw(r2);

    // Compose transforms using 2D transformation math
    final cosYaw1 = math.cos(yaw1);
    final sinYaw1 = math.sin(yaw1);

    final resultX = x1 + cosYaw1 * x2 - sinYaw1 * y2;
    final resultY = y1 + sinYaw1 * x2 + cosYaw1 * y2;
    final resultYaw = yaw1 + yaw2;

    return RobotPose(
      x: resultX,
      y: resultY,
      yaw: resultYaw,
    );
  }

  double _quaternionToYaw(Map<dynamic, dynamic> quaternion) {
    final qx = (quaternion['x'] as num).toDouble();
    final qy = (quaternion['y'] as num).toDouble();
    final qz = (quaternion['z'] as num).toDouble();
    final qw = (quaternion['w'] as num).toDouble();

    return math.atan2(
      2.0 * (qw * qz + qx * qy),
      1.0 - 2.0 * (qy * qy + qz * qz),
    );
  }
}
