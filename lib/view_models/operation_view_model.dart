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
      ROSConstants.topicCurrentMode,
      ROSConstants.msgString,
    );
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void unSubscribe() {
    _topicCurrentMode!.unsubscribe();
  }

  Future<void> sendOpsMode({required String mode}) async {
    print('re-initiating boot check topic...');
    _topicSetOpsMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode,
      ROSConstants.msgString,
    );

    // Subscribe to the topic to check for your published message (for confirmation).
    // Note: In a production scenario, this echo should ideally be part of the ROS system or another node.
    _topicSetOpsMode!.subscribe((msg) async {
      Map<String, dynamic> response = {};
      print("Received echo on trigger topic: $msg");
      // Optionally, cancel the subscription after receiving the echo once.
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
