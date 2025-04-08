import 'dart:async';
import 'dart:ffi';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class OperationViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicCurrentMode, _topicSetOpsMode;

  OperationViewModel(this._rosService) : super("");

  void getCurrentOp() {
    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicCurrentMode,
      ROSConstants.msgString,
    );
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    //todo handle the response
    // state = state.copyWith(
    //   posX: message['pose']['pose']['position']['x'],
    //   posY: message['pose']['pose']['position']['y'],
    //   oriX: message['pose']['pose']['orientation']['x'],
    //   oriY: message['pose']['pose']['orientation']['y'],
    //   oriZ: message['pose']['pose']['orientation']['z'],
    //   oriW: message['pose']['pose']['orientation']['w'],
    //   linVel: message['twist']['twist']['linear']['x'],
    //   angVel: message['twist']['twist']['angular']['z'],
    // );
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
