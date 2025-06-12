
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/view_models/boot_check_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/boot_check_state.dart';
import '../../view_models/ros_connection_view_model.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger ROS connection.
    Future.delayed(const Duration(seconds: 2), () {
      ref.read(rosConnectionVMProvider.notifier).connect();
      if (ref.context.mounted) {
        context.go(AlfredConstants.routeChecklistScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rosConnectionVMProvider, (previous, next) {
      if (next == ConnectionStatus.connected) {
        ref.read(bootCheckVMProvider.notifier).init();
      }
    });
    // Once boot check is successful, navigate to the next screen.
    ref.listen(bootCheckVMProvider, (previous, next) {
      if (next.overallStatus == 'OK') {
        ref.read(bootCheckVMProvider.notifier).clearTopic();
        ref.read(opsVMProvider.notifier).getCurrentOp();
      }
    });
    ref.listen(
      opsVMProvider,
          (previous, next) {
        ref.read(opsVMProvider.notifier).unsubscribe();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              if (next == 'delivery') {
                context.go(AlfredConstants.routeDeliveryMainScreen);
              } else {
                context.go(AlfredConstants.routeChecklistScreen);
              }
            }
          });
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 136.h), // Scaled spacing
            Expanded(
              child: Image.asset(
                'assets/images/loading.png',
                fit: BoxFit.contain, // Changed to contain for consistent scaling
                height: 488.h, // Scaled height (adjust to match design)
                width: 953.w, // Scaled width (adjust to match design)
              ),
            ),
            SizedBox(height: 64.h), // Scaled spacing
            Padding(
              padding: EdgeInsets.only(top: 10.h), // Scaled padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusWidget(
                    context,
                    ref.watch(rosConnectionVMProvider),
                    ref.watch(bootCheckVMProvider),
                  ),
                ],
              ),
            ),
            SizedBox(height: 87.h), // Scaled spacing
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(
      BuildContext context,
      ConnectionStatus connectionStatus,
      BootCheckResponse bootStatus,
      ) {
    if (connectionStatus == ConnectionStatus.connecting) {
      return const CircularProgressIndicator();
    } else if (connectionStatus == ConnectionStatus.error) {
      return Column(
        children: [
          Text(
            'Communication Failed',
            style: GoogleFonts.inter(
              textStyle: Theme.of(context).textTheme.titleMedium,
              fontSize: 24.sp, // Scaled font size
              color: Colors.red,
            ),
          ),
        ],
      );
    } else if (connectionStatus == ConnectionStatus.connected) {
      if (bootStatus.overallStatus == 'OK') {
        return Text(
          'All systems are good to go',
          style: GoogleFonts.inter(
            textStyle: Theme.of(context).textTheme.titleMedium,
            fontSize: 24.sp, // Scaled font size
            color: Colors.green,
          ),
        );
      } else if (bootStatus.overallStatus == 'FAIL') {
        String msg = bootStatus.message;
        for (var check in bootStatus.checks!) {
          if (check.status == 'FAIL') {
            msg += '(${check.error!})';
          }
        }
        return Column(
          children: [
            Text(
              msg,
              style: GoogleFonts.inter(
                textStyle: Theme.of(context).textTheme.titleMedium,
                fontSize: 24.sp, // Scaled font size
                color: Colors.red,
              ),
            ),
          ],
        );
      } else {
        return const CircularProgressIndicator();
      }
    } else if (connectionStatus == ConnectionStatus.closed) {
      return Text(
        'Connection closed',
        style: GoogleFonts.inter(
          textStyle: Theme.of(context).textTheme.titleMedium,
          fontSize: 24.sp, // Scaled font size
          color: Colors.red,
        ),
      );
    }
    return Text(
      'Checking System Status...',
      style: GoogleFonts.inter(
        textStyle: Theme.of(context).textTheme.titleMedium,
        fontSize: 24.sp, // Scaled font size
      ),
    );
  }
}

