import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:alfred/src/features/battery/presentation/screens/soft_shutdown_screen.dart';
import 'package:alfred/src/features/loading/presentation/screens/loading_screen.dart';
import 'package:alfred/src/features/mapping/presentation/screens/mapping_screen.dart';
import 'package:alfred/src/features/splash/presentation/splash_screen.dart';
import 'package:alfred/src/features/delivery/presentation/screens/delivery_main_screen.dart';
import 'package:alfred/src/shared/widgets/app_overlay_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/checklist/presentation/screens/checklist_view.dart';
import '../../features/base/presentation/screens/base_marking_screen.dart';
import '../../features/delivery/presentation/screens/delivery_complete_screen.dart';
import '../../features/delivery/presentation/screens/delivery_progress_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AlfredConstants.routeSplashScreen,
    routes: [
      ShellRoute(
          builder: (context, state, child) {
            return AppOverlayWidget(child: child);
          },
          routes: [
            GoRoute(
              path: AlfredConstants.routeSplashScreen,
              builder: (context, state) => const SplashScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeLoadingScreen,
              builder: (context, state) => const LoadingScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeChecklistScreen,
              builder: (context, state) => const ChecklistScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeBasePointMarkingScreen,
              builder: (context, state) => const BasePointMarkingScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeMappingScreen,
              builder: (context, state) => const MappingScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeDeliveryMainScreen,
              builder: (context, state) => const DeliveryScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeDeliveryInProgressScreen,
              builder: (context, state) => const DeliveryInProgressScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeDeliveryCompleteScreen,
              builder: (context, state) => const DeliveryCompleteScreen(),
            ),
            GoRoute(
              path: AlfredConstants.routeSoftShutdownScreen,
              builder: (context, state) => const SoftShutdownAlertScreen(),
            ),
          ])
    ],
  );
});
