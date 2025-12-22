class BasePointState {
  final bool isResetting;        // when reset command is sent
  final bool isResetComplete;    // when ACK received
  final String message;          // shows status message or ACK text

  const BasePointState({
    required this.isResetting,
    required this.isResetComplete,
    required this.message,
  });

  BasePointState copyWith({
    bool? isResetting,
    bool? isResetComplete,
    String? message,
  }) {
    return BasePointState(
      isResetting: isResetting ?? this.isResetting,
      isResetComplete: isResetComplete ?? this.isResetComplete,
      message: message ?? this.message,
    );
  }

  // Initial default states
  factory BasePointState.initial() {
    return const BasePointState(
      isResetting: false,
      isResetComplete: false,
      message: "",
    );
  }
}
