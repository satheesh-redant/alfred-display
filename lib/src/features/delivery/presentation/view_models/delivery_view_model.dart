// import 'dart:async';
// import '../../../../core/base/base_view_model.dart';
// import '../../data/models/delivery_models.dart';
// import '../../../../shared/services/delivery_service.dart';
//
// class DeliveryViewModel extends BaseViewModel<DeliveryData> {
//   final DeliveryService _deliveryService;
//   late StreamSubscription _tableListSubscription;
//   late StreamSubscription _deliveryStatusSubscription;
//   List<int> _availableTables = [];
//
//   DeliveryViewModel(this._deliveryService) : super(const DeliveryData()) {
//     _initializeSubscriptions();
//     // _loadTables();
//   }
//
//   List<int> get availableTables => _availableTables;
//
//   void _initializeSubscriptions() {
//     _tableListSubscription = _deliveryService.tableListStream.listen((tables) {
//       _availableTables = tables;
//       safeUpdateState(state.copyWith());
//     });
//
//     _deliveryStatusSubscription =
//         _deliveryService.deliveryStatusStream.listen((status) {
//       _handleDeliveryStatus(status);
//     });
//   }
//
//   void _handleDeliveryStatus(String status) {
//     if (status.toLowerCase() == 'moving') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.moving,
//         message: state.isBaseToTable
//             ? 'Alfred is on the move to table ${state.selectedTable}...'
//             : 'Alfred is returning to base...',
//       ));
//     } else if (status.toLowerCase() == 'delivered') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.delivered,
//         message: state.isBaseToTable
//             ? 'Ready to serve at table ${state.selectedTable}'
//             : 'Alfred is back at base',
//       ));
//     }
//   }
//
//   Future<void> loadTables() async {
//     try {
//       await _deliveryService.requestTableList();
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.error,
//         message: 'Failed to load tables: $e',
//       ));
//     }
//   }
//
//   void selectTable(int? tableNumber) {
//     safeUpdateState(state.copyWith(
//       selectedTable: tableNumber,
//       state: DeliveryState.idle,
//     ));
//   }
//
//   Future<void> goToTable() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.baseToTable,
//         state: DeliveryState.moving,
//       ));
//       await _deliveryService.gotoPoint(selectedTable, 0);
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.error,
//         message: 'Failed to go to table: $e',
//       ));
//     }
//   }
//
//   Future<void> returnToBase() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.tableToBase,
//         state: DeliveryState.moving,
//       ));
//       await _deliveryService.gotoPoint(selectedTable, 1);
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.error,
//         message: 'Failed to return to base: $e',
//       ));
//     }
//   }
//
//   void resetToIdle() {
//     safeUpdateState(const DeliveryData());
//   }
//
//   @override
//   void onDispose() {
//     _tableListSubscription.cancel();
//     _deliveryStatusSubscription.cancel();
//     super.onDispose();
//   }
// }


//new
// import 'dart:async';
// import '../../../../core/base/base_view_model.dart';
// import '../../data/models/delivery_models.dart';
// import '../../../../core/services/ros_service.dart';
//
// class DeliveryViewModel extends BaseViewModel<DeliveryData> {
//   final ROSService _rosService;
//   late StreamSubscription _tableListSubscription;
//   late StreamSubscription _deliveryStatusSubscription;
//   List<int> _availableTables = [1,2,3,4,5,6,7,8,9,10];
//
//   DeliveryViewModel(this._rosService) : super(const DeliveryData()) {
//     _initializeSubscriptions();
//     loadTables();
//   }
//
//   List<int> get availableTables => _availableTables;
//
//   void _initializeSubscriptions() {
//     _tableListSubscription = _rosService.tableListStream.listen((tables) {
//       _availableTables = tables;
//       safeUpdateState(state.copyWith());
//     });
//
//     _deliveryStatusSubscription =
//         _rosService.deliveryStatusStream.listen((status) {
//           _handleDeliveryStatus(status);
//         });
//   }
//
//   void _handleDeliveryStatus(String status) {
//     if (status.toLowerCase() == 'moving') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.moving,
//         message: state.isBaseToTable
//             ? 'Alfred is on the move to table ${state.selectedTable}...'
//             : 'Alfred is returning to base...',
//       ));
//     } else if (status.toLowerCase() == 'delivered') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.delivered,
//         message: state.isBaseToTable
//             ? 'Ready to serve at table ${state.selectedTable}'
//             : 'Alfred is back at base',
//       ));
//     }
//   }
//
//   Future<void> loadTables() async {
//     try {
//       await _rosService.requestTableList();
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//        // state: DeliveryState.error,
//         message: 'Failed to load tables: $e',
//       ));
//     }
//   }
//
//   void selectTable(int? tableNumber) {
//     safeUpdateState(state.copyWith(
//       selectedTable: tableNumber,
//       state: DeliveryState.idle,
//     ));
//   }
//
//   Future<void> goToTable() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.baseToTable,
//         state: DeliveryState.moving,
//       ));
//       await _rosService.gotoPoint(selectedTable, 0);
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.error,
//        // message: 'Failed to go to table: $e',
//       ));
//     }
//   }
//
//   Future<void> returnToBase() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.tableToBase,
//         state: DeliveryState.moving,
//       ));
//       await _rosService.gotoPoint(selectedTable, 1);
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//      //   state: DeliveryState.error,
//         message: 'Failed to return to base: $e',
//       ));
//     }
//   }
//
//   void resetToIdle() {
//     safeUpdateState(const DeliveryData());
//   }
//
//   @override
//   void onDispose() {
//     _tableListSubscription.cancel();
//     _deliveryStatusSubscription.cancel();
//     super.onDispose();
//   }
// }


//ack

// import 'dart:async';
// import 'dart:math';
// import '../../../../core/base/base_view_model.dart';
// import '../../data/models/delivery_models.dart';
// import '../../../../core/services/ros_service.dart';
//
// class DeliveryViewModel extends BaseViewModel<DeliveryData> {
//   final ROSService _rosService;
//   late StreamSubscription _tableListSubscription;
//   late StreamSubscription _deliveryStatusSubscription;
//   late StreamSubscription _powerOffAckSubscription;
//   List<int> _availableTables = [1,2,3,4,5,6,7,8,9,10];
//
//   DeliveryViewModel(this._rosService) : super(const DeliveryData()) {
//     _initializeSubscriptions();
//     loadTables();
//   }
//
//   List<int> get availableTables => _availableTables;
//
//   void _initializeSubscriptions() {
//     _tableListSubscription = _rosService.tableListStream.listen((tables) {
//       _availableTables = tables;
//       safeUpdateState(state.copyWith());
//     });
//
//     _deliveryStatusSubscription =
//         _rosService.deliveryStatusStream.listen((status) {
//           _handleDeliveryStatus(status);
//         });
//
//     // 🔥 POWER-OFF ACK subscription (added)
//     _powerOffAckSubscription =
//         _rosService.powerOffAckStream.listen((ack) {
//           final isOk = ack.toString().toLowerCase() == "ok";
//           safeUpdateState(state.copyWith(powerOffAck: isOk));
//         });
//   }
//
//   void _handleDeliveryStatus(String status) {
//     if (status.toLowerCase() == 'moving') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.moving,
//         message: state.isBaseToTable
//             ? 'Alfred is on the move to table ${state.selectedTable}...'
//             : 'Alfred is returning to base...',
//       ));
//     } else if (status.toLowerCase() == 'delivered') {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.delivered,
//         message: state.isBaseToTable
//             ? 'Ready to serve at table ${state.selectedTable}'
//             : 'Alfred is back at base',
//       ));
//     }
//   }
//
//   Future<void> loadTables() async {
//     try {
//       await _rosService.requestTableList();
//     } catch (e) {
//       safeUpdateState(state.copyWith(
//         message: 'Failed to load tables: $e',
//       ));
//     }
//   }
//
//   void selectTable(int? tableNumber) {
//     safeUpdateState(state.copyWith(
//       selectedTable: tableNumber,
//       state: DeliveryState.idle,
//     ));
//   }
//
//   Future<void> goToTable() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.baseToTable,
//         state: DeliveryState.moving,
//       ));
//       await _rosService.gotoPoint(selectedTable, 0);
//     } catch (_) {
//       safeUpdateState(state.copyWith(
//         state: DeliveryState.error,
//       ));
//     }
//   }
//
//   Future<void> returnToBase() async {
//     final selectedTable = state.selectedTable;
//     if (selectedTable == null) return;
//
//     try {
//       safeUpdateState(state.copyWith(
//         route: DeliveryRoute.tableToBase,
//         state: DeliveryState.moving,
//       ));
//       await _rosService.gotoPoint(selectedTable, 1);
//     } catch (_) {
//       safeUpdateState(state.copyWith(
//         message: 'Failed to return to base: $e',
//       ));
//     }
//   }
//
//   void resetToIdle() {
//     safeUpdateState(const DeliveryData());
//   }
//
//   // 🔥 Publish power-off command (no change)
//   Future<void> sendPowerOff() async {
//     await _rosService.sendPowerOffCommand();
//   }
//
//   @override
//   void onDispose() {
//     _tableListSubscription.cancel();
//     _deliveryStatusSubscription.cancel();
//     _powerOffAckSubscription.cancel(); // 🔥 Dispose added
//     super.onDispose();
//   }
// }


//ack new

import 'dart:async';
import 'dart:math';
import '../../../../core/base/base_view_model.dart';
import '../../data/models/delivery_models.dart';
import '../../../../core/services/ros_service.dart';

class DeliveryViewModel extends BaseViewModel<DeliveryData> {
  final ROSService _rosService;
  late StreamSubscription _tableListSubscription;
  late StreamSubscription _deliveryStatusSubscription;
  List<int> _availableTables = [1,2,3,4,5,6,7,8,9,10];

  DeliveryViewModel(this._rosService) : super(const DeliveryData()) {
    _initializeSubscriptions();
    loadTables();
  }

  List<int> get availableTables => _availableTables;

  void _initializeSubscriptions() {
    _tableListSubscription = _rosService.tableListStream.listen((tables) {
      _availableTables = tables;
      safeUpdateState(state.copyWith());
    });

    // 🔥 delivery_status also contains POWER-OFF ACK (SHUTTING_DOWN)
    _deliveryStatusSubscription =
        _rosService.deliveryStatusStream.listen((status) {
          _handleDeliveryStatus(status);

          // 🔥 detect power-off ACK
          if (status.toString().toLowerCase().contains("shutting_down")) {
            safeUpdateState(state.copyWith(powerOffAck: true));
          }
        });
  }

  void _handleDeliveryStatus(String status) {
    if (status.toLowerCase() == 'moving') {
      safeUpdateState(state.copyWith(
        state: DeliveryState.moving,
        message: state.isBaseToTable
            ? 'Alfred is on the move to table ${state.selectedTable}...'
            : 'Alfred is returning to base...',
      ));
    } else if (status.toLowerCase() == 'delivered') {
      safeUpdateState(state.copyWith(
        state: DeliveryState.delivered,
        message: state.isBaseToTable
            ? 'Ready to serve at table ${state.selectedTable}'
            : 'Alfred is back at base',
      ));
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
      state: DeliveryState.idle,
    ));
  }

  Future<void> goToTable() async {
    final selectedTable = state.selectedTable;
    if (selectedTable == null) return;

    try {
      safeUpdateState(state.copyWith(
        route: DeliveryRoute.baseToTable,
        state: DeliveryState.moving,
      ));
      await _rosService.gotoPoint(selectedTable, 0);
    } catch (_) {
      safeUpdateState(state.copyWith(
        state: DeliveryState.error,
      ));
    }
  }

  Future<void> returnToBase() async {
    final selectedTable = state.selectedTable;
    if (selectedTable == null) return;

    try {
      safeUpdateState(state.copyWith(
        route: DeliveryRoute.tableToBase,
        state: DeliveryState.moving,
      ));
      await _rosService.gotoPoint(selectedTable, 1);
    } catch (_) {
      safeUpdateState(state.copyWith(
        message: 'Failed to return to base: $e',
      ));
    }
  }

  void resetToIdle() {
    safeUpdateState(const DeliveryData());
  }

  // 🔥 publish power off
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
