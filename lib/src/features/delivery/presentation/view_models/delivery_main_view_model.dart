import 'dart:async';
import '../../../../core/base/base_view_model.dart';
import '../../data/models/delivery_models.dart';
import '../../data/services/delivery_service.dart';

class DeliveryMainViewModel extends BaseViewModel<DeliveryData> {
  final DeliveryService _deliveryService;
  late StreamSubscription _tableListSubscription;
  late StreamSubscription _deliveryStatusSubscription;
  List<int> _availableTables = [];

  DeliveryMainViewModel(this._deliveryService) : super(const DeliveryData()) {
    _initializeSubscriptions();
    _loadTables();
  }

  List<int> get availableTables => _availableTables;

  void _initializeSubscriptions() {
    _tableListSubscription = _deliveryService.tableListStream.listen((tables) {
      _availableTables = tables;
      safeUpdateState(state.copyWith());
    });

  }

  Future<void> _loadTables() async {
    safeUpdateState(state.copyWith(state: DeliveryState.idle));
    try {
      await _deliveryService.requestTableList();
    } catch (e) {
      safeUpdateState(state.copyWith(
        state: DeliveryState.error,
        message: 'Failed to load tables: $e',
      ));
    }
  }

  void selectTable(int? tableNumber) {
    safeUpdateState(state.copyWith(selectedTable: tableNumber));
  }

  Future<void> goToTable() async {
    final selectedTable = state.selectedTable;
    if (selectedTable == null) return;

    safeUpdateState(state.copyWith(state: DeliveryState.moving));

    try {
      await _deliveryService.moveToTable(selectedTable, 0);
    } catch (e) {
      safeUpdateState(state.copyWith(
        state: DeliveryState.error,
        message: 'Failed to move to table: $e',
      ));
    }
  }

  void resetState() {
    safeUpdateState(const DeliveryData());
  }

  @override
  void onDispose() {
    _tableListSubscription.cancel();
    super.onDispose();
  }
}
