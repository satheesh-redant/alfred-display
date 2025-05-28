// To parse this JSON data, do
//
//     final tableData = tableDataFromJson(jsonString);

import 'dart:convert';

List<TableData> tableDataFromJson(String str) => List<TableData>.from(json.decode(str).map((x) => TableData.fromJson(x)));

String tableDataToJson(List<TableData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TableData {
  int? table;
  double? x;
  double? y;
  int? yaw;

  TableData({
    this.table,
    this.x,
    this.y,
    this.yaw,
  });

  factory TableData.fromJson(Map<String, dynamic> json) => TableData(
    table: json["table"],
    x: json["x"]?.toDouble(),
    y: json["y"]?.toDouble(),
    yaw: json["yaw"],
  );

  Map<String, dynamic> toJson() => {
    "table": table,
    "x": x,
    "y": y,
    "yaw": yaw,
  };
}
