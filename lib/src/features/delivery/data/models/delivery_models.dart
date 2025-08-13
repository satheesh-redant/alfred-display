
enum DeliveryProgressStage {
  baseToTable,
  tableToBase,
  baseToTableFinished,
  tableToBaseFinished
}

enum DeliveryState {
  idle,
  selecting,
  moving,
  delivered,
  error
}

class DeliveryData {
  final int? selectedTable;
  final int? route; // 0: base to table, 1: table to base
  final DeliveryState state;
  final String message;
  final DeliveryProgressStage progressStage;

  const DeliveryData({
    this.selectedTable,
    this.route,
    this.state = DeliveryState.idle,
    this.message = '',
    this.progressStage = DeliveryProgressStage.baseToTable,
  });

  DeliveryData copyWith({
    int? selectedTable,
    int? route,
    DeliveryState? state,
    String? message,
    DeliveryProgressStage? progressStage,
  }) {
    return DeliveryData(
      selectedTable: selectedTable ?? this.selectedTable,
      route: route ?? this.route,
      state: state ?? this.state,
      message: message ?? this.message,
      progressStage: progressStage ?? this.progressStage,
    );
  }

  bool get isBaseToTable => route == 0;
  bool get isTableToBase => route == 1;
}

class TableData {
  final int number;
  final bool isAvailable;

  const TableData({
    required this.number,
    this.isAvailable = true,
  });
}
