import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/alfred_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      context.pushReplacement(AlfredConstants.routeLoadingScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ResponsiveRowColumn(
          layout: ResponsiveRowColumnType.COLUMN,
          columnMainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResponsiveRowColumnItem(
              child: Image.asset(
                'assets/images/company_logo.png',
                fit: BoxFit.contain, // Or BoxFit.fill based on your image
                height: 126,
                width: 84,
              ),
            ),
            ResponsiveRowColumnItem(
                child: SizedBox(
                  height: 63,
                )),
            ResponsiveRowColumnItem(
              child: Text(
                'Redant Technology',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
