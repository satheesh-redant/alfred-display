import 'dart:async';
import 'dart:convert';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/table_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';
import 'package:rosbridge/rosbridge.dart';

class TableViewModel extends StateNotifier<List<int>> {
  final ROSService _rosService;
  Topic? _topicTablesList, _topicRequestTables;

  TableViewModel(this._rosService) : super([]) {
    print('initiating all get tables topics');
    _topicRequestTables = _rosService.createTopic(
      ROSConstants.topicGetTables,
      ROSConstants.msgEmpty,
    );
    _topicTablesList = _rosService.createTopic(
      ROSConstants.topicTablesList,
      ROSConstants.msgString,
    );
    _topicTablesList!.subscribe(_handler);
  }

  Future<void> requestTableList() async {
    print('Publishing request tables');
    await _topicRequestTables!.publish({});
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print('Table list: $message');

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
    // unSubscribe();
  }

  void unSubscribe() {
    print('Unsubscribing to table list topic');
    _topicTablesList!.unsubscribe();
  }

  @override
  void dispose() {
    print('Disposing all route topics');
    _topicRequestTables!.unsubscribe();
    _topicTablesList!.unsubscribe();
    state = [];
  }
}

final tableVMProvider = StateNotifierProvider<TableViewModel, List<int>>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final tableVM = TableViewModel(rosService);
  ref.onDispose(() => tableVM.dispose());
  return tableVM;
});
