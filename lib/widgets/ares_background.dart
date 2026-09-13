import 'package:flutter/material.dart';

class AresBackground extends StatelessWidget {
  const AresBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: Image(
        image: AssetImage('ares_home_design.png'),
        fit: BoxFit.fill,
      ),
    );
  }
}
