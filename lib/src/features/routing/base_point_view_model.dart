import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/topic.dart';

import '../../core/configs/ros_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/ros_service.dart';

class BasePointViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicReturn, _topicReset, _topicResetAck, _topicReturnAck;

  Timer? timer;

  BasePointViewModel(this._rosService) : super("") {
    _initializeTopics();
  }

  void _initializeTopics() {
    print('initiating Base Point topics');

    _topicReturn = _rosService.createTopic(
      ROSConstants.topicReturnToBase,
      ROSConstants.msgString,
    );

    _topicReturnAck = _rosService.createTopic(
      ROSConstants.topicReturnToBaseAck,
      ROSConstants.msgString,
      throttleRate: 1000,
    );
    _topicReturnAck?.subscribe(_handler);

    _topicReset = _rosService.createTopic(
      ROSConstants.topicResetBaseLoc,
      ROSConstants.msgString,
    );

    _topicResetAck = _rosService.createTopic(
      ROSConstants.topicResetBaseLocAck,
      ROSConstants.msgString,
      throttleRate: 1000,
    );
    _topicResetAck?.subscribe(_handler);
  }

  Future<void> triggerReturnToBase() async {
    Map<String, dynamic> json = {"data": "Base"};
    if(timer == null) {
      timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
        print("Publishing return to base: $json");
        _topicReturn?.publish(json);
      },);
    }
  }

  Future<void> resetBaseLoc() async {
    Map<String, dynamic> json = {"data": "Base"};
    print('Publishing reset base location: $json');
    await _topicReset?.publish(json);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print('Base topic data : $message');
    state = message['data'];
  }

  void stopTimer() {
    print('Unsubscribing to return base topic & timer');
    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    print('Disposing all base point topics');
    _topicReturn?.unsubscribe();
    _topicReturnAck?.unsubscribe();
    _topicReset?.unsubscribe();
    _topicResetAck?.unsubscribe();
    state = "";
    if(timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

}

final basePointVMProvider =
    StateNotifierProvider<BasePointViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final basePointVM = BasePointViewModel(rosService);
  ref.onDispose(() => basePointVM.dispose());
  return basePointVM;
});
