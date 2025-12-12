import 'package:alfred/src/core/services/ros_service.dart';
import 'package:alfred/src/features/battery/presentation/widget/battery_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/core_providers.dart';
import '../../features/battery/provider/battery_provider.dart';


class AlfredAppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const AlfredAppBarWidget({
    Key? key,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(35);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryViewModelProvider);

    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button (if needed)
          if (showBackButton && Navigator.canPop(context)) ...[
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Logo/Brand - wrapped in SizedBox for consistent height
          SvgPicture.asset(
            'assets/images/RubbixRobotix_Logo.svg',
            // Path to your SVG file
            // width: 25,
            height: 17,
          ),
          // SizedBox(
          //   height: 17,
          //   child: Image.asset(
          //     'assets/images/logo_rubbix_robotix.png',
          //     height: 17,
          //     width: 137,
          //     fit: BoxFit.contain,
          //   ),
          // ),

          const SizedBox(width: 14),

          // Separator - centered
          Container(
            height: 20,
            width: 2,
            color: Colors.grey.shade500,
          ),


    const SizedBox(width: 14),

          // Timestamp - with height constraint
          Text(
            _formatDateTime(DateTime.now()),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF101828),
              fontWeight: FontWeight.w500,
              height: 1.0, // Removes extra vertical space from text
            ),
          ),

          const Spacer(),

          // WiFi/Connection Status (if you want to add it back)
          // _ConnectionStatusIcon(ref: ref),
          // const SizedBox(width: 12),

          // Battery Widget - already centered from previous fix
          WidgetBattery(batteryState: batteryState.value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String date = DateFormat('h:mm a, d MMMM').format(dateTime);
    return date.replaceAll('AM', 'am').replaceAll('PM', 'pm');
  }
}

// WiFi/Connection Status Icon
class _ConnectionStatusIcon extends StatelessWidget {
  final WidgetRef ref;

  const _ConnectionStatusIcon({required this.ref});

  @override
  Widget build(BuildContext context) {
    final rosStatus = ref.watch(rosConnectionStateProvider);

    IconData icon;
    Color color;

    switch (rosStatus) {
      case ROSConnectionStatus.connected:
        icon = Icons.wifi_rounded;
        color = Colors.green.shade700;
        break;

      case ROSConnectionStatus.connecting:
        icon = Icons.wifi_rounded;
        color = Colors.orange;
        break;

      case ROSConnectionStatus.error:
        icon = Icons.wifi_off_rounded;
        color = Colors.red;
        break;

      case ROSConnectionStatus.disconnected: // if ROS disconnected/closed
        icon = Icons.wifi_off_rounded;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 20, color: color);
  }
}
