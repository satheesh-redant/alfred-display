import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ros_service.dart';
import '../state/delivery_state.dart';

class DeliveryViewModel extends StateNotifier<DeliveryState> {
  final ROSService _ros;
  StreamSubscription? _statusSub;
  StreamSubscription? _tablesSub;

  DeliveryViewModel(this._ros) : super(const DeliveryState()) {
    _initializeStreams();
    _loadTables();
  }

  void _initializeStreams() {
    // Subscribe to ROS delivery status stream
    _statusSub = _ros.deliveryStatusStream.listen(_handleStatus);

    // Subscribe to ROS table list stream
    _tablesSub = _ros.tableListStream.listen((tables) {
      state = state.copyWith(availableTables: tables);
    });
  }

  void _handleStatus(String status) {
    final statusLower = status.toLowerCase().trim();

    if (statusLower == 'moving') {
      state = state.copyWith(
        status: DeliveryStatus.moving,
        message: state.isBaseToTable
            ? 'Alfred is moving to table ${state.selectedTable}...'
            : 'Alfred is returning to base...',
      );
    } else if (statusLower == 'delivered') {
      _handleDeliveryComplete();
    } else if (statusLower.contains('error') || statusLower.contains('failed')) {
      state = state.copyWith(
        status: DeliveryStatus.error,
        message: 'Error: $status',
      );
    }
  }

  void _handleDeliveryComplete() {
    if (state.isBaseToTable) {
      // Robot reached table - update available destinations
      final updatedTables = List<int>.from(state.availableTables)
        ..removeWhere((t) => t == state.selectedTable)
        ..insert(0, 0); // Add base (0) as option

      state = state.copyWith(
        status: DeliveryStatus.delivered,
        message: 'Ready to serve at table ${state.selectedTable}',
        availableTables: updatedTables,
      );
    } else {
      // Robot returned to base - reset
      reset();
    }
  }

  void _loadTables() {
    // Initialize with default tables (for development)
    final defaultTables = List.generate(10, (index) => index + 1);
    state = state.copyWith(availableTables: defaultTables);

    // Also request from ROS
    loadTables();
  }

  /// Load available tables from ROS
  Future<void> loadTables() async {
    try {
      await _ros.requestTableList();
    } catch (e) {
      state = state.copyWith(
        status: DeliveryStatus.error,
        message: 'Failed to load tables: $e',
      );
    }
  }

  /// Select a table
  void selectTable(int? tableNumber) {
    state = state.copyWith(selectedTable: tableNumber);
  }

  /// Send robot to selected table
  Future<void> goToTable() async {
    if (state.selectedTable == null) return;

    try {
      final route = state.selectedTable == 0
          ? DeliveryRoute.tableToBase
          : DeliveryRoute.baseToTable;

      state = state.copyWith(route: route, isLoading: true);

      // Send command to ROS
      await _ros.gotoPoint(state.selectedTable!);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        status: DeliveryStatus.error,
        message: 'Failed to send command: $e',
        isLoading: false,
      );
    }
  }

  /// Reset to initial state
  void reset() {
    state = const DeliveryState();
    _loadTables();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _tablesSub?.cancel();
    super.dispose();
  }
}
