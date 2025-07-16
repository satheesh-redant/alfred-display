// lib/view_models/table_view_model.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/ros_constants.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';
import '../models/table_state.dart';

class TableViewModel extends StateNotifier<List<int>> {
  final ROSService _service;
  Topic? _topicTablesList, _topicRequestTables;
  TableState? _newTable;
  int? _removedTableId;

  TableViewModel(this._service) : super([]) {
    requestTableList();
  }

  // ROS fetching logic (unchanged)
  Future<void> requestTableList() async {
    _topicRequestTables = _service.createTopic(
      ROSConstants.topicGetTables,
      ROSConstants.msgEmpty,
    );
    await _topicRequestTables!.publish({});
    getTableList();
  }

  void getTableList() {
    _topicTablesList = _service.createTopic(
      ROSConstants.topicTablesList,
      ROSConstants.msgString,
    );
    _topicTablesList!.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    if (message['data'] is String) {
      try {
        List<dynamic> parsedList = jsonDecode(message['data']);
        state = List<int>.from(parsedList);
      } catch (e) {}
    } else if (message['data'] is List<int>) {
      state = message['data'];
    }
  }

  void unSubscribe() {
    _topicTablesList?.unsubscribe();
    _topicRequestTables?.unsubscribe();
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
  return TableViewModel(rosService);
});
