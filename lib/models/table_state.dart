// // lib/models/table_state.dart
// class TableState {
//   final int tableNumber;
//   final bool isMarked;
//   final bool isSelected;
//   final bool isEnabled;
//   final bool isNewlyAdded;
//   final bool isRemoved;
//
//   TableState({
//     required this.tableNumber,
//     this.isMarked = false,
//     this.isSelected = false,
//     this.isEnabled = true,
//     this.isNewlyAdded = false,
//     this.isRemoved = false,
//   });
//
//   TableState copyWith({
//     int? tableNumber,
//     bool? isMarked,
//     bool? isSelected,
//     bool? isEnabled,
//     bool? isNewlyAdded,
//     bool? isRemoved,
//   }) {
//     return TableState(
//       tableNumber: tableNumber ?? this.tableNumber,
//       isMarked: isMarked ?? this.isMarked,
//       isSelected: isSelected ?? this.isSelected,
//       isEnabled: isEnabled ?? this.isEnabled,
//       isNewlyAdded: isNewlyAdded ?? this.isNewlyAdded,
//       isRemoved: isRemoved ?? this.isRemoved,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is TableState &&
//               runtimeType == other.runtimeType &&
//               tableNumber == other.tableNumber;
//
//   @override
//   int get hashCode => tableNumber.hashCode;
// }


// lib/models/table_state.dart
class TableState {
  final int tableNumber;
  final bool isMarked;
  final bool isSelected;
  final bool isEnabled;
  final bool isNewlyAdded;
  final bool isRemoved;

  TableState({
    required this.tableNumber,
    this.isMarked = false,
    this.isSelected = false,
    this.isEnabled = true,
    this.isNewlyAdded = false,
    this.isRemoved = false,
  });

  TableState copyWith({
    int? tableNumber,
    bool? isMarked,
    bool? isSelected,
    bool? isEnabled,
    bool? isNewlyAdded,
    bool? isRemoved,
  }) {
    return TableState(
      tableNumber: tableNumber ?? this.tableNumber,
      isMarked: isMarked ?? this.isMarked,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
      isNewlyAdded: isNewlyAdded ?? this.isNewlyAdded,
      isRemoved: isRemoved ?? this.isRemoved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TableState &&
              runtimeType == other.runtimeType &&
              tableNumber == other.tableNumber;

  @override
  int get hashCode => tableNumber.hashCode;
}




















// // lib/models/table_state.dart
// class TableState {
//   final int tableNumber;
//   final bool isMarked;
//   final bool isSelected;
//   final bool isEnabled;
//   final bool isNewlyAdded;
//   final bool isRemoved;
//
//   TableState({
//     required this.tableNumber,
//     this.isMarked = false,
//     this.isSelected = false,
//     this.isEnabled = true,
//     this.isNewlyAdded = false,
//     this.isRemoved = false,
//   });
//
//   TableState copyWith({
//     int? tableNumber,
//     bool? isMarked,
//     bool? isSelected,
//     bool? isEnabled,
//     bool? isNewlyAdded,
//     bool? isRemoved,
//   }) {
//     return TableState(
//       tableNumber: tableNumber ?? this.tableNumber,
//       isMarked: isMarked ?? this.isMarked,
//       isSelected: isSelected ?? this.isSelected,
//       isEnabled: isEnabled ?? this.isEnabled,
//       isNewlyAdded: isNewlyAdded ?? this.isNewlyAdded,
//       isRemoved: isRemoved ?? this.isRemoved,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//           other is TableState &&
//               runtimeType == other.runtimeType &&
//               tableNumber == other.tableNumber;
//
//   @override
//   int get hashCode => tableNumber.hashCode;
// }
//










// import 'package:flutter/foundation.dart';
//
// /// Represents the complete state for a single table tile in the UI grid.
// ///
// /// This class is immutable, meaning its values cannot be changed after it's created.
// /// To make changes, a new instance must be created using the `copyWith` method.
// /// This is a core principle of robust state management that prevents bugs.
// @immutable
// class TableState {
//   // --- Core Properties ---
//
//   /// The unique number identifying the table.
//   final int tableNumber;
//
//   /// True if the user has tapped this table to select it for an action (e.g., "Confirm").
//   final bool isSelected;
//
//   // --- Internal State Properties for Detailed Logic ---
//   // These properties handle the complex states required by the application.
//
//   /// True ONLY if the table is permanently saved/marked in the ROS system.
//   final bool isMarkedInROS;
//
//   /// True if the table was just added via the 'Add Table' dialog but has not yet
//   /// been confirmed and saved to ROS. This is used to render a dashed border.
//   final bool isPendingAddition;
//
//   /// True if the user has clicked the remove (-) icon in the current session.
//   /// This acts as a temporary "mask" to hide a table without deleting it from ROS.
//   final bool isLocallyRemoved;
//
//   // --- Main Constructor ---
//   const TableState({
//     required this.tableNumber,
//     required this.isSelected,
//     required this.isMarkedInROS,
//     required this.isPendingAddition,
//     required this.isLocallyRemoved,
//   });
//
//   // --- Computed Properties (Getters) for Simple UI Logic ---
//   // These getters provide simple boolean flags for the UI to use,
//   // based on the more detailed internal state properties. This matches your reference.
//
//   /// **isMarked**: Returns true if the table should be displayed as "marked" (solid color).
//   /// A table is considered marked if it's saved in ROS and has not been
//   /// temporarily removed by the user in this session.
//   bool get isMarked => isMarkedInROS && !isLocallyRemoved;
//
//   /// **isEnabled**: Returns true if the table button should be interactive.
//   /// A button is enabled if it is NOT considered marked.
//   bool get isEnabled => !isMarked;
//
//   // --- `copyWith` Method for Immutable Updates ---
//
//   /// Creates a new copy of this `TableState` with updated values.
//   /// Any properties not provided will retain their old value from the current object.
//   TableState copyWith({
//     int? tableNumber,
//     bool? isSelected,
//     bool? isMarkedInROS,
//     bool? isPendingAddition,
//     bool? isLocallyRemoved,
//   }) {
//     return TableState(
//       tableNumber: tableNumber ?? this.tableNumber,
//       isSelected: isSelected ?? this.isSelected,
//       isMarkedInROS: isMarkedInROS ?? this.isMarkedInROS,
//       isPendingAddition: isPendingAddition ?? this.isPendingAddition,
//       isLocallyRemoved: isLocallyRemoved ?? this.isLocallyRemoved,
//     );
//   }
// }
//













// class TableState {
//   final int tableNumber;
//   final bool isMarked;
//   final bool isSelected;
//   final bool isEnabled;
//
//   TableState({
//     required this.tableNumber,
//     this.isMarked = false,
//     this.isSelected = false,
//     this.isEnabled = true,
//   });
//
//   TableState copyWith({
//     int? tableNumber,
//     bool? isMarked,
//     bool? isSelected,
//     bool? isEnabled,
//   }) {
//     return TableState(
//       tableNumber: tableNumber ?? this.tableNumber,
//       isMarked: isMarked ?? this.isMarked,
//       isSelected: isSelected ?? this.isSelected,
//       isEnabled: isEnabled ?? this.isEnabled,
//     );
//   }
// }