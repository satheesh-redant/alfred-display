
import 'dart:convert';

class RouteState {
  final int route;
  final bool isLoading;
  final bool isMarked;
  final String statusMessage;
  final bool isModeChanged;

  const RouteState({
    this.route = -1,
    this.isLoading = false,
    this.isMarked = false,
    this.statusMessage = '',
    this.isModeChanged = false,
  });

  RouteState copyWith({
    int? route,
    bool? isLoading,
    bool? isMarked,
    String? statusMessage,
    bool? isModeChanged,
  }) {
    return RouteState(
      route: route ?? this.route,
      isLoading: isLoading ?? this.isLoading,
      isMarked: isMarked ?? this.isMarked,
      statusMessage: statusMessage ?? this.statusMessage,
      isModeChanged: isModeChanged ?? this.isModeChanged,
    );
  }
}
