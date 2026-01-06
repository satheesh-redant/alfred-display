import 'package:alfred/src/shared/models/power_off_status.dart';

import '../models/operation_mode.dart';

class SystemState {
  final bool isPoweringOff;
  final bool isChangingMode;
  final OperationMode currentMode;
  final PowerStatus? powerStatus;
  final bool isConnected;
  final String statusMessage;

  const SystemState({
    this.isPoweringOff = false,
    this.isChangingMode = false,
    this.currentMode = OperationMode.unknown,
    this.powerStatus,
    this.isConnected = false,
    this.statusMessage = '',
  });

  SystemState copyWith({
    bool? isPoweringOff,
    bool? isChangingMode,
    OperationMode? currentMode,
    PowerStatus? powerStatus,
    bool? isConnected,
    String? statusMessage,
  }) {
    return SystemState(
      isPoweringOff: isPoweringOff ?? this.isPoweringOff,
      isChangingMode: isChangingMode ?? this.isChangingMode,
      currentMode: currentMode ?? this.currentMode,
      powerStatus: powerStatus ?? this.powerStatus,
      isConnected: isConnected ?? this.isConnected,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  bool get isLoading => isPoweringOff || isChangingMode;
}
