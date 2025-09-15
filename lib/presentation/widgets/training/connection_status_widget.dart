import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/slam_connection_provider.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(slamConnectionProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(connectionState.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(connectionState.status),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(connectionState.status),
                color: _getStatusColor(connectionState.status),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(connectionState.status),
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(connectionState.status),
                ),
              ),
            ],
          ),
          if (connectionState.status == SlamConnectionStatus.subscribed) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIndicator('Map', connectionState.isMapReceiving),
                const SizedBox(width: 8),
                _buildIndicator('Pose', connectionState.isPoseReceiving),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SlamConnectionStatus status) {
    switch (status) {
      case SlamConnectionStatus.connected:
      case SlamConnectionStatus.subscribed:
        return Colors.green;
      case SlamConnectionStatus.connecting:
        return Colors.orange;
      case SlamConnectionStatus.error:
        return Colors.red;
      case SlamConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SlamConnectionStatus status) {
    switch (status) {
      case SlamConnectionStatus.connected:
      case SlamConnectionStatus.subscribed:
        return Icons.wifi;
      case SlamConnectionStatus.connecting:
        return Icons.wifi_find;
      case SlamConnectionStatus.error:
        return Icons.wifi_off;
      case SlamConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String _getStatusText(SlamConnectionStatus status) {
    switch (status) {
      case SlamConnectionStatus.connected:
        return "Connected";
      case SlamConnectionStatus.connecting:
        return "Connecting...";
      case SlamConnectionStatus.subscribed:
        return "Mapping Active";
      case SlamConnectionStatus.error:
        return "Error";
      case SlamConnectionStatus.disconnected:
        return "Disconnected";
    }
  }
}
