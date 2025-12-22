import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../states/loading_screen_state.dart';
import '../view_model/loading_screen_view_model.dart';

final loadingScreenViewModelProvider = StateNotifierProvider.autoDispose<
    LoadingScreenViewModel, LoadingScreenState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final vm = LoadingScreenViewModel(rosService);
  ref.onDispose(vm.dispose);
  return vm;
});
