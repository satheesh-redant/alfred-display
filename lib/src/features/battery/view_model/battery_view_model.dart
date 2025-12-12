
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/battery_model.dart';
import 'dart:async';
import '../../../core/configs/ros_constants.dart';
import '../../../core/services/ros_service.dart';
import 'package:rosbridge/rosbridge.dart';

class BatteryViewModel extends StateNotifier<AsyncValue<BatteryState>> {
  final ROSService _batteryService;
  StreamSubscription<BatteryState>? _subscription;

  // MERGED FROM BatteryService
  Topic? _batteryTopic;
  StreamController<BatteryState>? _batteryController;

  BatteryViewModel(this._batteryService) : super(const AsyncValue.loading()) {
    print('initiating battery topics');

    // EXACT COPY FROM BatteryService constructor
    _batteryController = StreamController<BatteryState>.broadcast();

    _batteryTopic = _batteryService.createTopic(
      ROSConstants.topicBattery,
      ROSConstants.batteryTopicType,
      queueSize: 1,
      throttleRate: 1000,
    );

    // ORIGINAL VIEWMODEL LOGIC
    _initialize();

    // BATTERY SERVICE LOGIC
    initializeBattery();
  }

  // -------------------------------
  // ORIGINAL VIEW MODEL _initialize
  // -------------------------------
  void _initialize() {
    _subscription = _batteryController!.stream.listen(
          (batteryState) {
        state = AsyncValue.data(batteryState);
      },
      onError: (error, stackTrace) {
        print('Battery stream error: $error');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  // -------------------------------
  // MERGED FROM BatteryService
  // -------------------------------
  void initializeBattery() {
    try {
      _batteryTopic!.subscribe(_handlerBatteryState);
      print('Battery topic subscribed successfully');
    } catch (e) {
      print('Error initializing battery topic: $e');
    }
  }

  // EXACT COPY
  Future<void> _handlerBatteryState(Map<String, dynamic> message) async {
    try {
      final batteryState = BatteryState.fromJson(message);
      _batteryController?.add(batteryState);
    } catch (e) {
      print('Error parsing battery message: $e');
    }
  }

  // EXACT COPY
  void _cleanup() {
    _batteryTopic?.unsubscribe();
    _batteryTopic = null;
  }

  // -------------------------------
  // ORIGINAL COMPUTED PROPERTIES
  // -------------------------------
  bool get isCharging => state.value?.statusEnum == BatteryStatus.charging;

  bool get isCritical => (state.value?.percentage ?? 0) < 0.02;

  bool get isCriticalLow => (state.value?.percentage ?? 0) < 0.10;

  bool get isLow => (state.value?.percentage ?? 0) < 0.20;

  bool get hasHealthIssue => state.value?.healthEnum != BatteryHealth.good;

  int? get estimatedMinutesLeft {
    final battery = state.value;
    if (battery == null || battery.current == null || battery.charge == null) {
      return null;
    }

    if (battery.statusEnum == BatteryStatus.charging) {
      return _calculateChargingTime(battery);
    }

    if (battery.current! < 0) {
      final currentAbs = battery.current!.abs();
      if (currentAbs > 0) {
        final hoursLeft = battery.charge! / currentAbs;
        return (hoursLeft * 60).toInt();
      }
    }

    return null;
  }

  int? _calculateChargingTime(BatteryState battery) {
    if (battery.capacity == null ||
        battery.charge == null ||
        battery.current == null) {
      return null;
    }

    final remainingCapacity = battery.capacity! - battery.charge!;
    if (battery.current! > 0) {
      final hoursToFull = remainingCapacity / battery.current!;
      return (hoursToFull * 60).toInt();
    }

    return null;
  }

  DateTime? get estimatedFullChargeTime {
    final minutes = estimatedMinutesLeft;
    if (minutes == null || !isCharging) return null;
    return DateTime.now().add(Duration(minutes: minutes));
  }

  @override
  void dispose() {
    _subscription?.cancel();

    // MERGED cleanup
    _cleanup();
    _batteryController?.close();

    super.dispose();
    // END
  }
}
