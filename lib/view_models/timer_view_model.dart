import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// State class for timer
class TimerState {
  final String currentTime;

  TimerState({
    this.currentTime = "",
  });

  TimerState copyWith({
    String? currentTime,
  }) {
    return TimerState(
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

class TimerViewModel extends StateNotifier<TimerState> {
  TimerViewModel() : super(TimerState()) {
    _init();
  }

  Timer? _timer;

  void _init() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm').format(now);
    final period = now.hour < 12 ? 'am' : 'pm';
    final dateString = DateFormat('d MMMM').format(now);

    state = state.copyWith(
      currentTime: '$timeString $period, $dateString',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider for timer
final timerProvider =
StateNotifierProvider<TimerViewModel, TimerState>(
      (ref) => TimerViewModel(),
);