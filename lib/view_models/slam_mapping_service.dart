import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';
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

  SlamMappingService(this._rosService, this._ref) : super("Initializing...") {
    print('Initializing SLAM mapping service');
    // Don't modify other providers in constructor
    // Just initialize the service state
  }

  // Separate method for initialization that can be called after provider is built
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

    } catch (e) {
      print('Error initializing SLAM mapping service: $e');
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
      print('Subscribed to /map topic');

      // Subscribe to TF updates
      await _tfTopic?.subscribe(_handleTfUpdate);
      print('Subscribed to /tf topic');

      // Subscribe to map save acknowledgment
      await _mapSavedAckTopic?.subscribe(_handleMapSavedAck);
      print('Subscribed to map saved acknowledgment');

      _ref.read(slamConnectionProvider.notifier).setSubscribed();
      state = "SLAM mapping started";

    } catch (e) {
      print('Error starting SLAM mapping: $e');
      _ref.read(slamConnectionProvider.notifier).setError(e.toString());
      state = "Error: $e";
    }
  }

  Future<void> _handleMapUpdate(Map<String, dynamic> mapMsg) async {
    try {
      print('Received map update - size: ${mapMsg['info']['width']}x${mapMsg['info']['height']}');

      final mapData = MapData.fromJson(mapMsg);
      _ref.read(mapProvider.notifier).updateMapData(mapData);
      _ref.read(slamConnectionProvider.notifier).setMapReceiving(true);

      state = "Map updated: ${mapData.width}x${mapData.height}";
    } catch (e) {
      print('Error processing map update: $e');
    }
  }

  Future<void> _handleTfUpdate(Map<String, dynamic> tfMsg) async {
    try {
      final transforms = tfMsg['transforms'] as List;

      // Look for base_link transform in map frame
      for (final transform in transforms) {
        final frameId = transform['header']['frame_id'];
        final childFrameId = transform['child_frame_id'];

        // Check if this is the base_link in map frame transform
        if (childFrameId == 'base_link' && frameId == 'map') {
          final robotPose = RobotPose.fromTfTransform(transform);
          _ref.read(robotPoseProvider.notifier).updatePose(robotPose);
          _ref.read(slamConnectionProvider.notifier).setPoseReceiving(true);
          break;
        }
      }
    } catch (e) {
      print('Error processing TF update: $e');
    }
  }

  Future<void> _handleMapSavedAck(Map<String, dynamic> message) async {
    print('Map saved acknowledgment: $message');
    state = message['data'];
  }

  Future<void> saveMap() async {
    try {
      if (!_isInitialized) {
        state = "Service not initialized";
        return;
      }

      await _saveMapTopic?.publish({});
      print('Map save request sent');
      state = "Saving map...";
    } catch (e) {
      print('Error saving map: $e');
      state = "Error saving map: $e";
    }
  }

  void stopMapping() {
    try {
      _mapTopic?.unsubscribe();
      _tfTopic?.unsubscribe();
      _mapSavedAckTopic?.unsubscribe();

      _ref.read(mapProvider.notifier).clearMap();
      _ref.read(robotPoseProvider.notifier).clearPose();
      _ref.read(slamConnectionProvider.notifier).reset();

      _isInitialized = false;
      state = "SLAM mapping stopped";
      print('SLAM mapping service stopped');
    } catch (e) {
      print('Error stopping SLAM mapping: $e');
    }
  }

  @override
  void dispose() {
    print('Disposing SLAM mapping service');
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
