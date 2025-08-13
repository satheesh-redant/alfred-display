import 'dart:async';
import '../../../../core/base/base_view_model.dart';
import '../../data/models/delivery_models.dart';
import '../../data/services/delivery_service.dart';

class DeliveryProgressViewModel extends BaseViewModel<DeliveryData> {
  final DeliveryService _deliveryService;
  late StreamSubscription _deliveryStatusSubscription;

  DeliveryProgressViewModel(this._deliveryService,
      {int? tableNumber, int? route})
      : super(DeliveryData(
          selectedTable: tableNumber,
          route: route,
          state: DeliveryState.moving,
          progressStage: route == 0
              ? DeliveryProgressStage.baseToTable
              : DeliveryProgressStage.tableToBase,
          message: route == 0
              ? 'Alfred is moving to table...'
              : 'Alfred is returning to base...',
        )) {
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    _deliveryStatusSubscription =
        _deliveryService.deliveryStatusStream.listen((statusUpdate) {
      _handleDeliveryStatusUpdate(statusUpdate);
    });
  }

  void _handleDeliveryStatusUpdate(DeliveryStatusUpdate statusUpdate) {
    if (statusUpdate.isMoving) {
      final isBaseToTable = state.isBaseToTable;
      safeUpdateState(state.copyWith(
        state: DeliveryState.moving,
        progressStage: isBaseToTable
            ? DeliveryProgressStage.baseToTable
            : DeliveryProgressStage.tableToBase,
        message: isBaseToTable
            ? 'Alfred is moving to table ${state.selectedTable}...'
            : 'Alfred is returning to base...',
      ));
    } else if (statusUpdate.isDelivered) {
      final isBaseToTable = state.isBaseToTable;

      if (isBaseToTable) {
        // Finished base to table journey
        safeUpdateState(state.copyWith(
          state: DeliveryState.delivered,
          progressStage: DeliveryProgressStage.baseToTableFinished,
          message: 'Alfred has arrived at table ${state.selectedTable}',
        ));
      } else {
        // Finished table to base journey
        safeUpdateState(state.copyWith(
          state: DeliveryState.delivered,
          progressStage: DeliveryProgressStage.tableToBaseFinished,
          message: 'Alfred has returned to base',
        ));
      }
    }
  }

  void startReturnJourney() {
    // Update to table to base route and trigger movement
    safeUpdateState(state.copyWith(
      route: 1,
      state: DeliveryState.moving,
      progressStage: DeliveryProgressStage.tableToBase,
      message: 'Starting return journey to base...',
    ));

    // Publish the return command
    if (state.selectedTable != null) {
      _deliveryService.moveToTable(state.selectedTable!, 1);
    }
  }

  @override
  void onDispose() {
    _deliveryStatusSubscription.cancel();
    super.onDispose();
  }
}
