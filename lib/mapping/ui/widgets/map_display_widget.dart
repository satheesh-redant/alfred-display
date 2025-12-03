import 'package:alfred/mapping/view_models/mapping_view_model.dart';
import 'package:alfred/view_models/ros_connection_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/map_data.dart';
import '../../models/robot_pose.dart';
import 'live_map_painter.dart';

class MapDisplayWidget extends ConsumerWidget {
  final VoidCallback? onSaveMap;

  const MapDisplayWidget({
    super.key,
    this.onSaveMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mappingState = ref.watch(mappingVMProvider);
    final mapData = mappingState.map;
    final robotPose = mappingState.pose;
    final connectionState = ref.watch(rosConnectionVMProvider);

    return Card(
      elevation: 6,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMapView(mapData, robotPose, connectionState),
            ),
            const SizedBox(height: 16),
            _buildSaveButton(connectionState),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(
      MapData? mapData,
      RobotPose? robotPose,
      ConnectionStatus connectionState,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (connectionState == ConnectionStatus.connected && mapData != null)
              CustomPaint(
                painter: LiveMapPainter(mapData, robotPose),
                child: Container(),
              )
            else
              _buildLoadingView(connectionState),
            _buildMapOverlays(mapData, robotPose),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(ConnectionStatus connectionState) {
    String message;
    IconData icon;
    Color color;

    switch (connectionState) {
      case ConnectionStatus.closed:
        message = "Not connected to ROS";
        icon = Icons.cloud_off;
        color = Colors.orange;
        break;
      case ConnectionStatus.connecting:
        message = "Connecting to ROS...";
        icon = Icons.cloud_sync;
        color = Colors.blue;
        break;
      case ConnectionStatus.connected:
        message = "Subscribing to topics...";
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case ConnectionStatus.error:
        message = "Connection error";
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (connectionState != ConnectionStatus.error)
              CircularProgressIndicator(color: color)
            else
              Icon(icon, color: color, size: 64),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (connectionState == ConnectionStatus.error) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  "Connection error",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapOverlays(MapData? mapData, RobotPose? robotPose) {
    return Stack(
      children: [
        // Map info overlay (top-left)
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mapData != null) ...[
                  _buildInfoRow(Icons.grid_on, "Grid",
                      "${mapData.width} × ${mapData.height}"),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.straighten, "Resolution",
                      "${(mapData.resolution * 100).toStringAsFixed(1)} cm/cell"),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.location_on, "Origin",
                      "(${mapData.originX.toStringAsFixed(2)}, ${mapData.originY.toStringAsFixed(2)})"),
                ] else
                  Text(
                    "No map data",
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Robot pose overlay (bottom-left)
        if (robotPose != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.smart_toy, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "ROBOT POSE",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.arrow_forward, "X",
                      "${robotPose.x.toStringAsFixed(3)} m", Colors.white),
                  const SizedBox(height: 3),
                  _buildInfoRow(Icons.arrow_upward, "Y",
                      "${robotPose.y.toStringAsFixed(3)} m", Colors.white),
                  const SizedBox(height: 3),
                  _buildInfoRow(Icons.ac_unit, "Yaw",
                      "${(robotPose.yaw * 180 / 3.14159).toStringAsFixed(1)}°", Colors.white),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      [Color textColor = Colors.white]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: textColor.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ConnectionStatus connectionState) {
    final isEnabled = connectionState == ConnectionStatus.connected;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onSaveMap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue.shade600 : Colors.grey,
          foregroundColor: Colors.white,
          elevation: isEnabled ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, size: 22),
        label: Text(
          "Save Map",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
