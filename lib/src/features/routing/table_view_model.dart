import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/rosbridge.dart';

import '../mapping/states/table_state.dart';
import '../../core/configs/ros_constants.dart';
import '../../core/providers/core_providers.dart';
import '../../core/services/ros_service.dart';

class TableViewModel extends StateNotifier<List<int>> {
  final ROSService _rosService;
  Topic? _topicTablesList, _topicRequestTables;
  TableState? _newTable;
  int? _removedTableId;

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

  // Business logic
  List<TableState> getTableStates() {
    final tables = state
        .where((id) => id != _removedTableId)
        .map((id) => TableState(tableNumber: id, isMarked: true, isEnabled: false))
        .toList()
      ..sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    if (_newTable != null && !_newTable!.isRemoved) {
      tables.add(_newTable!);
      tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    }
    return tables;
  }

  void addTable(int tableNumber) {
    if (state.contains(tableNumber) && tableNumber != _removedTableId) return;
    _newTable = TableState(tableNumber: tableNumber, isNewlyAdded: true, isSelected: false);
    notifyListeners();
  }

  void removeTable(int tableNumber) {
    if (_newTable != null && _newTable!.tableNumber == tableNumber) {
      _newTable = _newTable!.copyWith(isRemoved: true);
    } else if (state.contains(tableNumber)) {
      _removedTableId = tableNumber;
      state = state.where((id) => id != tableNumber).toList();
    }
    notifyListeners();
  }

  void selectTable(int tableNumber) {
    if (state.contains(tableNumber) && tableNumber != _removedTableId) return;
    if (_newTable != null && _newTable!.tableNumber == tableNumber && !_newTable!.isRemoved) {
      _newTable = _newTable!.copyWith(isSelected: true);
      notifyListeners();
    }
  }

  void confirmTable(int tableNumber) {
    if (_newTable != null && _newTable!.tableNumber == tableNumber) {
      state = [...state, tableNumber];
      _newTable = null;
      if (tableNumber == _removedTableId) _removedTableId = null;
      notifyListeners();
    }
  }

  void resetMarking() {
    if (_newTable != null) {
      _newTable = _newTable!.copyWith(isSelected: false);
      notifyListeners();
    }
  }

  bool get hasMarkedTables => state.isNotEmpty;

  int? get selectedTableNumber => _newTable != null && _newTable!.isSelected && !_newTable!.isRemoved ? _newTable!.tableNumber : null;

  void notifyListeners() {
    state = [...state];
  }
}

final tableVMProvider = StateNotifierProvider<TableViewModel, List<int>>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final tableVM = TableViewModel(rosService);
  ref.onDispose(() => tableVM.dispose());
  return tableVM;
});
