import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/core/routes.dart';
import 'package:alfred/view_models/route_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '../../core/toast_utils.dart';
import '../../providers/table_providers.dart';
import '../../view_models/base_point_view_model.dart';
import '../../view_models/operation_view_model.dart';
import '../../view_models/table_view_model.dart';
import '../widgets/button_widget.dart';
import '../widgets/table_grid_button_widget.dart';

class RoutingScreen extends ConsumerStatefulWidget {
  const RoutingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoutingScreenState();
}

class _RoutingScreenState extends ConsumerState<RoutingScreen> {
  int? selectedFromTable;
  int? selectedToTable;
  bool isRoutingMode = false;
  List<String> waypoints = [];

  @override
  void initState() {
    super.initState();
  }

  void _startRouting() {
    if (selectedFromTable != null && selectedToTable != null) {
      print("Starting routing from Table $selectedFromTable to Table $selectedToTable");
      setState(() {
        isRoutingMode = true;
        waypoints.clear();
      });
    }
  }

  void _dismissRoute() {
    setState(() {
      selectedFromTable = null;
      selectedToTable = null;
      isRoutingMode = false;
      waypoints.clear();
    });
  }

  void _addWaypoint() {
    String route = selectedFromTable.toString() + "-" + selectedToTable.toString();
    ref.read(routeVMProvider.notifier).sendRouteData(table: route);
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(
      routeVMProvider,
          (previous, next) {
        if (next.toUpperCase() == ROSConstants.success) {
          setState(() {
            waypoints.add("Waypoint ${waypoints.length + 1}");
          });
        }
      },
    );

    final fromTables = List.generate(11, (index) => index); // 0 to 10
    final toTables = List.generate(10, (index) => index + 1); // 1 to 10

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Text(
                    isRoutingMode
                        ? "Route: ${selectedFromTable == 0 ? 'BASE' : 'Table $selectedFromTable'} → Table ${selectedToTable}"
                        : "Select FROM and TO tables to start planning the route",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isRoutingMode ? const Color(0xFF059669) : const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isRoutingMode) ...[
                    SizedBox(height: 10),
                    Text(
                      "Click Add Waypoint to mark your route",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                ],
              ),
            ),

            // Control Buttons
            if (isRoutingMode)
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _dismissRoute,
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text("Dismiss", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 2,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _addWaypoint,
                      icon: Icon(Icons.add_location, color: Colors.white),
                      label: Text("Add Waypoint", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        elevation: 2,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Waypoints Display (if in routing mode)
            if (isRoutingMode && waypoints.isNotEmpty)
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Waypoints:",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 15),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: waypoints.map((waypoint) {
                            return Chip(
                              label: Text(
                                waypoint,
                                style: TextStyle(color: const Color(0xFF1E40AF)),
                              ),
                              backgroundColor: const Color(0xFFDBEAFE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Main Table Selection (only show if not in routing mode)
            if (!isRoutingMode)
              Expanded(
                child: Row(
                  children: [
                    // FROM Table Section
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15, top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  "FROM TABLE",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 10),

                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.8,
                                  ),
                                  itemCount: fromTables.length,
                                  itemBuilder: (context, index) {
                                    final tableNumber = fromTables[index];
                                    final isSelected = selectedFromTable == tableNumber;
                                    final isBase = tableNumber == 0;

                                    return Container(
                                      child: Stack(
                                        children: [
                                          // Custom FROM table button with blue selection color
                                          _buildFromTableButton(
                                            label: isBase ? "BASE" : tableNumber.toString(),
                                            tableNumber: tableNumber,
                                            isSelected: isSelected,
                                            onPressed: () {
                                              setState(() {
                                                selectedFromTable = tableNumber;
                                              });
                                            },
                                          ),
                                          if (isBase)
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Icon(
                                                Icons.home,
                                                color: const Color(0xFF3B82F6),
                                                size: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 24),

                    // TO Table Section
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15, top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  "TO TABLE",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFB7185),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 10),

                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.8,
                                  ),
                                  itemCount: toTables.length,
                                  itemBuilder: (context, index) {
                                    final tableNumber = toTables[index];
                                    final isSelected = selectedToTable == tableNumber;

                                    return _buildToTableButton(
                                      label: tableNumber.toString(),
                                      tableNumber: tableNumber,
                                      isSelected: isSelected,
                                      onPressed: () {
                                        setState(() {
                                          selectedToTable = tableNumber;
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Start Routing Button (only show when both tables are selected)
            if (!isRoutingMode && selectedFromTable != null && selectedToTable != null)
              Container(
                padding: EdgeInsets.only(top: 24),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startRouting,
                  icon: Icon(Icons.route, color: Colors.white),
                  label: Text(
                    "Start Route Planning: ${selectedFromTable == 0 ? 'BASE' : 'Table $selectedFromTable'} → Table $selectedToTable",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    elevation: 3,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Custom FROM table button with blue selection color
  Widget _buildFromTableButton({
    required String label,
    required int tableNumber,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6) // Blue when selected
                : const Color(0xFFF1F5F9), // Light gray when not selected
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white // White text when selected
                    : const Color(0xFF475569), // Dark gray when not selected
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom TO table button with pink/red selection color
  Widget _buildToTableButton({
    required String label,
    required int tableNumber,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFB7185) // Pink/red when selected
                : const Color(0xFFF1F5F9), // Light gray when not selected
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFB7185)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white // White text when selected
                    : const Color(0xFF475569), // Dark gray when not selected
              ),
            ),
          ),
        ),
      ),
    );
  }
}



