import 'package:flutter/material.dart';

import 'battery_status.dart';
import 'connectivity_status.dart';
import 'live_clock.dart';
import 'weather_status.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        LiveClock(),
        WeatherStatus(),
        ConnectivityStatus(),
        BatteryStatus(),
      ],
    );
  }
}
