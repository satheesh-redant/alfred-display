import '../../../core/services/ros_service.dart';
import '../model/boot_check_response.dart';

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
  final String statusMessage;
  final bool isRetrying;

  LoadingScreenState({
    required this.step,
    required this.connectionStatus,
    this.bootCheckResponse,
    required this.statusMessage,
    this.isRetrying = false,
  });

  LoadingScreenState copyWith({
    LoadingStep? step,
    ROSConnectionStatus? connectionStatus,
    BootCheckResponse? bootCheckResponse,
    String? statusMessage,
    bool? isRetrying,
  }) {
    return LoadingScreenState(
      step: step ?? this.step,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      bootCheckResponse: bootCheckResponse ?? this.bootCheckResponse,
      statusMessage: statusMessage ?? this.statusMessage,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }
}
