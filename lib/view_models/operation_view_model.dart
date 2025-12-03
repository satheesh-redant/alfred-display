import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';
import 'package:rosbridge/rosbridge.dart';

class OperationViewModel extends StateNotifier<AsyncValue<String>> {
  final ROSService _rosService;
  Topic? _topicCurrentMode, _topicSetMode;

  OperationViewModel(this._rosService) : super(const AsyncValue.loading()) {
    print('initiating ops mode topics');

    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicCurrentMode,
      ROSConstants.msgString,
      throttleRate: 1000,
    );

    _topicSetMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode,
      ROSConstants.msgString,
    );
  }

  Future<void> getCurrentMode() async {
    print('initiating /mode topic');
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    state = AsyncValue.data(message['data']);
  }

  Future<void> sendOpsMode({required String mode}) async {
    Map<String, dynamic> json = {"data": mode};
    print('Publishing ops mode: $json');
    await _topicSetMode!.publish(json);
  }

  void unsubscribe() {
    _topicCurrentMode?.unsubscribe();
    _topicCurrentMode = null;
  }

  @override
  void dispose() {
    print('Disposing all ops mode topics');
  }
}

final opsVMProvider = StateNotifierProvider<OperationViewModel, AsyncValue<String>>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final opsVM = OperationViewModel(rosService);
  ref.onDispose(() => opsVM.dispose());
  return opsVM;
});
