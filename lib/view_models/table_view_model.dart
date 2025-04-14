import 'dart:async';
import 'dart:ffi';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/table_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class TableViewModel extends StateNotifier<TableData> {

  final ROSService _rosService;
  Topic? _topicAddTable, _topicGetTables, _topicMoveTable, _topicRTB;

  TableViewModel(this._rosService) : super(TableData());

  void getTableList() {
    print('initiating get tables topic...');
    _topicGetTables = _rosService.createTopic(
      ROSConstants.topicGetTables,
      ROSConstants.msgString,
    );
    _topicGetTables!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    //todo handle the response
  }

  void unSubscribe() {
    _topicGetTables!.unsubscribe();
  }

  Future<void> addTable({required int table}) async {
    print('initiating add table topic...');
    _topicAddTable = _rosService.createTopic(
      ROSConstants.topicAddTable,
      ROSConstants.msgInteger,
    );

    // Subscribe to the topic to check for your published message (for confirmation).
    // Note: In a production scenario, this echo should ideally be part of the ROS system or another node.
    _topicAddTable!.subscribe((msg) async {
      Map<String, dynamic> response = {};
      print("Received echo on trigger topic: $msg");
      // Optionally, cancel the subscription after receiving the echo once.
      _topicAddTable!.unsubscribe();
    });

    Map<String, dynamic> json = {"data": table};
    await _topicAddTable!.publish(json);
  }

  Future<void> getTablesTable() async {
    print('initiating get tables topic...');
    _topicAddTable = _rosService.createTopic(
      ROSConstants.topicGetTables,
      ROSConstants.msgInteger,
    );

    // Subscribe to the topic to check for your published message (for confirmation).
    // Note: In a production scenario, this echo should ideally be part of the ROS system or another node.
    _topicAddTable!.subscribe((msg) async {
      print("table list: $msg");
      _topicAddTable!.unsubscribe();
    });
  }

  Future<void> moveTable({required int table}) async {
    print('initiating move table topic...');
    _topicMoveTable = _rosService.createTopic(
      ROSConstants.topicMoveTable,
      ROSConstants.msgInteger,
    );

    _topicMoveTable!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicMoveTable!.unsubscribe();
    });

    Map<String, dynamic> json = {"data": table};
    await _topicMoveTable!.publish(json);
  }

  Future<void> returnToBase() async {
    print('initiating return to base topic...');
    _topicRTB = _rosService.createTopic(
      ROSConstants.topicReturnToBase,
      ROSConstants.msgEmpty,
    );

    _topicRTB!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicRTB!.unsubscribe();

    });

    await _topicRTB!.publish({});
  }


}

final tableVMProvider = StateNotifierProvider<TableViewModel, TableData>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return TableViewModel(rosService);
});
