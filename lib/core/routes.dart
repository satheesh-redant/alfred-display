import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/screens/base_point_marking_screen.dart';
import 'package:alfred/presentation/screens/battery_screens/battery_charging_screen.dart';
import 'package:alfred/presentation/screens/battery_screens/shutdown_alert_screen.dart';
import 'package:alfred/presentation/screens/loading_screen.dart';
import 'package:alfred/presentation/screens/mapping_screen.dart';
import 'package:alfred/presentation/screens/routing_screen.dart';
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
        path: AlfredConstants.routeTrainingScreen,  // New Route
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeDeliveryMainScreen,
        builder: (context, state) => const DeliveryMainScreen(),
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
        path: AlfredConstants.routeMappingScreen,
        builder: (context, state) => const MappingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeRoutingScreen,
        builder: (context, state) => const RoutingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeBatteryChargingScreen,
        builder: (context, state) => const BatteryChargingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeShutdownScreen,
        builder: (context, state) => const ShutdownAlertScreen(),
      ),
    ],
    initialLocation: AlfredConstants.routeSplashScreen,
  );
});