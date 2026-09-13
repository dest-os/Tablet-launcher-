import 'package:flutter/material.dart';

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

class AresHomeScreen extends StatelessWidget {
  const AresHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Text(
            'DEST-OS ARES',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
