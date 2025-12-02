import 'package:alfred/src/core/configs/alfred_constants.dart';
// import 'package:alfred/presentation/screens/base_point_marking_screen.dart';
import 'package:alfred/src/features/loading/presentation/screens/loading_screen.dart';
import 'package:alfred/presentation/screens/mapping_screen.dart';
import 'package:alfred/presentation/screens/routing_screen.dart';
import 'package:alfred/src/features/splash/presentation/splash_screen.dart';
import 'package:alfred/src/features/delivery/presentation/screens/delivery_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/checklist/presentation/screens/checklist_view.dart';
import '../../../presentation/screens/training_screen.dart';
import '../../features/base/presentation/screens/base_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
        path: AlfredConstants.routeTrainingScreen,
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeDeliveryScreen,
        builder: (context, state) => const DeliveryScreen(),
      ),
      // GoRoute(
      //   path: AlfredConstants.routeDeliveryInProgressScreen,
      //   builder: (context, state) => const DeliveryProgressScreen(),
      // ),
      // GoRoute(
      //   path: AlfredConstants.routeDeliveryCompleteScreen,
      //   builder: (context, state) => const DeliveryCompleteScreen(),
      // ),
      // GoRoute(
      //   path: AlfredConstants.routeDeliveryReturningBaseScreen,
      //   builder: (context, state) => const DeliveryReturningBaseScreen(),
      // ),
      GoRoute(
        path: AlfredConstants.routeMappingScreen,
        builder: (context, state) => const MappingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeRoutingScreen,
        builder: (context, state) => const RoutingScreen(),
      ),
    ],
    initialLocation: AlfredConstants.routeSplashScreen,
  );
});