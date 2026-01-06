class PowerStatus {
  final bool isShuttingDown;
  final String message;

  const PowerStatus({
    this.isShuttingDown = false,
    this.message = '',
  });

  factory PowerStatus.fromRos(String ack) {
    final isShuttingDown = ack.toLowerCase().contains('shutting_down') ||
        ack.toLowerCase().contains('shutdown') ||
        ack.toLowerCase().contains('off');

    return PowerStatus(
      isShuttingDown: isShuttingDown,
      message: ack,
    );
  }
}
