import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/configs/alfred_constants.dart';
import '../../../../shared/models/operation_mode.dart';
import '../../../../shared/providers/system_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loadingScreenViewModelProvider.notifier).startLoadingProcess();
    });

  }

  @override
  Widget build(BuildContext context) {

    ref.listen(loadingScreenViewModelProvider, (previous, next) {
      if (next.step == LoadingStep.opsMode) {
        final mode = ref.read(systemViewModelProvider).currentMode;
        if (mode == OperationMode.mapping) {
          context.go(AlfredConstants.routeMappingScreen);
        } else if (mode == OperationMode.routing) {
          context.go(AlfredConstants.routeRoutingScreen);
        } else if (mode == OperationMode.navigation) {
          context.go(AlfredConstants.routeDeliveryScreen);
        } else {
          print(mode.name.toLowerCase());
        }
      }
    },);

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

}

