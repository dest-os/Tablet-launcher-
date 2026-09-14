import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key});

  @override
  State<BatteryStatus> createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  final Battery _battery = Battery();

  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;

  @override
  void initState() {
    super.initState();

    _loadBatteryInfo();

    _battery.onBatteryStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _batteryState = state;
      });

      _loadBatteryInfo();
    });
  }

  Future<void> _loadBatteryInfo() async {
    final level = await _battery.batteryLevel;

    if (!mounted) return;

    setState(() {
      _batteryLevel = level;
    });
  }

  IconData _batteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }

    if (_batteryLevel >= 90) {
      return Icons.battery_full;
    }

    if (_batteryLevel >= 60) {
      return Icons.battery_5_bar;
    }

    if (_batteryLevel >= 40) {
      return Icons.battery_4_bar;
    }

    if (_batteryLevel >= 20) {
      return Icons.battery_2_bar;
    }

    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: 1.5708,
          child: Icon(
            _batteryIcon(),
            color: const Color(0xFF00BFFF),
            size: 30,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$_batteryLevel%',
          style: const TextStyle(
            color: Color(0xFF00BFFF),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
