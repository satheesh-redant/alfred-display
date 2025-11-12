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
  bool _hasShownCriticalWarning = false;
  bool _hasShownCriticalDialog = false;

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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Text('Battery Error: $error'),
        ),
      ),
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

    // Critical Low - Show confirmation dialog (5-9%)
    if (category == BatteryLevelCategory.criticalLow &&
        percentage >= 5 &&
        percentage < 10 &&
        !_hasShownCriticalDialog) {
      // Use WidgetsBinding to ensure dialog shows after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCriticalConfirmationDialog(battery);
      });
      _hasShownCriticalDialog = true;
    }

    // Critical Low Warning - Show warning dialog (< 10%)
    if (category == BatteryLevelCategory.criticalLow &&
        percentage < 5 &&
        !_hasShownCriticalWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCriticalWarningDialog(battery);
      });
      _hasShownCriticalWarning = true;
    }

    // Low Battery - Show banner (10-19%)
    if (category == BatteryLevelCategory.low && !_hasShownLowWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowBatteryBanner(battery);
      });
      _hasShownLowWarning = true;
    }

    // Battery Health Issues
    if (battery.healthEnum != BatteryHealth.good) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showHealthWarning(battery);
      });
    }

    // Reset flags when battery level improves
    if (percentage >= 20) {
      _hasShownLowWarning = false;
      _hasShownCriticalWarning = false;
      _hasShownCriticalDialog = false;
    }

    _lastCategory = category;
  }

  void _resetFlags() {
    _hasShownLowWarning = false;
    _hasShownCriticalWarning = false;
    _hasShownCriticalDialog = false;
  }

  void _showCriticalConfirmationDialog(BatteryState battery) {
    if (!mounted) return;

    final estimatedTime =
        ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            size: 56, color: Colors.red),
        title: const Text(
          'Are you sure you want to continue for service?',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estimated Run Time: ${estimatedTime ?? 0} min',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Battery: ${((battery.percentage ?? 0) * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showCriticalWarningDialog(BatteryState battery) {
    if (!mounted) return;

    final estimatedTime =
        ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.battery_alert, size: 56, color: Colors.red),
        title: const Text(
          'Critically Low Battery < 10%',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Estimated Run Time: ${estimatedTime ?? 0} min',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please plug in the charger to avoid shutdown',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _showLowBatteryBanner(BatteryState battery) {
    final percentage = ((battery.percentage ?? 0) * 100).toInt();

    showLowBatteryWarning(
      context: context,
      batteryPercentage: percentage,
    );
  }

  void _showHealthWarning(BatteryState battery) {
    if (!mounted) return;

    if (battery.healthEnum == BatteryHealth.overheat ||
        battery.healthEnum == BatteryHealth.cold) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Battery Health Warning: ${battery.healthLabel}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }
}
