import 'dart:async';
import 'package:alfred/models/battery_state.dart';
import 'package:alfred/services/ros_service.dart';
import 'package:alfred/config/ros_constants.dart';
import 'package:rosbridge/rosbridge.dart';

class BatteryService {
  final ROSService _rosService;
  Topic? _batteryTopic;
  StreamController<BatteryState>? _batteryController;

  BatteryService(this._rosService) {
    print('initiating battery topics');
    _batteryController = StreamController<BatteryState>.broadcast();

    // Create the battery topic
    _batteryTopic = _rosService.createTopic(
      ROSConstants.batteryTopicName,
      ROSConstants.batteryTopicType,
      queueSize: 1,
      throttleRate: 1000,
    );
  }

  Stream<BatteryState> get batteryStream {
    return _batteryController?.stream ?? Stream.empty();
  }

  void initializeBattery() {
    try {
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

  void dispose() {
    _cleanup();
    _batteryController?.close();
  }
}
