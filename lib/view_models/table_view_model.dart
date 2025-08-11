import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/table_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class TableViewModel extends StateNotifier<List<int>> {

  final ROSService _rosService;
  Topic? _topicTablesList, _topicRequestTables;

  TableViewModel(this._rosService) : super([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

  Future<void> requestTableList() async {
    print('initiating requestTableList...');
    _topicRequestTables = _rosService.createTopic(
      ROSConstants.topicGetTables,
      ROSConstants.msgEmpty,
    );

    _topicRequestTables!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicRequestTables!.unsubscribe();
    });

    await _topicRequestTables!.publish({});
  }

  void getTableList() {
    print('initiating get tables topic...');
    _topicTablesList = _rosService.createTopic(
      ROSConstants.topicTablesList,
      ROSConstants.msgString,
    );
    _topicTablesList!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);

    // Check if the data is a string and parse it into a List<int>
    if (message['data'] is String) {
      try {
        // Parse the string into a List<dynamic> first
        List<dynamic> parsedList = jsonDecode(message['data']);

        // Convert the list to List<int> if necessary
        state = List<int>.from(parsedList);
      } catch (e) {
        print("Error parsing data: $e");
      }
    } else if (message['data'] is List<int>) {
      state = message['data']; // It's already a List<int>
    } else {
      // Handle any other cases if necessary
      print("Unexpected type for message['data']");
    }
    unSubscribe();
  }

  void unSubscribe() {
    _topicTablesList!.unsubscribe();
  }

}

final tableVMProvider = StateNotifierProvider<TableViewModel, List<int>>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return TableViewModel(rosService);
});
