import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class AddTableViewModel extends StateNotifier<String> {

  final ROSService _rosService;
  Topic? _topicAddTable, _topicAddTableAck;

  AddTableViewModel(this._rosService) : super("");

  Future<void> addTable({required int table}) async {
    print('initiating add table topic...');
    _topicAddTable = _rosService.createTopic(
      ROSConstants.topicAddTable,
      ROSConstants.msgString,
    );

    _topicAddTable!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicAddTable!.unsubscribe();
    });

    Map<String, dynamic> json = {"data": table.toString()};
    await _topicAddTable!.publish(json);
  }

  Future<void> addTableAck() async {
    print('initiating add table topic...');
    _topicAddTableAck = _rosService.createTopic(
      ROSConstants.topicAddTableAck,
      ROSConstants.msgString,
      throttleRate: 2000,
    );

    _topicAddTableAck!.subscribe(_handlerAck);
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void unsubscribe() {
    _topicAddTableAck!.unsubscribe();
    state = "";
  }

}

final addTableVMProvider = StateNotifierProvider<AddTableViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return AddTableViewModel(rosService);
});
