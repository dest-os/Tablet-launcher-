import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherStatus extends StatefulWidget {
  const WeatherStatus({super.key});

  @override
  State<WeatherStatus> createState() => _WeatherStatusState();
}

class _WeatherStatusState extends State<WeatherStatus> {
  double? _temperature;
  String _weatherText = 'Hava durumu';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();

        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&current=temperature_2m,weather_code'
        '&temperature_unit=celsius',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);

      final current = data['current'];

      final temperature =
          (current['temperature_2m'] as num).toDouble();

      if (!mounted) return;

      setState(() {
        _temperature = temperature;
        _weatherText = _weatherDescription(
          current['weather_code'] as num,
        );
      });
    } catch (_) {
      // Hava durumu alınamazsa arayüz çalışmaya devam eder.
    }
  }

  String _weatherDescription(num code) {
    final value = code.toInt();

    if (value == 0) return 'Açık';
    if (value <= 3) return 'Parçalı bulutlu';
    if (value <= 48) return 'Sisli';
    if (value <= 67) return 'Yağmurlu';
    if (value <= 77) return 'Karlı';
    if (value <= 82) return 'Sağanak';
    if (value <= 86) return 'Kar yağışı';
    return 'Fırtınalı';
  }

  @override
  Widget build(BuildContext context) {
    if (_temperature == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 6),
          Text(
            'Hava durumu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.cloud,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(width: 6),
        Text(
          '${_temperature!.round()}°C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _weatherText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
