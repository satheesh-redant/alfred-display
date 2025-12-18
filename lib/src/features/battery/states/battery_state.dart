import 'package:alfred/src/features/battery/model/battery_model.dart';
import 'package:alfred/src/features/loading/model/operation_mode.dart';

class BatteryState {
  BatteryData? batteryData;
  OperationMode mode;

  BatteryState({
    this.batteryData,
    this.mode = OperationMode.unknown
  });

  BatteryState copyWith({
    BatteryData? batteryData,
    OperationMode? mode,
  }) {
    return BatteryState(
      batteryData: batteryData ?? this.batteryData,
      mode: mode ?? this.mode,
    );
  }
}
