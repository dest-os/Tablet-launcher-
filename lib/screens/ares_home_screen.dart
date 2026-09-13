import 'package:flutter/material.dart';

import '../widgets/ares_background.dart';
import '../widgets/live_clock.dart';
import '../widgets/live_calendar.dart';
import '../widgets/weather_status.dart';
import '../widgets/connectivity_status.dart';
import '../widgets/battery_status.dart';

class AresHomeScreen extends StatelessWidget {
  const AresHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  const AresBackground(),

                  // CANLI SAAT / TARİH / GÜN
                  Positioned(
                    left: width * 0.035,
                    top: height * 0.055,
                    width: width * 0.285,
                    height: height * 0.075,
                    child: const Center(
                      child: LiveClock(),
                    ),
                  ),

                  // CANLI TAKVİM
                  Positioned(
                    left: width * 0.195,
                    top: height * 0.205,
                    width: width * 0.185,
                    height: height * 0.245,
                    child: const LiveCalendar(),
                  ),

                  // CANLI HAVA DURUMU
                  Positioned(
                    left: width * 0.635,
                    top: height * 0.205,
                    width: width * 0.205,
                    height: height * 0.245,
                    child: const Center(
                      child: WeatherStatus(),
                    ),
                  ),

                  // CANLI BAĞLANTI DURUMU
                  Positioned(
                    left: width * 0.765,
                    top: height * 0.035,
                    width: width * 0.125,
                    height: height * 0.075,
                    child: const Center(
                      child: ConnectivityStatus(),
                    ),
                  ),

                  // CANLI BATARYA
                  Positioned(
                    left: width * 0.900,
                    top: height * 0.035,
                    width: width * 0.075,
                    height: height * 0.075,
                    child: const Center(
                      child: BatteryStatus(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
