import 'package:alfred/src/core/providers/core_providers.dart';
import 'package:alfred/src/core/services/ros_service.dart';
import 'package:alfred/src/features/mapping/model/map_model.dart';
import 'package:alfred/src/features/mapping/model/robot_pose.dart';
import 'package:alfred/src/features/mapping/presentation/widgets/live_map_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../base/providers/base_provider.dart';
import '../../providers/mapping_providers.dart';
import '../../view_model/mapping_view_model.dart';

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
    final connectionState = ref.watch(rosConnectionStateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mark Table (Only single selection is allowed)',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMapView(mapData, robotPose, connectionState),
          ),
          const SizedBox(height: 16),
          _buildSaveButton(connectionState),
        ],
      ),
    );
  }

  Widget _buildMapView(
    MapData? mapData,
    RobotPose? robotPose,
    AsyncValue<ROSConnectionStatus> connectionState,
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
            connectionState.when(
              loading: () => _buildLoadingView(ROSConnectionStatus.connecting),
              error: (_, __) => _buildLoadingView(ROSConnectionStatus.error),
              data: (status) {
                if (status == ROSConnectionStatus.connected && mapData != null) {
                  return CustomPaint(
                    painter: LiveMapPainter(mapData, robotPose),
                    child: Container(),
                  );
                } else {
                  return _buildLoadingView(status);
                }
              },
            ),
            _buildMapOverlays(mapData, robotPose),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(ROSConnectionStatus connectionState) {
    String message;
    IconData icon;
    Color color;

    switch (connectionState) {
      case ROSConnectionStatus.disconnected:
        message = "Not connected to ROS";
        icon = Icons.cloud_off;
        color = Colors.orange;
        break;
      case ROSConnectionStatus.connecting:
        message = "Connecting to ROS...";
        icon = Icons.cloud_sync;
        color = Colors.blue;
        break;
      case ROSConnectionStatus.connected:
        message = "Subscribing to topics...";
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case ROSConnectionStatus.error:
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
            if (connectionState != ROSConnectionStatus.error)
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
            if (connectionState == ROSConnectionStatus.error) ...[
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
                  _buildInfoRow(
                      Icons.ac_unit,
                      "Yaw",
                      "${(robotPose.yaw * 180 / 3.14159).toStringAsFixed(1)}°",
                      Colors.white),
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

  Widget _buildSaveButton(AsyncValue<ROSConnectionStatus> connectionState) {
    final isEnabled = connectionState.value == ROSConnectionStatus.connected;

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
