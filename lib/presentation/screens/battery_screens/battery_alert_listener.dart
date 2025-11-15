import 'package:alfred/core/toast_utils.dart';
import 'package:alfred/models/battery_state.dart';
import 'package:alfred/presentation/screens/battery_screens/shutdown_alert_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alfred/view_models/battery_view_model.dart';
import 'package:go_router/go_router.dart';

import 'battery_charging_screen.dart';

class BatteryAlertListener extends ConsumerStatefulWidget {
  final Widget child;

  const BatteryAlertListener({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<BatteryAlertListener> createState() =>
      _BatteryAlertListenerState();
}

class _BatteryAlertListenerState extends ConsumerState<BatteryAlertListener> {
  BatteryLevelCategory? _lastCategory;
  bool _hasShownLowWarning = false;

  @override
  Widget build(BuildContext context) {
    final batteryState = ref.watch(batteryViewModelProvider);

    ref.listen<AsyncValue<BatteryState>>(
      batteryViewModelProvider,
          (previous, next) {
        next.whenData((battery) {
          _handleBatteryChanges(battery);
        });
      },
    );

    return batteryState.when(
      data: (battery) {
        // Check if robot is charging - show charging screen
        if (battery.statusEnum == BatteryStatus.charging) {
          return const BatteryChargingScreen();
        }

        // Check if battery is critically low - show shutdown screen
        final percentage = (battery.percentage ?? 0) * 100;
        if (percentage < 2) {
          return const ShutdownAlertScreen();
        }

        // Normal app flow
        return widget.child;
      },
      loading: () => Container(),
      error: (error, _) => Container(),
    );
  }

  void _handleBatteryChanges(BatteryState battery) {
    final percentage = (battery.percentage ?? 0) * 100;
    final category = ref.read(batteryLevelCategoryProvider);
    final isCharging = battery.statusEnum == BatteryStatus.charging;

    // Don't show alerts when charging (already on charging screen)
    if (isCharging) {
      _resetFlags();
      return;
    }

    // Don't show if battery is too low (will show shutdown screen)
    if (percentage < 2) {
      return;
    }

    // Low Battery - Show banner (10-19%)
    if (category == BatteryLevelCategory.low && !_hasShownLowWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowBatteryBanner(battery);
      });
      _hasShownLowWarning = true;
    }

    // Reset flags when battery level improves
    if (percentage >= 20) {
      _hasShownLowWarning = false;
    }

    _lastCategory = category;
  }

  void _resetFlags() {
    _hasShownLowWarning = false;
  }

  void _showLowBatteryBanner(BatteryState battery) {
    final percentage = ((battery.percentage ?? 0) * 100).toInt();

    showLowBatteryWarning(
      context: context,
      batteryPercentage: percentage,
    );
  }
}
