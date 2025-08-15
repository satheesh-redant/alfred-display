import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rosbridge/rosbridge.dart';

import '../configs/ros_constants.dart';

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

  Timer? _healthCheckTimer;
  bool _isDisposed = false;

  ROSConnectionStatus get currentStatus => _currentStatus;

  ROSService._internal() {
    print('ROSService: Initialized');
    _initializeROS();
    _startHealthCheck();
  }

  void _initializeROS({String? customUrl}) {
    final rosUrl = customUrl ?? ROSConstants.rosUrl;
    _ros = Ros(url: rosUrl);

    _ros.statusStream.listen((status) {
      final newStatus = _mapROSStatus(status);
      if (_currentStatus != newStatus && !_isDisposed) {
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
      case Status.closed:
      case Status.errored:
        return ROSConnectionStatus.error;
      default:
        return ROSConnectionStatus.disconnected;
    }
  }

  Future<void> connect() async {
    if (_isDisposed) return;

    try {
      if (_currentStatus == ROSConnectionStatus.connected) {
        return; // Already connected
      }

      if (_currentStatus == ROSConnectionStatus.connecting) {
        return; // Connection already in progress
      }

      _connectionController.add(ROSConnectionStatus.connecting);
      await _ros.connect();
    } catch (e) {
      if (!_isDisposed) {
        print('ROSService: Connection failed - $e');
        _connectionController.add(ROSConnectionStatus.error);
      }
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_isDisposed) return;

    try {
      print('ROSService: Disconnecting');
      _healthCheckTimer?.cancel();

      // Simple close - let the library handle the details
      if (_currentStatus == ROSConnectionStatus.connected) {
        await _ros.close();
      }

      _connectionController.add(ROSConnectionStatus.disconnected);
    } catch (e) {
      print('ROSService: Disconnect error - $e');
      // Force status update even if error occurs
      _connectionController.add(ROSConnectionStatus.disconnected);
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (_ros.status == false && _currentStatus == ROSConnectionStatus.connected) {
        print('ROSService: Health check failed - connection lost');
        _connectionController.add(ROSConnectionStatus.error);
      }
    });
  }

  Topic createTopic(String name, String type,
      {int queueSize = 10, int throttleRate = 0}) {
    if (_isDisposed) {
      throw StateError('ROSService has been disposed');
    }

    if (name.isEmpty || type.isEmpty) {
      throw ArgumentError('Topic name and type cannot be empty');
    }

    if (_topics.containsKey(name)) {
      return _topics[name]!;
    }

    final topic = Topic(
      ros: _ros,
      name: name,
      type: type,
      queueSize: queueSize.clamp(1, 100), // Reasonable limits
      throttleRate: throttleRate.clamp(0, 1000),
      reconnectOnClose: true,
    );

    print('ROSService: Created topic $name');
    _topics[name] = topic;
    return topic;
  }

  void subscribeToTopic(String topicName, String messageType,
      void Function(Map<String, dynamic>) callback) {
    if (_isDisposed) {
      throw StateError('ROSService has been disposed');
    }

    final topic = createTopic(topicName, messageType);

    // Cancel existing subscription if it exists
    if (_subscriptions.containsKey(topicName)) {
      _subscriptions[topicName]!.cancel();
    }

    try {
      print('ROSService: Subscribed to $topicName');
      // Subscribe to the topic
      topic.subscribe((Map<String, dynamic> message) async {
        if (!_isDisposed) {
          callback(message);
        }
      });

    } catch (e) {
      print('ROSService: Subscribe error for $topicName - $e');
      rethrow;
    }
  }

  Future<void> publishToTopic(
      String topicName, String messageType, Map<String, dynamic> data) async {
    if (_isDisposed) {
      throw StateError('ROSService has been disposed');
    }

    if (data.isEmpty) {
      throw ArgumentError('Message data cannot be empty');
    }

    if (_currentStatus != ROSConnectionStatus.connected) {
      throw StateError('ROS is not connected. Current status: $_currentStatus');
    }

    try {
      final topic = createTopic(topicName, messageType);
      await topic.publish(data);
      print('ROSService: Published to $topicName');
    } catch (e) {
      print('ROSService: Publish error for $topicName - $e');
      rethrow;
    }
  }

  void unsubscribeFromTopic(String topicName) {
    if (_subscriptions.containsKey(topicName)) {
      _subscriptions[topicName]!.cancel();
      _subscriptions.remove(topicName);
    }

    if (_topics.containsKey(topicName)) {
      try {
        print('ROSService: Unsubscribed from $topicName');
        _topics[topicName]!.unsubscribe();
        _topics.remove(topicName);
      } catch (e) {
        print('ROSService: Unsubscribe error for $topicName - $e');
      }
    }
  }

  void unsubscribeFromAllTopics() {
    print('ROSService: Unsubscribing from all topics');
    final topicNames = List<String>.from(_topics.keys);
    for (final topicName in topicNames) {
      unsubscribeFromTopic(topicName);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) return;

    print('ROSService: Disposing service');
    _isDisposed = true;

    try {
      // Stop health check timer
      _healthCheckTimer?.cancel();

      // Cancel all subscriptions
      final subscriptionFutures = _subscriptions.values
          .map((sub) => sub.cancel())
          .where((future) => future != null)
          .cast<Future>();

      if (subscriptionFutures.isNotEmpty) {
        await Future.wait(subscriptionFutures);
      }
      _subscriptions.clear();

      // Unsubscribe from all topics
      final topicFutures = _topics.values.map((topic) async {
        try {
          await topic.unsubscribe();
        } catch (e) {
          print('ROSService: Topic cleanup error - $e');
        }
      });

      await Future.wait(topicFutures);
      _topics.clear();

      // Disconnect ROS connection
      if (_currentStatus == ROSConnectionStatus.connected) {
        await _ros.close();
      }

      // Close connection controller
      await _connectionController.close();
      print('ROSService: Service disposed');

    } catch (e) {
      print('ROSService: Disposal error - $e');
    }
  }

  // Utility methods for debugging and monitoring
  Map<String, String> getActiveTopics() {
    return Map.fromEntries(
        _topics.entries.map((entry) => MapEntry(entry.key, entry.value.type))
    );
  }

  int get activeSubscriptionCount => _subscriptions.length;

  bool get isConnected => _currentStatus == ROSConnectionStatus.connected;
  bool get isConnecting => _currentStatus == ROSConnectionStatus.connecting;
  bool get hasError => _currentStatus == ROSConnectionStatus.error;
}
