import 'package:alfred/src/core/providers/core_providers.dart';
import 'package:alfred/src/shared/states/system_state.dart';
import 'package:alfred/src/shared/view_models/system_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final systemViewModelProvider =
    StateNotifierProvider<SystemViewModel, SystemState>((ref) {
  final ros = ref.watch(rosServiceProvider);
  final vm = SystemViewModel(ros);
  ref.onDispose(vm.dispose);
  return vm;
});
