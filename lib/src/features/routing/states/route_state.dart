class RouteState {
  final int route;
  final bool isLoading;
  final bool isMarked;
  final String statusMessage;

  const RouteState({
    this.route = -1,
    this.isLoading = false,
    this.isMarked = false,
    this.statusMessage = '',
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
    );
  }
}
