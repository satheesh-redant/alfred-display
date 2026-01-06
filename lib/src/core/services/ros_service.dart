import 'dart:async';
import 'package:alfred/src/features/battery/model/battery_model.dart';
import 'package:rosbridge/rosbridge.dart';
import 'package:rxdart/rxdart.dart';

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

  Stream<ROSConnectionStatus> get connectionStream =>
      _connectionController.stream;

  // loading
  final StreamController<String> _bootCheckController =
      StreamController<String>.broadcast();

  Stream<String> get bootCheckStream => _bootCheckController.stream;

  final StreamController<String> _modeController =
      StreamController<String>.broadcast();

  Stream<String> get modeStream => _modeController.stream;

  // base reset
  final StreamController<String> _baseResetStatusController =
      StreamController<String>.broadcast();

  Stream<String> get baseResetStatusStream => _baseResetStatusController.stream;

  final StreamController<String> _baseReturnStatusController =
      StreamController<String>.broadcast();

  Stream<String> get returnToBaseStatusStream =>
      _baseReturnStatusController.stream;

  // delivery
  final StreamController<String> _deliveryStatusController =
      StreamController<String>.broadcast();

  Stream<String> get deliveryStatusStream => _deliveryStatusController.stream;

  final StreamController<List<int>> _tableListController =
      StreamController<List<int>>.broadcast();

  Stream<List<int>> get tableListStream => _tableListController.stream;

  // power off ack
  final StreamController<String> _powerOffAckController =
      StreamController<String>.broadcast();

  Stream<String> get powerOffAckStream => _powerOffAckController.stream;

  //battery
  final StreamController<BatteryData> _batteryController =
      StreamController<BatteryData>.broadcast();

  Stream<BatteryData> get batteryRawStream => _batteryController.stream;

  ROSConnectionStatus _currentStatus = ROSConnectionStatus.disconnected;

  ROSConnectionStatus get currentStatus => _currentStatus;

  final StreamController<String> _routingAckController =
      StreamController<String>.broadcast();

  Stream<String> get routingAckStream => _routingAckController.stream;

  //  added retry timer
  Timer? _retryTimer;
  static const Duration _retryInterval = Duration(seconds: 10);

  bool _isDisposed = false;

  ROSService._internal() {
    print('ROSService: Initialized');
    _initializeROS();
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
          _stopRetryTimer();
          _initializeSubscriptions();
        } else if (newStatus == ROSConnectionStatus.error ||
            newStatus == ROSConnectionStatus.disconnected) {
          _startRetryTimer();
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

  void _initializeSubscriptions() {
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
      final data = msg['data'] as String? ?? '';
      _modeController.add(data);
    });

    subscribeToTopic(ROSConstants.topicDeliveryStatus, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        print('Delivery status received: $status');
        _deliveryStatusController.add(status);
      } catch (e) {
        print("Delivery status parse error: $e");
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
        print("Table list parse error: $e");
      }
    });

    // RESET BASE ACK
    subscribeToTopic(ROSConstants.topicResetBaseLocAck, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        _baseResetStatusController.add(status);
      } catch (e) {
        print("Reset Base ACK parse error: $e");
      }
    });

    subscribeToTopic(ROSConstants.topicReturnToBaseAck, ROSConstants.msgString,
        (msg) {
      try {
        final status = msg['data'] as String? ?? '';
        _baseReturnStatusController.add(status);
      } catch (e) {
        print("Reset Base ACK parse error: $e");
      }
    });

    // POWER_OFF_ACK
    subscribeToTopic(ROSConstants.topicPowerOffAck, ROSConstants.msgString,
        (msg) {
      final ack = msg['data'] ?? '';
      _powerOffAckController.add(ack);
    });

    subscribeToTopic(ROSConstants.topicBattery, ROSConstants.msgString, (msg) {
      final data = msg['data'] ?? '';
      final batteryState = BatteryData.fromJson(data);
      _batteryController.add(batteryState);
    });

    subscribeToTopic(ROSConstants.topicRouteAck, ROSConstants.msgString, (msg) {
      final data = msg['data'] ?? '';
      _routingAckController.add(data);
    });
  }

  Future<void> requestModeChange(String mode) async {
    final data = {'data': '$mode'};
    print('Requesting mode change: $data');
    await publishToTopic(
        ROSConstants.topicModeRequested, ROSConstants.msgString, data);
  }

  Future<void> requestTableList() async {
    print('Requesting table list...');
    await publishToTopic(
        ROSConstants.topicGetTables, ROSConstants.msgEmpty, {});
  }

  Future<void> gotoPoint(int tableNumber) async {
    final data = {'data': tableNumber};
    print('Publishing table number: $data');
    await publishToTopic(
        ROSConstants.topicMoveTable, ROSConstants.msgInteger, data);
  }

  Future<void> resetBaseLocation() async {
    final data = {"data": "Base"};
    print("Publishing /reset_base_loc: $data");
    await publishToTopic(
        ROSConstants.topicResetBaseLoc, ROSConstants.msgString, data);
  }

  Future<void> sendPowerOffCommand() async {
    final data = {"data": "OFF"};
    print("Publishing power off command: $data");
    await publishToTopic(
        ROSConstants.topicPowerOff, ROSConstants.msgString, data);
  }

  Future<void> sendWaypoint({required String data}) async {

    Map<String, dynamic> json = {"data": data};
    print('Publishing route data: $json');

    await publishToTopic(
        ROSConstants.topicRoute, ROSConstants.msgString, json);
  }

  Future<void> disconnect() async {
    if (_isDisposed) return;
    try {
      print('ROSService: Disconnecting');
      _stopRetryTimer(); // ⭐ stop retry
      if (_currentStatus == ROSConnectionStatus.connected) {
        await _ros.close();
      }
      _connectionController.add(ROSConnectionStatus.disconnected);
    } catch (e) {
      _connectionController.add(ROSConnectionStatus.disconnected);
    }
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
    // if (data.isEmpty) throw ArgumentError('Message data cannot be empty');
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
    await _modeController.close();
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
