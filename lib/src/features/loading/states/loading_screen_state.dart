
import '../../../core/services/ros_service.dart';
import '../../../shared/models/boot_check_response.dart';
import '../../../shared/services/operation_mode_service.dart';

enum LoadingStep {
  connecting,
  bootChecking,
  opsMode,
  navigating,
}

class LoadingScreenState {
  final LoadingStep step;
  final ROSConnectionStatus connectionStatus;
  final BootCheckResponse? bootCheckResponse;
  final OperationMode? operationMode;
  final String statusMessage;
  final bool isRetrying;

  LoadingScreenState({
    required this.step,
    required this.connectionStatus,
    this.bootCheckResponse,
    this.operationMode,
    required this.statusMessage,
    this.isRetrying = false,
  });

  LoadingScreenState copyWith({
    LoadingStep? step,
    ROSConnectionStatus? connectionStatus,
    BootCheckResponse? bootCheckResponse,
    OperationMode? operationMode,
    String? statusMessage,
    bool? isRetrying,
  }) {
    return LoadingScreenState(
      step: step ?? this.step,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      bootCheckResponse: bootCheckResponse ?? this.bootCheckResponse,
      operationMode: operationMode ?? this.operationMode,
      statusMessage: statusMessage ?? this.statusMessage,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }
}
