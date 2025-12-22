enum DeliveryStatus {
  idle,
  moving,
  delivered,
  error
}

enum DeliveryRoute {
  baseToTable,
  tableToBase
}

class DeliveryState {
  final int? selectedTable;
  final DeliveryRoute route;
  final DeliveryStatus state;
  final String message;

  // NEW FIELD (default false)
  final bool powerOffAck;

  const DeliveryState({
    this.selectedTable,
    this.route = DeliveryRoute.baseToTable,
    this.state = DeliveryStatus.idle,
    this.message = '',
    this.powerOffAck = false, // default
  });

  DeliveryState copyWith({
    int? selectedTable,
    DeliveryRoute? route,
    DeliveryStatus? state,
    String? message,
    bool? powerOffAck, // added
  }) {
    return DeliveryState(
      selectedTable: selectedTable ?? this.selectedTable,
      route: route ?? this.route,
      state: state ?? this.state,
      message: message ?? this.message,
      powerOffAck: powerOffAck ?? this.powerOffAck, // added
    );
  }

  int get routeValue => route == DeliveryRoute.baseToTable ? 0 : 1;
  bool get isBaseToTable => route == DeliveryRoute.baseToTable;
  bool get isTableToBase => route == DeliveryRoute.tableToBase;
}
