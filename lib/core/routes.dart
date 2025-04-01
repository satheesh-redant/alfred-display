import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/screens/base_point_screen.dart';
import 'package:alfred/presentation/screens/delivery_screen.dart';
import 'package:alfred/presentation/screens/loading_screen.dart';
import 'package:alfred/presentation/screens/mapping_screen.dart';
import 'package:alfred/presentation/alfred_last_screens/alfred_returning_base_screen.dart';
import 'package:alfred/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/alfred_last_screens/alfred_main_screen.dart';
import '../presentation/alfred_last_screens/alfred_progress_screen.dart';
import '../presentation/screens/check_list_screen.dart';
import '../presentation/screens/alfred_training_screen.dart';
import 'package:alfred/presentation/screens/base_point_marker_screen.dart';
import '../presentation/alfred_last_screens/alfred_completion_screen.dart';


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
        path: AlfredConstants.routeBasePointScreen,
        builder: (context, state) => const BasePointScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeBasePointMarkerScreen,  // New Route
        builder: (context, state) => const BasePointMarkerScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeAlfredTrainingScreen,  // New Route
        builder: (context, state) => const AlfredTrainingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeAlfredMainScreen,
        builder: (context, state) => const AlfredMainScreen(),
      ),
      GoRoute(
        path: '${AlfredConstants.routeAlfredProgressScreen}/:tableNumber',
        builder: (context, state) => const AlfredProgressScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeAlfredCompletionScreen,
        builder: (context, state) => const AlfredCompletionScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeAlfredReturningBaseScreen,
        builder: (context, state) => const AlfredReturningBaseScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeMappingScreen,
        builder: (context, state) => const MappingScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeDeliveryScreen,
        builder: (context, state) => const DeliveryScreen(),
      ),
    ],
    initialLocation: AlfredConstants.routeSplashScreen,
  );
});