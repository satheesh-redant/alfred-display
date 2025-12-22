import 'package:alfred/src/features/delivery/state/delivery_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../view_model/delivery_view_model.dart';

final deliveryViewModelProvider =
    StateNotifierProvider<DeliveryViewModel, DeliveryState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  DeliveryViewModel vm = DeliveryViewModel(rosService);
  ref.onDispose(vm.dispose);
  return vm;
});
