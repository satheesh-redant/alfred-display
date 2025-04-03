import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/view_models/boot_check_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../gen/strings.g.dart';
import '../../models/boot_status_state.dart';
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
      if (next.hardwareOk && next.batteryOk && next.sensorOk) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 2), () {
            context.go(AlfredConstants.routeChecklistScreen);
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: Image.asset(
                'assets/images/loading.png',
                fit: BoxFit.cover, // Or BoxFit.fill based on your image
                // width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
            ),
            const SizedBox(height: 50),
            Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusWidget(context, ref.watch(rosConnectionVMProvider), ref.watch(bootCheckVMProvider)),
                  ],
                )),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(
    BuildContext context,
    ConnectionStatus connectionStatus,
    BootStatusResponse bootStatus,
  ) {
    if (connectionStatus == ConnectionStatus.connecting) {
      return const CircularProgressIndicator();
    } else if (connectionStatus == ConnectionStatus.error) {
      return Text(
        'Initialization Failed',
        style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleMedium, fontSize: 24),
      );
    } else if (connectionStatus == ConnectionStatus.connected) {
      if (!bootStatus.hardwareOk || !bootStatus.batteryOk || !bootStatus.sensorOk) {
        return Text(
          bootStatus.message,
          style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleMedium, fontSize: 24),
        );
      }
      return Text(
        'System Initialized',
        style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleMedium, fontSize: 24),
      );
    }
    return Container();
  }
}
