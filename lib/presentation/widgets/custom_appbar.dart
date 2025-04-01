import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(30);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String _currentTime = "";
  bool _isDarkMode = false;
  Timer? _timer; // Add this to store the timer reference

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Initialize timer when widget is created
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  void _updateTime() {
    if (!mounted) return; // Add safety check

    setState(() {
      _currentTime = DateFormat('hh:mm a, d MMMM').format(DateTime.now());
    });
  }

  void _toggleDarkMode() {
    if (!mounted) return; // Add safety check

    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Dark Mode: ${_isDarkMode ? 'Enabled' : 'Disabled'}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[300],
        toolbarHeight: 45,
        title: Row(
          children: [
            Image.asset(
              "assets/images/ra_logo.png",
              height: 25,
            ),
            SizedBox(width: 20),
            Text(
              _currentTime,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.wifi, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.toggle_on_outlined, color: Colors.grey),
                  onPressed: _toggleDarkMode,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}