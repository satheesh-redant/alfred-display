//retry
import 'dart:async';
import 'package:alfred/src/features/battery/model/battery_model.dart';
import 'package:flutter/material.dart';
import 'package:rosbridge/rosbridge.dart';
import 'package:rxdart/rxdart.dart';

import '../../features/loading/model/operation_mode.dart';
import '../configs/ros_constants.dart';

enum ROSConnectionStatus { disconnected, connecting, connected, error }

class ROSService {
  static final ROSService _instance = ROSService._internal();

  factory ROSService() => _instance;

  late final Ros _ros;
  final Map<String, Topic> _topics = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  final BehaviorSubject<ROSConnectionStatus> _connectionController =
      BehaviorSubject<ROSConnectionStatus>();

  // loading
  final StreamController<String> _bootCheckController =
      StreamController<String>.broadcast();
  final StreamController<OperationMode> _opsModeController =
      StreamController<OperationMode>.broadcast();

  // base reset
  final StreamController<String> _baseResetStatusController =
      StreamController<String>.broadcast();

  final StreamController<String> _baseReturnStatusController =
      StreamController<String>.broadcast();

  // delivery
  final StreamController<String> _deliveryStatusController =
      StreamController<String>.broadcast();
  final StreamController<List<int>> _tableListController =
      StreamController<List<int>>.broadcast();

  // power off ack
  final StreamController<String> _powerOffAckController =
      StreamController<String>.broadcast();

  //battery
  final StreamController<BatteryData> _batteryController =
      StreamController<BatteryData>.broadcast();

  Stream<ROSConnectionStatus> get connectionStream =>
      _connectionController.stream;

  Stream<String> get bootCheckStream => _bootCheckController.stream;

  Stream<OperationMode> get opsModeStream => _opsModeController.stream;

  Stream<String> get deliveryStatusStream => _deliveryStatusController.stream;

  Stream<List<int>> get tableListStream => _tableListController.stream;

  Stream<String> get baseResetStatusStream => _baseResetStatusController.stream;

  Stream<String> get returnToBaseStatusStream =>
      _baseReturnStatusController.stream;

  Stream<String> get powerOffAckStream => _powerOffAckController.stream;

  Stream<BatteryData> get batteryRawStream => _batteryController.stream;

  ROSConnectionStatus _currentStatus = ROSConnectionStatus.disconnected;

  Timer? _healthCheckTimer;

  //  added retry timer
  Timer? _retryTimer;
  static const Duration _retryInterval = Duration(seconds: 10);

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

        if (newStatus == ROSConnectionStatus.connected) {
          _stopRetryTimer(); // ⭐ stop retry when connected
          _initializeBootAndOpsSubscriptions();
        } else if (newStatus == ROSConnectionStatus.error ||
            newStatus == ROSConnectionStatus.disconnected) {
          _startRetryTimer(); // ⭐ start retry on failure
        }
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
      if (_currentStatus == ROSConnectionStatus.connected) return;
      if (_currentStatus == ROSConnectionStatus.connecting) return;

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

  // ⭐ retry logic added
  void _startRetryTimer() {
    _stopRetryTimer();
    print(
        "ROSService: Retrying connection in ${_retryInterval.inSeconds} seconds...");
    _retryTimer = Timer.periodic(_retryInterval, (_) => _attemptReconnect());
  }

  void _stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _attemptReconnect() async {
    if (_currentStatus == ROSConnectionStatus.connected ||
        _currentStatus == ROSConnectionStatus.connecting) return;

    print("ROSService: Attempting reconnect...");
    await connect();
  }

  // ⭐ retry logic end

  void _initializeBootAndOpsSubscriptions() {
    print("ROSService: Initializing topic subscriptions...");

    subscribeToTopic(ROSConstants.topicBootCheck, ROSConstants.msgString,
        (msg) {
      try {
        final data = msg['data'] as String;
        _bootCheckController.add(data);
      } catch (e) {
        print("Boot parse error: $e");
      }
    });

    subscribeToTopic(ROSConstants.topicMode, ROSConstants.msgString, (msg) {
      final m = msg["data"]?.toString().toLowerCase() ?? "";
      final mode = m == "mapping"
          ? OperationMode.mapping
          : m == "routing"
              ? OperationMode.routing
              : m == "navigation"
                  ? OperationMode.navigation
                  : OperationMode.unknown;
      _opsModeController.add(mode);
    });

    subscribeToTopic(ROSConstants.topicDeliveryStatus, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        print('Delivery status received: $status');
        _deliveryStatusController.add(status);
      } catch (e) {
        _deliveryStatusController.addError("Failed to parse: $e");
      }
    });

    subscribeToTopic(ROSConstants.topicTablesList, ROSConstants.msgString,
        (msg) {
      try {
        final data = msg['data'] as String? ?? '';
        print('Table list received: $data');
        final numbers = data
            .split(',')
            .where((s) => s.isNotEmpty)
            .map((s) => int.tryParse(s.trim()))
            .where((n) => n != null)
            .cast<int>()
            .toList();

        _tableListController.add(numbers);
      } catch (e) {
        _tableListController.addError("Failed to parse: $e");
      }
    });

    // RESET BASE ACK
    subscribeToTopic(ROSConstants.topicResetBaseLocAck, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        //  print("Reset Base ACK received → $status");
        _baseResetStatusController.add(status);
      } catch (e) {
        print("Reset Base ACK parse error: $e");
      }
    });

    subscribeToTopic(ROSConstants.topicReturnToBaseAck, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        //  print("Reset Base ACK received → $status");
        _baseReturnStatusController.add(status);
      } catch (e) {
        print("Reset Base ACK parse error: $e");
      }
    });

    // POWER_OFF_ACK
    subscribeToTopic(ROSConstants.topicPowerOffAck, ROSConstants.msgString,
        (msg) {
      final ack = msg['data'] ?? '';
      print("Power Off ACK received → $ack");
      _powerOffAckController.add(ack);
    });

    subscribeToTopic(ROSConstants.topicBattery, ROSConstants.msgString, (msg) {
      final batteryState = BatteryData.fromJson(msg);
      _batteryController.add(batteryState);
    });
  }

  Future<void> requestTableList() async {
    print('Requesting table list...');
    await publishToTopic(
        ROSConstants.topicGetTables, ROSConstants.emptyMessageType, {});
  }

  Future<void> gotoPoint(int tableNumber, int route) async {
    final data = {'data': '$tableNumber:$route'};
    print('Publishing table number: $data');
    await publishToTopic(
        ROSConstants.topicMoveTable, ROSConstants.stringMessageType, data);
  }

  Future<void> resetBaseLocation() async {
    final data = {"data": "Base"};
    print("Publishing /reset_base_loc: $data");
    await publishToTopic(
        ROSConstants.topicResetBaseLoc, ROSConstants.msgString, data);
  }

  Future<void> sendPowerOffCommand() async {
    await publishToTopic(
        ROSConstants.topicPowerOff, ROSConstants.msgString, {'data': 'OFF'});
  }

  Future<void> disconnect() async {
    if (_isDisposed) return;
    try {
      print('ROSService: Disconnecting');
      _healthCheckTimer?.cancel();
      _stopRetryTimer(); // ⭐ stop retry
      if (_currentStatus == ROSConnectionStatus.connected) {
        await _ros.close();
      }
      _connectionController.add(ROSConnectionStatus.disconnected);
    } catch (e) {
      _connectionController.add(ROSConnectionStatus.disconnected);
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (_ros.status == false &&
          _currentStatus == ROSConnectionStatus.connected) {
        print('ROSService: Health check failed - connection lost');
        _connectionController.add(ROSConnectionStatus.error);
      }
    });
  }

  Topic createTopic(String name, String type,
      {int queueSize = 10, int throttleRate = 0}) {
    if (_isDisposed) throw StateError('ROSService has been disposed');
    if (_topics.containsKey(name)) return _topics[name]!;
    final topic = Topic(
      ros: _ros,
      name: name,
      type: type,
      queueSize: queueSize.clamp(1, 100),
      throttleRate: throttleRate.clamp(0, 1000),
      reconnectOnClose: true,
    );
    _topics[name] = topic;
    return topic;
  }

  void subscribeToTopic(String topicName, String messageType,
      void Function(Map<String, dynamic>) callback) {
    if (_isDisposed) throw StateError('ROSService has been disposed');
    final topic = createTopic(topicName, messageType);
    if (_subscriptions.containsKey(topicName)) {
      _subscriptions[topicName]!.cancel();
    }
    topic.subscribe((Map<String, dynamic> message) async {
      if (!_isDisposed) callback(message);
    });
  }

  Future<void> publishToTopic(
      String topicName, String messageType, Map<String, dynamic> data) async {
    if (_isDisposed) throw StateError('ROSService has been disposed');
    if (data.isEmpty) throw ArgumentError('Message data cannot be empty');
    if (_currentStatus != ROSConnectionStatus.connected) {
      throw StateError('ROS is not connected');
    }
    final topic = createTopic(topicName, messageType);
    await topic.publish(data);
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _stopRetryTimer(); // ⭐ cancel retry
    _healthCheckTimer?.cancel();

    for (final topic in _topics.values) {
      try {
        await topic.unsubscribe();
      } catch (_) {}
    }
    _topics.clear();

    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();

    if (_currentStatus == ROSConnectionStatus.connected) {
      await _ros.close();
    }

    await _connectionController.close();
    await _bootCheckController.close();
    await _opsModeController.close();
    await _baseResetStatusController.close();
    await _baseReturnStatusController.close();
    await _deliveryStatusController.close();
    await _powerOffAckController.close();
    await _tableListController.close();
  }

  bool get isConnected => _currentStatus == ROSConnectionStatus.connected;

  bool get isConnecting => _currentStatus == ROSConnectionStatus.connecting;

  bool get hasError => _currentStatus == ROSConnectionStatus.error;
}
