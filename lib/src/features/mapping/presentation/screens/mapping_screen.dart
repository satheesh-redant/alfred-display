import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../../core/configs/alfred_constants.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../providers/mapping_providers.dart';
import '../../view_model/mapping_view_model.dart';
import '../widgets/map_display_widget.dart';
import 'confirmation_dialog.dart';

class MappingScreen extends ConsumerStatefulWidget {
  const MappingScreen({super.key});

  @override
  ConsumerState<MappingScreen> createState() => _MappingScreenState();
}

class _MappingScreenState extends ConsumerState<MappingScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapping();
    });
  }

  Future<void> _initializeMapping() async {
    if (_hasInitialized) return;
    final vm = ref.read(mappingVMProvider.notifier);
    await vm.initialize();
    await vm.startMapping();
    _hasInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    // reflect mapping status changes from VM
    ref.listen(mappingVMProvider, (previous, next) {
      // 1. Print/log only when statusMessage actually changes
      if (previous?.statusMessage != next.statusMessage &&
          next.statusMessage.isNotEmpty) {
        print(next.statusMessage);
      }

      // 2. Handle loading overlay only on isSaving changes
      if (previous?.isSaving != next.isSaving) {
        if (next.isSaving) {
          context.loaderOverlay.show();
        } else {
          context.loaderOverlay.hide();
        }
      }

      // 3. Show "map saved" dialog only on transition false -> true
      final wasSaved = previous?.mapSaved ?? false;
      if (!wasSaved && next.mapSaved) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmationDialog(
              title: "Map Saved Successfully",
              message:
              "Would you like to go to the route planning screen to create navigation routes?",
              onYes: () {
                context.loaderOverlay.show();
                ref.read(mappingVMProvider.notifier).changeMode();
              },
              onNo: () {},
            );
          },
        );
      }

      if(next.isModeChanged) {
        context.go(AlfredConstants.routeRoutingScreen);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AlfredAppBarWidget(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 100),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildStatusSection(),
                        ),
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
                  // _buildSidebar() if you still want it
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
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Image.asset(
                "assets/images/alfred_base_point.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaveMap() {
    // only call VM here
    ref.read(mappingVMProvider.notifier).saveMap();
  }
}

