import 'package:flutter/material.dart';

import '../widgets/ares_background.dart';

class AresHomeScreen extends StatelessWidget {
  const AresHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Stack(
            fit: StackFit.expand,
            children: const [
              AresBackground(),
            ],
          ),
        ),
      ),
    );
  }
}
