import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/screens/base_point_screen.dart';
import 'package:alfred/presentation/screens/delivery_screen.dart';
import 'package:alfred/presentation/screens/loading_screen.dart';
import 'package:alfred/presentation/screens/mapping_screen.dart';
import 'package:alfred/presentation/screens/returning_base_screen.dart';
import 'package:alfred/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/alfred_base_screen.dart';
import '../presentation/screens/alfred_table_screen.dart';
import '../presentation/screens/check_list_screen.dart';
import '../presentation/screens/table_screen.dart';
import 'package:alfred/presentation/screens/base_marking_screen.dart';
import '../presentation/screens/task_complete_screen.dart';



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
        path: AlfredConstants.routeTableScreen,  // New Route
        builder: (context, state) => const TableScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeBaseScreen,
        builder: (context, state) => const BaseScreen(),
      ),
      GoRoute(
        path: '${AlfredConstants.routeTableMoveScreen}/:tableNumber',
        builder: (context, state) => const TableMoveScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeTaskCompleteScreen,
        builder: (context, state) => const TaskCompleteScreen(),
      ),
      GoRoute(
        path: AlfredConstants.routeReturningBaseScreen,
        builder: (context, state) => const ReturningBaseScreen(),
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