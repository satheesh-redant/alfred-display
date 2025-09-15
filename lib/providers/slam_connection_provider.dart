import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SlamConnectionStatus {
  disconnected,
  connecting,
  connected,
  subscribed,
  error
}

class SlamConnectionState {
  final SlamConnectionStatus status;
  final String? errorMessage;
  final bool isMapReceiving;
  final bool isPoseReceiving;

  SlamConnectionState({
    required this.status,
    this.errorMessage,
    this.isMapReceiving = false,
    this.isPoseReceiving = false,
  });

  SlamConnectionState copyWith({
    SlamConnectionStatus? status,
    String? errorMessage,
    bool? isMapReceiving,
    bool? isPoseReceiving,
  }) {
    return SlamConnectionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isMapReceiving: isMapReceiving ?? this.isMapReceiving,
      isPoseReceiving: isPoseReceiving ?? this.isPoseReceiving,
    );
  }
}

class SlamConnectionNotifier extends StateNotifier<SlamConnectionState> {
  SlamConnectionNotifier() : super(SlamConnectionState(status: SlamConnectionStatus.disconnected));

  void setConnecting() {
    state = state.copyWith(status: SlamConnectionStatus.connecting);
  }

  void setConnected() {
    state = state.copyWith(status: SlamConnectionStatus.connected, errorMessage: null);
  }

  void setSubscribed() {
    state = state.copyWith(status: SlamConnectionStatus.subscribed);
  }

  void setError(String error) {
    state = state.copyWith(status: SlamConnectionStatus.error, errorMessage: error);
  }

  void setMapReceiving(bool receiving) {
    state = state.copyWith(isMapReceiving: receiving);
  }

  void setPoseReceiving(bool receiving) {
    state = state.copyWith(isPoseReceiving: receiving);
  }

  void reset() {
    state = SlamConnectionState(status: SlamConnectionStatus.disconnected);
  }
}

final slamConnectionProvider = StateNotifierProvider<SlamConnectionNotifier, SlamConnectionState>((ref) {
  return SlamConnectionNotifier();
});
