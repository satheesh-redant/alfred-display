import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/map_provider.dart';
import '../../../providers/robot_pose_provider.dart';
import '../../../providers/slam_connection_provider.dart';
import 'live_map_painter.dart';

class MapDisplayWidget extends ConsumerWidget {
  final VoidCallback? onSaveMap;

  const MapDisplayWidget({
    super.key,
    this.onSaveMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapData = ref.watch(mapProvider);
    final robotPose = ref.watch(robotPoseProvider);
    final connectionState = ref.watch(slamConnectionProvider);

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
            // _buildHeader(),
            // const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMapView(mapData, robotPose, connectionState),
                  ),
                  const SizedBox(height: 20),
                  _buildSaveButton(connectionState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "LIVE SLAM MAP",
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMapView(MapData? mapData, RobotPose? robotPose, SlamConnectionState connectionState) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[4],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: mapData != null
                  ? CustomPaint(
                painter: LiveMapPainter(mapData, robotPose),
                child: Container(),
              )
                  : _buildLoadingView(connectionState),
            ),
          ),
          _buildMapOverlays(mapData, robotPose),
        ],
      ),
    );
  }

  Widget _buildLoadingView(SlamConnectionState connectionState) {
    String message;
    switch (connectionState.status) {
      case SlamConnectionStatus.disconnected:
        message = "Not connected to ROS";
        break;
      case SlamConnectionStatus.connecting:
        message = "Connecting to ROS...";
        break;
      case SlamConnectionStatus.connected:
        message = "Subscribing to topics...";
        break;
      case SlamConnectionStatus.subscribed:
        message = "Waiting for map data...";
        break;
      case SlamConnectionStatus.error:
        message = "Connection error";
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (connectionState.status != SlamConnectionStatus.error)
            CircularProgressIndicator(color: Colors.blue),
          if (connectionState.status == SlamConnectionStatus.error)
            Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (connectionState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              connectionState.errorMessage!,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapOverlays(MapData? mapData, RobotPose? robotPose) {
    return Stack(
      children: [
        // Map info
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              mapData != null
                  ? "Resolution: ${mapData.resolution.toStringAsFixed(3)}m/px\n${mapData.width}x${mapData.height} grid"
                  : "No map data",
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Robot pose info
        if (robotPose != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                robotPose.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton(SlamConnectionState connectionState) {
    final isEnabled = connectionState.status == SlamConnectionStatus.subscribed;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onSaveMap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue.shade600 : Colors.grey,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, size: 20),
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
