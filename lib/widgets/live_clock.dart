import 'dart:async';

import 'package:flutter/material.dart';

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late DateTime _now;
  Timer? _timer;

  final List<String> _dayNames = const [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  final List<String> _monthNames = const [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  void initState() {
    super.initState();

    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatTime() {
    return '${_twoDigits(_now.hour)}:${_twoDigits(_now.minute)}';
  }

  String _formatDate() {
    return '${_twoDigits(_now.day)} '
        '${_monthNames[_now.month - 1]} '
        '${_now.year}';
  }

  String _formatDay() {
    return _dayNames[_now.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time_rounded,
          color: Color(0xFF00BFFF),
          size: 34,
        ),
        const SizedBox(width: 12),
        Text(
          _formatTime(),
          style: const TextStyle(
            color: Color(0xFF168CFF),
            fontSize: 38,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 2,
          height: 34,
          color: Color(0xFF00BFFF),
        ),
        const SizedBox(width: 14),
        Text(
          _formatDate(),
          style: const TextStyle(
            color: Color(0xFF00CFFF),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 18),
        Text(
          _formatDay(),
          style: const TextStyle(
            color: Color(0xFF00CFFF),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
