import 'dart:async';

import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/topic.dart';

class BasePointViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  late Topic _topicReturn, _topicReset, _topicResetAck, _topicReturnAck;

  Timer? timer;

  BasePointViewModel(this._rosService) : super("") {
    _initializeTopics();
  }

  void _initializeTopics() {
    print('initiating topics...');

    _topicReturn = _rosService.createTopic(
      ROSConstants.topicReturnToBase,
      ROSConstants.msgString,
    );
    print('Return To Base topic created...');

    _topicReturnAck = _rosService.createTopic(
      ROSConstants.topicReturnToBaseAck,
      ROSConstants.msgString,
      throttleRate: 1000,
    );
    print('Return To Base Ack topic created...');

    _topicReset = _rosService.createTopic(
      ROSConstants.topicResetBaseLoc,
      ROSConstants.msgString,
    );
    print('Reset Base topic created...');

    _topicResetAck = _rosService.createTopic(
      ROSConstants.topicResetBaseLocAck,
      ROSConstants.msgString,
      throttleRate: 1000,
    );
    print('Reset Base Ack topic created...');
  }

  Future<void> triggerReturnToBase() async {
    _topicReturn.subscribe((msg) async {
      print("Return to Base topic echo: $msg");
    });

    Map<String, dynamic> json = {"data": "Base"};
    if(timer == null) {
      timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
        print("publishing return to base...");
        _topicReturn.publish(json);
      },);
    }
  }

  void getReturnToBaseAck() {
    print('Subscribing return to base ack topic...');
    _topicReturnAck.subscribe(_handler);
  }

  Future<void> resetBaseLoc() async {
    print('initiating reset base location...');
    _topicReset.subscribe((msg) async {
      print("Reset Base echo: $msg");
      _topicReset.unsubscribe();
    });

    Map<String, dynamic> json = {"data": "Base"};
    await _topicReset.publish(json);
  }

  void getResetBaseLocAck() {
    print('Subscribing reset base location ack topic...');
    _topicResetAck.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void removeResetBaseListener() {
    _topicResetAck.unsubscribe();
    state = "";
  }

  void removeReturnToBaseListener() {
    _topicReturn.unsubscribe();
    timer?.cancel();
    timer = null;
  }

  void removeReturnToBaseAckListener() {
    _topicReturnAck.unsubscribe();
    state = "";
  }

}

final basePointVMProvider =
    StateNotifierProvider<BasePointViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BasePointViewModel(rosService);
});
