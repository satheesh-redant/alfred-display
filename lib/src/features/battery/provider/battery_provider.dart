import 'package:alfred/src/features/battery/view_model/battery_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../model/battery_model.dart';

final batteryViewModelProvider =
StateNotifierProvider<BatteryViewModel, AsyncValue<BatteryState>>((ref) {
  final service = ref.watch(rosServiceProvider);
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
