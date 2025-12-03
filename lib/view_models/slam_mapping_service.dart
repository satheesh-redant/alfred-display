import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';
import 'dart:math' as math;
import '../services/ros_service.dart';
import '../providers/map_provider.dart';
import '../providers/robot_pose_provider.dart';
import '../providers/slam_connection_provider.dart';
import '../config/ros_constants.dart';

class SlamMappingService extends StateNotifier<String> {
  final ROSService _rosService;
  final Ref _ref;

  Topic? _mapTopic;
  Topic? _tfTopic;
  Topic? _saveMapTopic;
  Topic? _mapSavedAckTopic;

  bool _isInitialized = false;

  // Store transform tree for computing map -> base_link
  final Map<String, Map<String, dynamic>> _transformCache = {};

  SlamMappingService(this._rosService, this._ref) : super("Initializing...") {
    print('Initializing SLAM mapping service');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _ref.read(slamConnectionProvider.notifier).setConnecting();

      // Initialize topics
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

      _ref.read(slamConnectionProvider.notifier).setConnected();
      _isInitialized = true;
      state = "Service initialized";

      print('✅ SLAM Mapping Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing SLAM mapping service: $e');
      _ref.read(slamConnectionProvider.notifier).setError(e.toString());
      state = "Error: $e";
    }
  }

  Future<void> startMapping() async {
    try {
      // Ensure service is initialized first
      if (!_isInitialized) {
        await initialize();
      }

      // Subscribe to map updates
      await _mapTopic?.subscribe(_handleMapUpdate);
      print('✅ Subscribed to /map topic');

      // Subscribe to TF updates
      await _tfTopic?.subscribe(_handleTfUpdate);
      print('✅ Subscribed to /tf topic');

      // Subscribe to map save acknowledgment
      await _mapSavedAckTopic?.subscribe(_handleMapSavedAck);
      print('✅ Subscribed to map saved acknowledgment');

      _ref.read(slamConnectionProvider.notifier).setSubscribed();
      state = "SLAM mapping started";
    } catch (e) {
      print('❌ Error starting SLAM mapping: $e');
      _ref.read(slamConnectionProvider.notifier).setError(e.toString());
      state = "Error: $e";
    }
  }

  Future<void> _handleMapUpdate(Map<String, dynamic> mapMsg) async {
    try {
      print('\n📍 Map update received - size: ${mapMsg['info']['width']}x${mapMsg['info']['height']}');
      final mapData = MapData.fromJson(mapMsg);
      _ref.read(mapProvider.notifier).updateMapData(mapData);
      _ref.read(slamConnectionProvider.notifier).setMapReceiving(true);
      state = "Map updated: ${mapData.width}x${mapData.height}";
    } catch (e) {
      print('❌ Error processing map update: $e');
    }
  }

  Future<void> _handleTfUpdate(Map<String, dynamic> tfMsg) async {
    try {
      print('\n🔄 TF Update Received');
      final transforms = tfMsg['transforms'] as List;
      print('Number of transforms in message: ${transforms.length}');

      // Store all transforms in cache
      for (final transform in transforms) {
        final frameId = _normalizeFrameId(transform['header']['frame_id']);
        final childFrameId = _normalizeFrameId(transform['child_frame_id']);

        print('  📌 Transform: $frameId -> $childFrameId');

        // Cache the transform
        final key = '$frameId->$childFrameId';
        _transformCache[key] = transform;

        // Keep cache size reasonable (last 100 transforms)
        if (_transformCache.length > 100) {
          _transformCache.remove(_transformCache.keys.first);
        }
      }

      // Try to find or compute map -> base_link transform
      final robotPose = _computeMapToBaseLinkTransform();

      if (robotPose != null) {
        print('✅ Successfully computed robot pose');
        print('   X: ${robotPose.x.toStringAsFixed(3)} m');
        print('   Y: ${robotPose.y.toStringAsFixed(3)} m');
        print('   Yaw: ${(robotPose.yaw * 180 / math.pi).toStringAsFixed(1)}°');

        _ref.read(robotPoseProvider.notifier).updatePose(robotPose);
        _ref.read(slamConnectionProvider.notifier).setPoseReceiving(true);
      } else {
        print('⚠️  Could not compute map -> base_link transform');
        _printAvailableTransforms();
      }
    } catch (e, stackTrace) {
      print('❌ Error processing TF update: $e');
      print('Stack trace: $stackTrace');
    }
  }

  String _normalizeFrameId(dynamic frameId) {
    // Remove leading slash if present
    String normalized = frameId.toString().trim();
    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    return normalized;
  }

  RobotPose? _computeMapToBaseLinkTransform() {
    // List of common base frame names
    final baseFrameNames = ['base_link', 'base_footprint', 'base'];
    final mapFrameName = 'map';

    // Try direct transform first (map -> base_link)
    for (final baseName in baseFrameNames) {
      final directKey = '$mapFrameName->$baseName';
      if (_transformCache.containsKey(directKey)) {
        print('  ✅ Found direct transform: $directKey');
        return RobotPose.fromTfTransform(_transformCache[directKey]!);
      }
    }

    // Try to compute through odom (map -> odom -> base_link)
    // This is the most common transform chain in ROS navigation
    final odomFrameNames = ['odom', 'odom_combined'];

    for (final odomName in odomFrameNames) {
      final mapToOdomKey = '$mapFrameName->$odomName';

      for (final baseName in baseFrameNames) {
        final odomToBaseKey = '$odomName->$baseName';

        if (_transformCache.containsKey(mapToOdomKey) &&
            _transformCache.containsKey(odomToBaseKey)) {
          print('  ✅ Found transform chain: $mapToOdomKey + $odomToBaseKey');

          // Compose transforms: map->odom * odom->base = map->base
          return _composeTransforms(
            _transformCache[mapToOdomKey]!,
            _transformCache[odomToBaseKey]!,
          );
        }
      }
    }

    print('  ❌ No valid transform chain found');
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
    // Result = T1 * T2
    final cosYaw1 = math.cos(yaw1);
    final sinYaw1 = math.sin(yaw1);

    final resultX = x1 + cosYaw1 * x2 - sinYaw1 * y2;
    final resultY = y1 + sinYaw1 * x2 + cosYaw1 * y2;
    final resultYaw = yaw1 + yaw2;

    print('  🔗 Composed transform: ($x1, $y1, $yaw1) * ($x2, $y2, $yaw2) = ($resultX, $resultY, $resultYaw)');

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

    // Convert quaternion to yaw (rotation around Z-axis)
    final yaw = math.atan2(2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz));
    return yaw;
  }

  void _printAvailableTransforms() {
    print('\n📋 Available transforms in cache:');
    if (_transformCache.isEmpty) {
      print('   (empty)');
    } else {
      _transformCache.keys.forEach((key) => print('   - $key'));
    }
    print('');
  }

  Future<void> _handleMapSavedAck(Map<dynamic, dynamic> message) async {
    print('💾 Map saved acknowledgment: $message');
    state = message['data'].toString();
  }

  Future<void> saveMap() async {
    try {
      if (!_isInitialized) {
        state = "Service not initialized";
        return;
      }

      await _saveMapTopic?.publish({});
      print('💾 Map save request sent');
      state = "Saving map...";
    } catch (e) {
      print('❌ Error saving map: $e');
      state = "Error saving map: $e";
    }
  }

  void stopMapping() {
    try {
      _mapTopic?.unsubscribe();
      _tfTopic?.unsubscribe();
      _mapSavedAckTopic?.unsubscribe();

      _transformCache.clear();

      _ref.read(mapProvider.notifier).clearMap();
      _ref.read(robotPoseProvider.notifier).clearPose();
      _ref.read(slamConnectionProvider.notifier).reset();

      _isInitialized = false;
      state = "SLAM mapping stopped";
      print('🛑 SLAM mapping service stopped');
    } catch (e) {
      print('❌ Error stopping SLAM mapping: $e');
    }
  }

  @override
  void dispose() {
    print('🗑️  Disposing SLAM mapping service');
    stopMapping();
    super.dispose();
  }
}

final slamMappingServiceProvider = StateNotifierProvider<SlamMappingService, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final slamService = SlamMappingService(rosService, ref);
  ref.onDispose(() => slamService.dispose());
  return slamService;
});
