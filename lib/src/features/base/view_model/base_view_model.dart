import 'dart:async';
import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/services/ros_service.dart';
import '../model/base_model.dart';
import '../providers/base_provider.dart';
import '../state/base_state.dart';

class BasePointViewModel extends BaseViewModel<BasePointState> {
  final ROSService _rosService;
  StreamSubscription? _resetAckSubscription;

  BasePointViewModel(this._rosService) : super(BasePointState.initial()) {
    _listenToResetAck();
  }

  void _listenToResetAck() {
    _resetAckSubscription = _rosService.baseResetStatusStream.listen((msg) {
      state = state.copyWith(
        isResetting: false,
        isResetComplete: true,
        message: msg,
      );
    });
  }

  Future<void> resetBaseLoc() async {
    print("Triggering reset base...");

    state = state.copyWith(
      isResetting: true,
      isResetComplete: false,
      message: "Resetting base...",
    );

    await _rosService.resetBaseLocation();
  }

  @override
  void onDispose() {
    print('Disposing BasePointViewModel');
    _resetAckSubscription?.cancel();
    super.onDispose();
  }
}

final basePointVMProvider =
    StateNotifierProvider<BasePointViewModel, BasePointState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final vm = BasePointViewModel(rosService);
  ref.onDispose(() => vm.dispose());
  return vm;
});
