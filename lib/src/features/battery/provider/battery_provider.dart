import 'package:alfred/src/features/battery/view_model/battery_view_model.dart';
import 'package:alfred/src/features/loading/model/operation_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../loading/providers/loading_providers.dart';
import '../model/battery_model.dart';
import '../states/battery_state.dart';

final batteryViewModelProvider =
StateNotifierProvider<BatteryViewModel, AsyncValue<BatteryState>>((ref) {
  final service = ref.watch(rosServiceProvider);
  return BatteryViewModel(service);
});

final modeProvider = Provider<OperationMode>((ref) {
  return ref.watch(batteryViewModelProvider).value?.mode ?? OperationMode.unknown;
});

final batteryPercentageProvider = Provider<double>((ref) {
  return (ref.watch(batteryViewModelProvider).value?.batteryData?.percentage ?? -1) * 100; //must be -1 when no battery data
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
