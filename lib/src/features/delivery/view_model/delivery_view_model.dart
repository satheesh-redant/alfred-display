import 'dart:async';
import 'dart:math';

import '../../../core/base/base_view_model.dart';
import '../../../core/services/ros_service.dart';
import '../state/delivery_state.dart';

class DeliveryViewModel extends BaseViewModel<DeliveryState> {
  final ROSService _rosService;

  late StreamSubscription _tableListSubscription;
  late StreamSubscription _deliveryStatusSubscription;
  late StreamSubscription _softPowerOffSubscription;

  List<int> _availableTables = [];

  List<int> get availableTables => _availableTables;

  DeliveryViewModel(this._rosService) : super(const DeliveryState()) {
    _initializeSubscriptions();
    _initializeTableList();
  }

  void _initializeSubscriptions() {
    _tableListSubscription = _rosService.tableListStream.listen((tables) {
      _availableTables = tables;
      safeUpdateState(state.copyWith());
    });

    // delivery_status also contains POWER-OFF ACK (SHUTTING_DOWN)
    _deliveryStatusSubscription =
        _rosService.deliveryStatusStream.listen((status) {
      _handleDeliveryStatus(status);
    });

    _softPowerOffSubscription = _rosService.powerOffAckStream.listen((status) {
      if (status.toString().toLowerCase().contains("shutting_down")) {
        safeUpdateState(state.copyWith(powerOffAck: true));
      }
    });
  }

  void _initializeTableList() async {
    _availableTables = List.generate(10, (index) => index + 1);
  }

  void _handleDeliveryStatus(String status) {
    if (status.toLowerCase() == 'moving') {
      safeUpdateState(state.copyWith(
        state: DeliveryStatus.moving,
        message: state.isBaseToTable
            ? 'Alfred is on the move to table ${state.selectedTable}...'
            : 'Alfred is returning to base...',
      ));
    } else if (status.toLowerCase() == 'delivered') {
      _initializeTableList();
      if (state.isBaseToTable) {
        //add base
        _availableTables.first = 0;
        // Remove current table location
        _availableTables.removeWhere((table) => table == state.selectedTable!);
        safeUpdateState(state.copyWith(
          state: DeliveryStatus.delivered,
          message: state.isBaseToTable
              ? 'Ready to serve at table ${state.selectedTable}'
              : 'Alfred is back at base',
        ));
      } else {
        resetToIdle();
      }
    }
  }

  Future<void> loadTables() async {
    try {
      await _rosService.requestTableList();
    } catch (e) {
      safeUpdateState(state.copyWith(
        message: 'Failed to load tables: $e',
      ));
    }
  }

  void selectTable(int? tableNumber) {
    safeUpdateState(state.copyWith(
      selectedTable: tableNumber,
    ));
  }

  Future<void> goToTable() async {
    final selectedTable = state.selectedTable;
    if (selectedTable == null) return;

    try {
      safeUpdateState(state.copyWith(
        route: state.selectedTable == 0
            ? DeliveryRoute.tableToBase
            : DeliveryRoute.baseToTable,
      ));
      await _rosService.gotoPoint(selectedTable);
    } catch (_) {
      safeUpdateState(state.copyWith(
        state: DeliveryStatus.error,
      ));
    }
  }

  // Future<void> returnToBase() async {
  //   final selectedTable = states.selectedTable;
  //   if (selectedTable == null) return;
  //
  //   try {
  //     safeUpdateState(states.copyWith(
  //       route: DeliveryRoute.tableToBase,
  //       states: DeliveryState.moving,
  //     ));
  //     await _rosService.gotoPoint(selectedTable);
  //   } catch (_) {
  //     safeUpdateState(states.copyWith(
  //       message: 'Failed to return to base: $e',
  //     ));
  //   }
  // }

  void resetToIdle() {
    safeUpdateState(const DeliveryState());
  }

  Future<void> sendPowerOff() async {
    await _rosService.sendPowerOffCommand();
  }

  @override
  void onDispose() {
    _tableListSubscription.cancel();
    _deliveryStatusSubscription.cancel();
    super.onDispose();
  }
}
