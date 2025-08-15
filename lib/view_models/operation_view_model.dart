import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';

import '../src/core/configs/ros_constants.dart';
import '../src/core/providers/core_providers.dart';
import '../src/core/services/ros_service.dart';

class OperationViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicCurrentMode;

  OperationViewModel(this._rosService) : super("");

  void init() {
    print('initiating all ops mode topics');
    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode,
      ROSConstants.msgString,
      throttleRate: 500,
    );
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print('Current ops mode: $message');
    state = message['data'];
  }

  Future<void> sendOpsMode({required String mode}) async {
    Map<String, dynamic> json = {"data": mode};
    print('Publishing ops mode: $json');
    await _topicCurrentMode!.publish(json);
  }

  @override
  void dispose() {
    print('Disposing all ops mode topics');
    _topicCurrentMode!.unsubscribe();
    state = "";
  }
}

final opsVMProvider = StateNotifierProvider<OperationViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final opsVM = OperationViewModel(rosService);
  ref.onDispose(() => opsVM.dispose());
  return opsVM;
});
