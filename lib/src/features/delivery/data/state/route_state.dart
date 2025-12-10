import 'dart:convert';

RouteState routeStateFromJson(String str) => RouteState.fromJson(json.decode(str));

String routeStateToJson(RouteState data) => json.encode(data.toJson());

enum Status {
  inprogress,
  completed,
  rejected,
  pending,
}

class RouteState {
  int tableNumber;
  // int route;
  Status? status;


  RouteState({
    this.tableNumber = 0,
    // this.route = 0,
    this.status = Status.pending,
  });

  factory RouteState.fromJson(Map<String, dynamic> json) => RouteState(
    tableNumber: json["tableNumber"],
    // route: json["route"],
    status: Status.values.firstWhere((e) => e.name == json["status"]),
  );

  Map<String, dynamic> toJson() => {
    "tableNumber": tableNumber,
    // "route": route,
    "status": status?.name,
  };
}
