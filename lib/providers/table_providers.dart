
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Provider for tables list
final tableProvider = StateNotifierProvider<TableNotifier, List<int>>((ref) => TableNotifier());

final markedTablesProvider = StateProvider<List<int>>((ref) => []);

class TableNotifier extends StateNotifier<List<int>> {
  TableNotifier() : super(List.generate(10, (index) => index + 1));

  void addTable() {
    state = [...state, state.length + 1];
  }
}

// Provider for selected table
final selectedTableProvider = StateProvider<int?>((ref) => null);

// Provider for mapping state
final isTrainingProvider = StateProvider<bool>((ref) => false);

// New provider to track selected state for each table
final tableSelectionProvider = StateNotifierProvider<TableSelectionNotifier, Map<int, bool>>(
      (ref) => TableSelectionNotifier(),
);

// Add this provider to your table_providers.dart file
final isMarkingCompleteProvider = StateProvider<bool>((ref) => false);

class TableSelectionNotifier extends StateNotifier<Map<int, bool>> {
  TableSelectionNotifier() : super({});

  void toggleSelection(int tableNumber) {
    state = {...state, tableNumber: !(state[tableNumber] ?? false)};
  }
  void clearSelection() {
    state = {};
  }
}
