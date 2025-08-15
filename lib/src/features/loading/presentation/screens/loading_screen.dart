import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/configs/alfred_constants.dart';
import '../../../../shared/services/operation_mode_service.dart';
import '../../providers/loading_providers.dart';
import '../../states/loading_screen_state.dart';
import '../widgets/loading_status_widget.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ref.read(loadingScreenViewModelProvider.notifier).startLoadingProcess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loadingScreenViewModelProvider);

    // Listen for navigation
    ref.listen(loadingScreenViewModelProvider, (previous, next) {
      if (next.step == LoadingStep.navigating && next.operationMode != null) {
        print('Navigating to ${next.operationMode} screen');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              if (next.operationMode == OperationMode.delivery) {
                context.go(AlfredConstants.routeDeliveryScreen);
              } else {
                context.go(AlfredConstants.routeChecklistScreen);
              }
            }
          });
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 136.h),

            // Main loading image
            Expanded(
              child: Image.asset(
                'assets/images/loading.png',
                fit: BoxFit.contain,
                height: 488.h,
                width: 953.w,
              ),
            ),

            SizedBox(height: 64.h),

            // Status section - always shows loader and status
            LoadingStatusWidget(state: state),

            SizedBox(height: 87.h),
          ],
        ),
      ),
    );
  }
}
