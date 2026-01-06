import '../../../../core/helpers/toast_utils.dart';
import '../../provider/battery_provider.dart';
import '../../states/battery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shutdown_alert_screen.dart';

class BatteryAlertListener extends ConsumerStatefulWidget {
  final Widget child;

  const BatteryAlertListener({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<BatteryAlertListener> createState() =>
      _BatteryAlertListenerState();
}

class _BatteryAlertListenerState extends ConsumerState<BatteryAlertListener> {
  bool _hasShownLowWarning = false;

  @override
  Widget build(BuildContext context) {
    final batteryState = ref.watch(batteryViewModelProvider);

    // Listen to battery changes for low battery warnings
    ref.listen<AsyncValue<BatteryState>>(
      batteryViewModelProvider,
          (previous, next) {
        next.whenData((battery) {
          _handleBatteryChanges();
        });
      },
    );

    // Handle shutdown screen
    return batteryState.when(
      data: (battery) {
        final percentage = ref.read(batteryPercentageProvider).round();
        if (percentage >= 0 && percentage < 2) {
          return const ShutdownAlertScreen();
        }
        return widget.child;
      },
      loading: () => widget.child,
      error: (error, _) {
        print('Battery error: $error');
        return widget.child;
      },
    );
  }

  void _handleBatteryChanges() {
    final percentage = ref.read(batteryPercentageProvider).round();
    final category = ref.read(batteryLevelCategoryProvider);

    if (percentage < 2) return;

    // Low Battery - Show banner (10-19%)
    if (category == BatteryLevelCategory.low && !_hasShownLowWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowBatteryBanner();
      });
      _hasShownLowWarning = true;
    }

    // Reset flags when battery level improves
    if (percentage >= 20) {
      _hasShownLowWarning = false;
    }
  }

  void _showLowBatteryBanner() {
    final percentage = ref.read(batteryPercentageProvider).round();
    showLowBatteryWarning(
      context: context,
      batteryPercentage: percentage,
    );
  }
}
