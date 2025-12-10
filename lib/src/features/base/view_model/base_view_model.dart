import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ros_service.dart';
import '../model/base_model.dart';
import '../providers/base_provider.dart';
import '../state/base_state.dart'; // <-- added import for state model

class BasePointViewModel extends StateNotifier<BasePointState> {
  final ROSService _rosService;
  StreamSubscription? _resetAckSubscription;

  BasePointViewModel(this._rosService)
      : super(BasePointState.initial()) { // <-- initial model
    _listenToResetAck();
  }

  void _listenToResetAck() {
    _resetAckSubscription = _rosService.baseResetStatusStream.listen((msg) {
   // print("Base reset ACK received: $msg");

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
  void dispose() {
    print('Disposing BasePointViewModel');
    _resetAckSubscription?.cancel();
    super.dispose();
  }
}

final basePointVMProvider =
StateNotifierProvider<BasePointViewModel, BasePointState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final vm = BasePointViewModel(rosService);
  ref.onDispose(() => vm.dispose());
  return vm;
});
