import 'dart:async';
import 'package:rosbridge/rosbridge.dart';

import '../../../config/ros_constants.dart';

enum ROSConnectionStatus { disconnected, connecting, connected, error }

class ROSService {
  static final ROSService _instance = ROSService._internal();

  factory ROSService() => _instance;

  late final Ros _ros;
  final Map<String, Topic> _topics = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  final StreamController<ROSConnectionStatus> _connectionController =
      StreamController<ROSConnectionStatus>.broadcast();

  Stream<ROSConnectionStatus> get connectionStream =>
      _connectionController.stream;
  ROSConnectionStatus _currentStatus = ROSConnectionStatus.disconnected;

  ROSService._internal() {
    _initializeROS();
  }

  void _initializeROS() {
    _ros = Ros(url: ROSConstants.rosUrl);

    _ros.statusStream.listen((status) {
      final newStatus = _mapROSStatus(status);
      if (_currentStatus != newStatus) {
        _currentStatus = newStatus;
        _connectionController.add(newStatus);
      }
    });
  }

  ROSConnectionStatus _mapROSStatus(Status status) {
    switch (status) {
      case Status.connected:
        return ROSConnectionStatus.connected;
      case Status.connecting:
        return ROSConnectionStatus.connecting;
      default:
        return ROSConnectionStatus.disconnected;
    }
  }

  Future<void> connect() async {
    try {
      _connectionController.add(ROSConnectionStatus.connecting);
      await _ros.connect();
    } catch (e) {
      _connectionController.add(ROSConnectionStatus.error);
      rethrow;
    }
  }

  Topic createTopic(String name, String type,
      {int queueSize = 10, int throttleRate = 0}) {
    if (_topics.containsKey(name)) {
      return _topics[name]!;
    }

    final topic = Topic(
      ros: _ros,
      name: name,
      type: type,
      queueSize: queueSize,
      throttleRate: throttleRate,
      reconnectOnClose: false,
    );

    _topics[name] = topic;
    return topic;
  }

  void subscribeToTopic(String topicName, String messageType, void Function(Map<String, dynamic>) callback) {
    final topic = createTopic(topicName, messageType);

    // Use the proper subscribe method with typed callback
    topic.subscribe((Map<String, dynamic> message) async {
      callback(message);
    });
  }

  Future<void> publishToTopic(
      String topicName, String messageType, Map data) async {
    final topic = createTopic(topicName, messageType);
    await topic.publish(data);
  }

  void unsubscribeFromTopic(String topicName) {
    if (_subscriptions.containsKey(topicName)) {
      _subscriptions[topicName]!.cancel();
      _subscriptions.remove(topicName);
    }

    if (_topics.containsKey(topicName)) {
      _topics[topicName]!.unsubscribe();
      _topics.remove(topicName);
    }
  }

  void dispose() {
    _subscriptions.values.forEach((sub) => sub.cancel());
    _subscriptions.clear();
    _topics.values.forEach((topic) => topic.unsubscribe());
    _topics.clear();
    _connectionController.close();
  }
}
