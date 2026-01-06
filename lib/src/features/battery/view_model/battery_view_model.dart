import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/battery_model.dart';
import 'dart:async';
import '../../../core/services/ros_service.dart';

import '../states/battery_state.dart';

class BatteryViewModel extends BaseViewModel<AsyncValue<BatteryState>> {
  final ROSService _rosService;

  StreamSubscription? _batteryStreamSubscription;

  BatteryViewModel(this._rosService) : super(const AsyncValue.loading()) {
    print('initiating battery topics');
    _initialize();
  }

  void _initialize() async {
    _batteryStreamSubscription = _rosService.batteryRawStream.listen(
      (batteryState) {
        final prevValue = state.asData!.value;
        state = AsyncValue.data(prevValue.copyWith(batteryData: batteryState));
      },
      onError: (error, stackTrace) {
        print('Battery stream error: $error');
        state = AsyncValue.error(error, stackTrace);
      },
    );

    state = await AsyncValue.guard(() async {
      return BatteryState();
    });
  }

  // -------------------------------
  // ORIGINAL COMPUTED PROPERTIES
  // -------------------------------
  bool get isCharging =>
      state.value?.batteryData?.statusEnum == BatteryChargingStatus.charging;

  bool get isCritical => (state.value?.batteryData?.percentage ?? 0) < 0.02;

  bool get isCriticalLow => (state.value?.batteryData?.percentage ?? 0) < 0.10;

  bool get isLow => (state.value?.batteryData?.percentage ?? 0) < 0.20;

  bool get hasHealthIssue =>
      state.value?.batteryData?.healthEnum != BatteryHealth.good;

  int? get estimatedMinutesLeft {
    final battery = state.value;
    if (battery == null ||
        battery.batteryData?.current == null ||
        battery.batteryData?.charge == null) {
      return null;
    }

    if (battery.batteryData?.statusEnum == BatteryChargingStatus.charging) {
      return _calculateChargingTime(battery);
    }

    if (battery.batteryData!.current! < 0) {
      final currentAbs = battery.batteryData!.current!.abs();
      if (currentAbs > 0) {
        final hoursLeft = battery.batteryData!.charge! / currentAbs;
        return (hoursLeft * 60).toInt();
      }
    }

    return null;
  }

  int? _calculateChargingTime(BatteryState battery) {
    if (battery.batteryData?.capacity == null ||
        battery.batteryData?.charge == null ||
        battery.batteryData?.current == null) {
      return null;
    }

    final remainingCapacity =
        battery.batteryData!.capacity! - battery.batteryData!.charge!;
    if (battery.batteryData!.current! > 0) {
      final hoursToFull = remainingCapacity / battery.batteryData!.current!;
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
  void onDispose() {
    _batteryStreamSubscription?.cancel();
    super.onDispose();
  }
}
