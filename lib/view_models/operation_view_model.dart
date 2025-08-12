import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class OperationViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicCurrentMode/*, _topicSetOpsMode*/;

  OperationViewModel(this._rosService) : super("") {
    print('initiating all ops mode topics');

    _topicCurrentMode = _rosService.createTopic(
      ROSConstants.topicSetOpsMode, //todo change it to current mode
      ROSConstants.msgString,
      throttleRate: 500,
    );


  }

  void getCurrentOp() {
    print('Subscribing to current operation topic');
    _topicCurrentMode!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print('Current ops mode: $message');
    state = message['data'];
  }

  void unsubscribe() {
    print('Unsubscribing to current ops mode topic');
    _topicCurrentMode!.unsubscribe();
    state = "";
  }

  Future<void> sendOpsMode({required String mode}) async {
    // _topicSetOpsMode = _rosService.createTopic(
    //   ROSConstants.topicSetOpsMode,
    //   ROSConstants.msgString,
    // );
    //
    // _topicSetOpsMode!.subscribe((msg) async {
    //   print("Received echo on trigger topic: $msg");
    //   _topicSetOpsMode!.unsubscribe();
    // });

    Map<String, dynamic> json = {"data": mode};
    print('Publishing ops mode: $json');
    await _topicCurrentMode!.publish(json);
  }

  @override
  void dispose() {
    print('Disposing all ops mode topics');
    _topicCurrentMode!.unsubscribe();
    // _topicSetOpsMode!.unsubscribe();
    state = "";
  }
}

final opsVMProvider = StateNotifierProvider<OperationViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final opsVM = OperationViewModel(rosService);
  ref.onDispose(() => opsVM.dispose());
  return opsVM;
});
