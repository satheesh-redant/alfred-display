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
  final bool isLoading;
  final DeliveryRoute route;
  final DeliveryStatus state;
  final String message;

  // NEW FIELD (default false)
  final bool powerOffAck;
  final bool isModeChanged;

  const DeliveryState({
    this.selectedTable,
    this.isLoading = false,
    this.route = DeliveryRoute.baseToTable,
    this.state = DeliveryStatus.idle,
    this.message = '',
    this.powerOffAck = false,
    this.isModeChanged = false,
  });

  DeliveryState copyWith({
    int? selectedTable,
    bool? isLoading,
    DeliveryRoute? route,
    DeliveryStatus? state,
    String? message,
    bool? powerOffAck,
    bool? isModeChanged,
  }) {
    return DeliveryState(
      selectedTable: selectedTable ?? this.selectedTable,
      isLoading: isLoading ?? this.isLoading,
      route: route ?? this.route,
      state: state ?? this.state,
      message: message ?? this.message,
      powerOffAck: powerOffAck ?? this.powerOffAck,
      isModeChanged: isModeChanged ?? this.isModeChanged,
    );
  }

  int get routeValue => route == DeliveryRoute.baseToTable ? 0 : 1;
  bool get isBaseToTable => route == DeliveryRoute.baseToTable;
  bool get isTableToBase => route == DeliveryRoute.tableToBase;
}
