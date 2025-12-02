import 'package:alfred/models/battery_state.dart';
import 'package:alfred/presentation/screens/battery_screens/battery_alert_listener.dart';
import 'package:alfred/presentation/screens/battery_screens/battery_charging_screen.dart';
import 'package:alfred/view_models/battery_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  OverlayEntry? _chargingOverlay;
  bool _isChargingScreenVisible = false;

  @override
  Widget build(BuildContext context) {
    // Listen for charging mode
    ref.listen<AsyncValue<String>>(
      opsVMProvider,
          (previous, next) {
        next.whenData((mode) {
          if (mode.toLowerCase() == 'charging' && !_isChargingScreenVisible) {
            _showChargingScreen();
          } else if (mode.toLowerCase() != 'charging' && _isChargingScreenVisible) {
            _hideChargingScreen();
          }
        });
      },
    );

    // Provide overlay context for the entire app
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => BatteryAlertListener(
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _showChargingScreen() {
    if (_isChargingScreenVisible || !mounted) return;

    setState(() => _isChargingScreenVisible = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final overlay = Overlay.of(context);
      _chargingOverlay = OverlayEntry(
        builder: (context) => _AnimatedChargingShow(
          child: const BatteryChargingScreen(),
        ),
      );
      overlay.insert(_chargingOverlay!);
    });
  }

  void _hideChargingScreen() {
    if (!_isChargingScreenVisible || _chargingOverlay == null) return;

    setState(() => _isChargingScreenVisible = false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chargingOverlay == null || !mounted) return;

      // Create new overlay entry with dismiss animation
      final overlay = Overlay.of(context);
      final oldOverlay = _chargingOverlay!;

      _chargingOverlay = OverlayEntry(
        builder: (context) => _AnimatedChargingDismiss(
          onComplete: () {
            // Remove after animation completes
            if (mounted) {
              Future.delayed(Duration.zero, () {
                try {
                  oldOverlay.remove();
                  oldOverlay.dispose();
                } catch (e) {
                  // Already removed, safe to ignore
                }
              });
            }
          },
          child: const BatteryChargingScreen(),
        ),
      );

      // Replace old with new (animated dismiss)
      overlay.insert(_chargingOverlay!);
      oldOverlay.remove();

      // Clean up after animation
      Future.delayed(const Duration(milliseconds: 350), () {
        if (_chargingOverlay != null) {
          try {
            _chargingOverlay!.remove();
            _chargingOverlay!.dispose();
          } catch (e) {
            // Already removed
          }
          _chargingOverlay = null;
        }
      });
    });
  }

  @override
  void dispose() {
    if (_chargingOverlay != null) {
      try {
        _chargingOverlay!.remove();
        _chargingOverlay!.dispose();
      } catch (e) {
        // Already removed
      }
    }
    super.dispose();
  }
}

// Show animation: Scale + Fade In
class _AnimatedChargingShow extends StatefulWidget {
  final Widget child;

  const _AnimatedChargingShow({
    required this.child,
  });

  @override
  State<_AnimatedChargingShow> createState() => _AnimatedChargingShowState();
}

class _AnimatedChargingShowState extends State<_AnimatedChargingShow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// Dismiss animation: Scale + Fade Out
class _AnimatedChargingDismiss extends StatefulWidget {
  final Widget child;
  final VoidCallback onComplete;

  const _AnimatedChargingDismiss({
    required this.child,
    required this.onComplete,
  });

  @override
  State<_AnimatedChargingDismiss> createState() => _AnimatedChargingDismissState();
}

class _AnimatedChargingDismissState extends State<_AnimatedChargingDismiss>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInCubic,
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
