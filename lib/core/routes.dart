import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/screens/base_point_marking_screen.dart';
import 'package:alfred/presentation/screens/loading_screen.dart';
import 'package:alfred/presentation/screens/mapping_screen.dart';
import 'package:alfred/presentation/screens/delivery_screens/delivery_returning_base_screen.dart';
import 'package:alfred/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/delivery_screens/delivery_main_screen.dart';
import '../presentation/screens/delivery_screens/delivery_in_progress_screen.dart';
import '../presentation/screens/check_list_screen.dart';
import '../presentation/screens/training_screen.dart';
import '../presentation/screens/delivery_screens/delivery_complete_screen.dart';


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
        path: AlfredConstants.routeDeliveryMainScreen,
        builder: (context, state) => const DeliveryMainScreen(),
      ),
      GoRoute(
        path: '${AlfredConstants.routeDeliveryInProgressScreen}/:tableNumber',
        builder: (context, state) => const DeliveryInProgressScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeDeliveryCompleteScreen,
        builder: (context, state) => const DeliveryCompleteScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeDeliveryReturningBaseScreen,
        builder: (context, state) => const DeliveryReturningBaseScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeMappingScreen,
        builder: (context, state) => const MappingScreen(),
      ),
    ],
    initialLocation: AlfredConstants.routeSplashScreen,
  );
});