
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This provider manages a list of table IDs that the user has "removed"
/// from the UI during the current app session. This is a "soft delete" and
/// does not affect the permanent data stored on the ROS node.
class RemovedTablesNotifier extends StateNotifier<List<int>> {
  RemovedTablesNotifier() : super([]);

  /// Adds a table ID to the list of tables to be hidden from the UI.
  void add(int tableId) {
    final currentState = state.toSet();
    currentState.add(tableId);
    state = currentState.toList();
  }

  /// If a user decides to re-add a table that was previously removed in the
  /// same session, this function removes it from the "removed" list,
  void remove(int tableId) {
    state = state.where((id) => id != tableId).toList();
  }

  void clear() {
    state = [];
  }
}

final removedTablesProvider =
StateNotifierProvider<RemovedTablesNotifier, List<int>>((ref) {
  return RemovedTablesNotifier();
});



