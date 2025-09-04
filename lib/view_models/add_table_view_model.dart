import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class AddTableViewModel extends StateNotifier<String> {

  final ROSService _rosService;
  Topic? _topicAddTable, _topicAddTableAck, _topicSaveMap, _topicSavedMapAck;

  AddTableViewModel(this._rosService) : super(""){
    print('initiating table topics');
    _topicAddTable = _rosService.createTopic(
      ROSConstants.topicAddTable,
      ROSConstants.msgString,
    );

    _topicSaveMap = _rosService.createTopic(
      ROSConstants.topicSaveMap,
      ROSConstants.msgEmpty,
    );

    _topicAddTableAck = _rosService.createTopic(
      ROSConstants.topicAddTableAck,
      ROSConstants.msgString,
      throttleRate: 2000,
    );
    _topicAddTableAck!.subscribe(_handlerAck);

    _topicSavedMapAck = _rosService.createTopic(
      ROSConstants.topicMapSaved,
      ROSConstants.msgString,
      throttleRate: 2000,
    );
    _topicSavedMapAck!.subscribe(_handlerMapAck);
  }

  Future<void> addTable({required int table}) async {
    Map<String, dynamic> json = {"data": table.toString()};
    print('Publishing add table: $json');
    await _topicAddTable!.publish(json);
  }

  Future<void> saveMap() async {
    await _topicSaveMap!.publish({});
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print('Add table ack data : $message');
    state = message['data'];
  }

  Future<void> _handlerMapAck(Map<String, dynamic> message) async {
    print('Save map ack data : $message');
    state = message['data'];
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
