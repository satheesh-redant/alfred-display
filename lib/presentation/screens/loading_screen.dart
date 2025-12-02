import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/view_models/battery_view_model.dart';
import 'package:alfred/view_models/boot_check_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../models/boot_check_state.dart';
import '../../view_models/ros_connection_view_model.dart';
import 'battery_screens/battery_alert_listener.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rosConnectionVMProvider.notifier).connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rosConnectionVMProvider, (previous, next) {
      if (next == ConnectionStatus.connected) {
        ref.read(bootCheckVMProvider.notifier).init();
        ref.read(batteryViewModelProvider.notifier).subscribe();
        ref.read(opsVMProvider.notifier).getCurrentMode();
      } else {
        print(next);
      }
    });

    // Once boot check is successful, navigate to the next screen.
    ref.listen(bootCheckVMProvider, (previous, next) {
      if (next.overallStatus == 'OK') {
        ref.read(bootCheckVMProvider.notifier).clearTopic();
      }
    });

    ref.listen<AsyncValue<String>>(
      opsVMProvider,
      (previous, next) {
        if (next.value?.toLowerCase() == 'mapping') {
          context.go(AlfredConstants.routeTrainingScreen);
        } else if (next.value?.toLowerCase() == 'navigation') {
          context.go(AlfredConstants.routeDeliveryMainScreen);
        } else if (next.value?.toLowerCase() == 'routing') {
          context.go(AlfredConstants.routeRoutingScreen);
        } /*else if (next.value?.toLowerCase() == 'charging') {
          context.go(AlfredConstants.routeBatteryChargingScreen);
        } */else {
          print(next.value?.toLowerCase());
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: BatteryAlertListener(
          child: Center(
        child: ResponsiveRowColumn(
          layout: ResponsiveRowColumnType.COLUMN,
          columnMainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResponsiveRowColumnItem(
                child: SizedBox(
              height: 136,
            )),
            ResponsiveRowColumnItem(
                child: Expanded(
                    child: Image.asset(
              'assets/images/loading.png',
              fit: BoxFit.cover,
            ))),
            ResponsiveRowColumnItem(
                child: SizedBox(
              height: 64,
            )),
            ResponsiveRowColumnItem(
                child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatusWidget(
                            context,
                            ref.watch(rosConnectionVMProvider),
                            ref.watch(bootCheckVMProvider)),
                      ],
                    ))),
            ResponsiveRowColumnItem(
                child: SizedBox(
              height: 87,
            )),
          ],
        ),
      )),
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
                fontSize: 24,
                color: Colors.red),
          ),
        ],
      );
    } else if (connectionStatus == ConnectionStatus.connected) {
      /*if (bootStatus.overallStatus?.toUpperCase() == 'OK') {
        return Text(
          'All systems are good to go',
          style: GoogleFonts.inter(
              textStyle: Theme.of(context).textTheme.titleMedium,
              fontSize: 24,
              color: Colors.green),
        );
      } else */
      if (bootStatus.overallStatus?.toUpperCase() == 'FAIL') {
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
                  fontSize: 24,
                  color: Colors.red),
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
            fontSize: 24,
            color: Colors.red),
      );
    }
    return Text(
      'Checking System Status...',
      style: GoogleFonts.inter(
          textStyle: Theme.of(context).textTheme.titleMedium, fontSize: 24),
    );
    return Container();
  }
}
