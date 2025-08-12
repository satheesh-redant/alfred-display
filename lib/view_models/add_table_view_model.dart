import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class AddTableViewModel extends StateNotifier<String> {

  final ROSService _rosService;
  Topic? _topicAddTable, _topicAddTableAck;

  AddTableViewModel(this._rosService) : super(""){
    print('initiating table topics');
    _topicAddTable = _rosService.createTopic(
      ROSConstants.topicAddTable,
      ROSConstants.msgString,
    );

    _topicAddTableAck = _rosService.createTopic(
      ROSConstants.topicAddTableAck,
      ROSConstants.msgString,
      throttleRate: 2000,
    );
  }

  Future<void> addTable({required int table}) async {
    Map<String, dynamic> json = {"data": table.toString()};
    print('Publishing add table: $json');
    await _topicAddTable!.publish(json);
  }

  Future<void> addTableAck() async {
    print('Subscribing to add table ack topic');
    _topicAddTableAck!.subscribe(_handlerAck);
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print('Add table ack data : $message');
    state = message['data'];
  }

  void unsubscribe() {
    print('Unsubscribing to add table ack topic');
    _topicAddTableAck!.unsubscribe();
    state = "";
  }

  @override
  void dispose() {
    print('Disposing all table topics');
    _topicAddTable!.unsubscribe();
    _topicAddTableAck!.unsubscribe();
  }

}

final addTableVMProvider = StateNotifierProvider<AddTableViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final addTableVM = AddTableViewModel(rosService);
  ref.onDispose(() => addTableVM.dispose());
  return addTableVM;
});
