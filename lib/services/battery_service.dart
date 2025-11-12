import 'dart:async';
import 'package:alfred/models/battery_state.dart';
import 'package:alfred/services/ros_service.dart';
import 'package:alfred/config/ros_constants.dart';
import 'package:rosbridge/rosbridge.dart';

class BatteryService {
  final ROSService _rosService;
  Topic? _batteryTopic;
  StreamController<BatteryState>? _batteryController;
  StreamSubscription? _rosStatusSubscription;
  bool _isInitialized = false;

  BatteryService(this._rosService) {
    _batteryController = StreamController<BatteryState>.broadcast();
    _listenToRosConnection();
  }

  void _listenToRosConnection() {
    // Wait for ROS to be connected before subscribing to topics
    _rosStatusSubscription = _rosService.ros.statusStream.listen((status) {
      if (status == Status.connected && !_isInitialized) {
        print('ROS connected, initializing battery topic...');
        _initializeTopic();
        _isInitialized = true;
      } else if (status != Status.connected && _isInitialized) {
        print('ROS disconnected, cleaning up battery topic...');
        _cleanup();
        _isInitialized = false;
      }
    });
  }

  void _initializeTopic() {
    try {
      // Create the battery topic
      _batteryTopic = _rosService.createTopic(
        ROSConstants.batteryTopicName,
        ROSConstants.batteryTopicType,
        queueSize: 1,
        throttleRate: 1000,
      );

      // Subscribe to the topic
      _batteryTopic!.subscribe(_handlerBatteryState);

      print('Battery topic subscribed successfully');
    } catch (e) {
      print('Error initializing battery topic: $e');
    }
  }

  Future<void> _handlerBatteryState(Map<String, dynamic> message) async {
    try {
      // Parse the ROS message to BatteryState
      final batteryState = BatteryState.fromJson(message);
      _batteryController?.add(batteryState);
    } catch (e) {
      print('Error parsing battery message: $e');
    }
  }

  void _cleanup() {
    _batteryTopic?.unsubscribe();
    _batteryTopic = null;
  }

  Stream<BatteryState> get batteryStream {
    return _batteryController?.stream ?? Stream.empty();
  }

  void dispose() {
    _cleanup();
    _rosStatusSubscription?.cancel();
    _batteryController?.close();
  }
}
