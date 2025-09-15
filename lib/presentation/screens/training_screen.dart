import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../config/alfred_constants.dart';
import '../../config/ros_constants.dart';
import '../../providers/ros_service_provider.dart';
import '../../view_models/add_table_view_model.dart';
import '../../view_models/slam_mapping_service.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/training/map_display_widget.dart';
import '../widgets/training/connection_status_widget.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  String mappingStatus = "Initializing...";
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure providers are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSlamMapping();
    });
  }

  Future<void> _initializeSlamMapping() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    try {
      // setState(() {
      //   mappingStatus = "Connecting to ROS...";
      // });
      //
      // // Connect to ROS first
      // final rosService = ref.read(rosServiceProvider);
      // await rosService.connect();

      setState(() {
        mappingStatus = "Initializing SLAM service...";
      });

      // Initialize SLAM mapping service (this can now modify other providers)
      await ref.read(slamMappingServiceProvider.notifier).initialize();

      setState(() {
        mappingStatus = "Starting SLAM mapping...";
      });

      // Start SLAM mapping
      await ref.read(slamMappingServiceProvider.notifier).startMapping();

      setState(() {
        mappingStatus = "SLAM mapping active - Drive Alfred around";
      });

    } catch (e) {
      setState(() {
        mappingStatus = "Error: $e";
      });
      print('Error initializing SLAM mapping: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to SLAM mapping service state changes
    ref.listen(slamMappingServiceProvider, (previous, next) {
      if (next.isNotEmpty && mounted) {
        setState(() {
          mappingStatus = next;
        });
      }
    });

    // Listen to add table view model for save map completion
    ref.listen(addTableVMProvider, (previous, next) {
      if (next.toUpperCase() == ROSConstants.success) {
        ref.context.loaderOverlay.hide();
        context.go(AlfredConstants.routeRoutingScreen);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            AppBarWidget(),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 100),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left content - Status and robot image
                        Expanded(
                          flex: 2,
                          child: _buildStatusSection(),
                        ),
                        // Right content - Map display
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 20),
                            child: MapDisplayWidget(
                              onSaveMap: _handleSaveMap,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // _buildSidebar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            "Training Mode",
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E3A59),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            mappingStatus,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // const ConnectionStatusWidget(),
          // const SizedBox(height: 30),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Image.asset(
                "assets/images/alfred_base.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      left: 20,
      top: 0,
      bottom: 0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 80,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2E3A59),
                const Color(0xFF1A2332),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSidebarItem(
                icon: Icons.transform,
                label: 'SLAM\nMapping',
                isActive: true,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _buildSidebarItem(
                icon: Icons.home_outlined,
                label: 'Back to\nMain',
                onTap: () {
                  _cleanup();
                  context.go(AlfredConstants.routeDeliveryMainScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSaveMap() {
    // Use SLAM mapping service to save map
    ref.read(slamMappingServiceProvider.notifier).saveMap();

    // Also trigger the existing add table view model for compatibility
    ref.context.loaderOverlay.show();
    ref.read(addTableVMProvider.notifier).saveMap();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Saving map...",
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _cleanup() {
    ref.read(slamMappingServiceProvider.notifier).stopMapping();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
