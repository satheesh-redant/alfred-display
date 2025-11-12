import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alfred/models/battery_state.dart';
import 'package:alfred/services/battery_service.dart';
import 'package:alfred/services/ros_service.dart';
import 'dart:async';

class BatteryViewModel extends StateNotifier<AsyncValue<BatteryState>> {
  final BatteryService _batteryService;
  StreamSubscription<BatteryState>? _subscription;

  BatteryViewModel(this._batteryService) : super(const AsyncValue.loading()) {
    _initialize();
  }

  void _initialize() {
    _subscription = _batteryService.batteryStream.listen(
      (batteryState) {
        state = AsyncValue.data(batteryState);
      },
      onError: (error, stackTrace) {
        print('Battery stream error: $error');
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  // Computed properties for UI
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
    super.dispose();
  }
}

// Providers
final batteryServiceProvider = Provider<BatteryService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final batteryService = BatteryService(rosService);
  ref.onDispose(() => batteryService.dispose());
  return batteryService;
});

final batteryViewModelProvider =
    StateNotifierProvider<BatteryViewModel, AsyncValue<BatteryState>>((ref) {
  final service = ref.watch(batteryServiceProvider);
  return BatteryViewModel(service);
});

// Computed providers
final isChargingProvider = Provider<bool>((ref) {
  return ref.watch(batteryViewModelProvider).value?.statusEnum ==
      BatteryStatus.charging;
});

final batteryPercentageProvider = Provider<double>((ref) {
  return (ref.watch(batteryViewModelProvider).value?.percentage ?? 0) * 100;
});

final batteryLevelCategoryProvider = Provider<BatteryLevelCategory>((ref) {
  final percentage = ref.watch(batteryPercentageProvider);

  if (percentage < 2) return BatteryLevelCategory.shutdown;
  if (percentage < 10) return BatteryLevelCategory.criticalLow;
  if (percentage < 20) return BatteryLevelCategory.low;
  if (percentage < 60) return BatteryLevelCategory.moderate;
  return BatteryLevelCategory.healthy;
});

enum BatteryLevelCategory {
  shutdown,
  criticalLow,
  low,
  moderate,
  healthy,
}
