import 'package:flutter/material.dart';

import 'screens/ares_home_screen.dart';

void main() {
  runApp(const DestOsAresLauncher());
}

class DestOsAresLauncher extends StatelessWidget {
  const DestOsAresLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DEST-OS ARES',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const AresHomeScreen(),
    );
  }
}
