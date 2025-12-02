
//new
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ros_service.dart';
import '../../../../core/configs/alfred_constants.dart';
import '../../providers/loading_providers.dart';
import '../../states/loading_screen_state.dart';
import '../widgets/loading_status_widget.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  late final ProviderSubscription _removeListener;

  @override
  void initState() {
    super.initState();

    /// Trigger loading after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadingScreenViewModelProvider.notifier).startLoadingProcess();
    });

    /// Navigation listener – allowed in initState using listenManual
    _removeListener = ref.listenManual(
      loadingScreenViewModelProvider,
          (previous, next) {
        if (next.step == LoadingStep.navigating && next.operationMode != null) {
          print("Navigating to ${next.operationMode} screen");

          if (!mounted) return;

          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;

            if (next.operationMode == OperationMode.delivery) {
              context.go(AlfredConstants.routeDeliveryScreen);
            } else {
              context.go(AlfredConstants.routeChecklistScreen);
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loadingScreenViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 136.h),

            Expanded(
              child: Image.asset(
                'assets/images/loading.png',
                fit: BoxFit.contain,
                height: 488.h,
                width: 953.w,
              ),
            ),

            SizedBox(height: 64.h),

            LoadingStatusWidget(state: state),

            SizedBox(height: 87.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeListener.close(); // remove navigation listener safely
    super.dispose();
  }
}

