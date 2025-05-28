import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class OperationViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicCurrentMode, _topicSetOpsMode;

  OperationViewModel(this._rosService) : super("");

  void getCurrentOp() {
    print('Subscribing current operation topic...');
    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode, //todo change it to current mode
      ROSConstants.msgString,
      throttleRate: 500,
    );
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void unsubscribe() {
    _topicCurrentMode!.unsubscribe();
    state = "";
  }

  Future<void> sendOpsMode({required String mode}) async {
    print('re-initiating send ops mode topic...');
    _topicSetOpsMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode,
      ROSConstants.msgString,
    );
    _topicSetOpsMode!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicSetOpsMode!.unsubscribe();
    });

    Map<String, dynamic> json = {"data": mode};
    await _topicSetOpsMode!.publish(json);
  }
}

final opsVMProvider = StateNotifierProvider<OperationViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return OperationViewModel(rosService);
});
