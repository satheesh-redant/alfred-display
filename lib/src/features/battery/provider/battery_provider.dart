// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/providers/core_providers.dart';
// import '../view_model/battery_view_model.dart';
// import '../model/battery_model.dart';
//
//
// final batteryVMProvider =
// StateNotifierProvider<BatteryViewModel, BatteryStatus>((ref) {
//   final rosService = ref.watch(rosServiceProvider);
//   final batteryVM = BatteryViewModel(rosService);
//   ref.onDispose(() => batteryVM.dispose());
//   return batteryVM;
// });
