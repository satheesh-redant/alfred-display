import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseViewModel<T> extends StateNotifier<T> {
  BaseViewModel(T initialState) : super(initialState);

  bool _disposed = false;

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      onDispose();
      super.dispose();
    }
  }

  void onDispose() {}

  bool get isDisposed => _disposed;

  void safeUpdateState(T newState) {
    if (!_disposed) {
      state = newState;
    }
  }
}
