enum DeliveryStatus { idle, moving, delivered, error }

enum DeliveryRoute { baseToTable, tableToBase }

class DeliveryState {
  final int? selectedTable;
  final bool isLoading;
  final DeliveryRoute route;
  final DeliveryStatus status;
  final String message;
  final List<int> availableTables;

  const DeliveryState({
    this.selectedTable,
    this.isLoading = false,
    this.route = DeliveryRoute.baseToTable,
    this.status = DeliveryStatus.idle,
    this.message = '',
    this.availableTables = const [],
  });

  DeliveryState copyWith({
    int? selectedTable,
    bool? isLoading,
    DeliveryRoute? route,
    DeliveryStatus? status,
    String? message,
    List<int>? availableTables,
  }) {
    return DeliveryState(
      selectedTable: selectedTable ?? this.selectedTable,
      isLoading: isLoading ?? this.isLoading,
      route: route ?? this.route,
      status: status ?? this.status,
      message: message ?? this.message,
      availableTables: availableTables ?? this.availableTables,
    );
  }

  bool get isBaseToTable => route == DeliveryRoute.baseToTable;

  bool get isTableToBase => route == DeliveryRoute.tableToBase;

  bool get isIdle => status == DeliveryStatus.idle;

  bool get isMoving => status == DeliveryStatus.moving;

  bool get isDelivered => status == DeliveryStatus.delivered;

  bool get hasError => status == DeliveryStatus.error;
}
