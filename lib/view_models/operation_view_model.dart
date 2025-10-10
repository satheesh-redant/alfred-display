import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class OperationViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicCurrentMode, _topicSetMode;

  OperationViewModel(this._rosService) : super("") {
    _topicSetMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode,
      ROSConstants.msgString,
    );
  }

  Future<void> getCurrentMode() async {
    print('initiating /mode topic');
    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicCurrentMode,
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
    await _topicSetMode!.publish(json);
  }

  void unsubscribe() {
    _topicCurrentMode?.unsubscribe();
    _topicCurrentMode = null;
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
