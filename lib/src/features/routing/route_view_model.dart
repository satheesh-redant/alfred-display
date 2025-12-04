// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rosbridge/rosbridge.dart';
//
// import '../../core/configs/ros_constants.dart';
// import '../../core/providers/core_providers.dart';
// import '../../core/services/ros_service.dart';
// import '../delivery/data/state/route_state.dart';
// import '../delivery/data/state/route_state.dart' as model;
//
// class RouteViewModel extends StateNotifier<String> {
//
//   final ROSService _rosService;
//   Topic? _topicRoute, _topicRouteAck;
//
//   RouteViewModel(this._rosService) : super('') {
//     print('initiating all route topic');
//     _topicRoute = _rosService.createTopic(
//       ROSConstants.topicRoute,
//       ROSConstants.msgString,
//     );
//
//     _topicRouteAck = _rosService.createTopic(
//       ROSConstants.topicRouteAck,
//       ROSConstants.msgString,
//       throttleRate: 500,
//     );
//     _topicRouteAck!.subscribe(_handlerAck);
//   }
//
//   Future<void> sendRouteData({required int table, required int route}) async {
//     final model.RouteState routeState = model.RouteState(
//       tableNumber: table,
//       route: route,
//     );
//
//     Map<String, dynamic> json = {"data": routeStateToJson(routeState)};
//     print('Publishing route data: $json');
//
//     await _topicRoute!.publish(json);
//   }
//
//   Future<void> _handlerAck(Map<String, dynamic> message) async {
//     print('Route ack data: $message');
//     state = message['data'];
//   }
//
//   @override
//   void dispose() {
//     print('Disposing all route topics');
//     _topicRoute!.unsubscribe();
//     _topicRouteAck!.unsubscribe();
//     state = "";
//   }
//
// }
//
// final routeVMProvider = StateNotifierProvider<RouteViewModel, String>((ref) {
//   final rosService = ref.watch(rosServiceProvider);
//   final routeVM = RouteViewModel(rosService);
//   ref.onDispose(() => routeVM.dispose());
//   return routeVM;
// });
