
import 'dart:convert';

RouteState routeStateFromJson(String str) =>
    RouteState.fromJson(json.decode(str));

String routeStateToJson(RouteState data) =>
    json.encode(data.toJson());

class RouteState {
  final int tableNumber;
  final int route;

  RouteState({
    required this.tableNumber,
    required this.route,
  });

  factory RouteState.fromJson(Map<String, dynamic> json) => RouteState(
    tableNumber: json["tableNumber"],
    route: json["route"],
  );

  Map<String, dynamic> toJson() => {
    "tableNumber": tableNumber,
    "route": route,
  };
}
