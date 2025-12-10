class BaseResetState {
  final String ackMessage;          // raw ACK text from robot → "SUCCESS", "FAILED", "IN_PROGRESS"
  final bool isSuccess;             // true if SUCCESS
  final bool isInProgress;          // true if waiting
  final bool isFailed;              // true if failed

  BaseResetState({
    required this.ackMessage,
    this.isSuccess = false,
    this.isInProgress = false,
    this.isFailed = false,
  });

  BaseResetState copyWith({
    String? ackMessage,
    bool? isSuccess,
    bool? isInProgress,
    bool? isFailed,
  }) {
    return BaseResetState(
      ackMessage: ackMessage ?? this.ackMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isInProgress: isInProgress ?? this.isInProgress,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}
