enum DeliveryState {
  idle,
  moving,
  delivered,
  error
}

enum DeliveryRoute {
  baseToTable, // 0
  tableToBase  // 1
}

class DeliveryData {
  final int? selectedTable;
  final DeliveryRoute route;
  final DeliveryState state;
  final String message;

  const DeliveryData({
    this.selectedTable,
    this.route = DeliveryRoute.baseToTable,
    this.state = DeliveryState.idle,
    this.message = '',
  });

  DeliveryData copyWith({
    int? selectedTable,
    DeliveryRoute? route,
    DeliveryState? state,
    String? message,
  }) {
    return DeliveryData(
      selectedTable: selectedTable ?? this.selectedTable,
      route: route ?? this.route,
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }

  int get routeValue => route == DeliveryRoute.baseToTable ? 0 : 1;
  bool get isBaseToTable => route == DeliveryRoute.baseToTable;
  bool get isTableToBase => route == DeliveryRoute.tableToBase;
}
