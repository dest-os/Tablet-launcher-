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
  IconData _weatherIcon = Icons.cloud_outlined;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _weatherText = 'Konum yok';
            _weatherIcon = Icons.location_off_outlined;
            _loading = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&current=temperature_2m,weather_code'
        '&timezone=auto',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Hava durumu alınamadı');
      }

      final data = jsonDecode(response.body);

      final temperature =
          (data['current']['temperature_2m'] as num).toDouble();

      final weatherCode =
          (data['current']['weather_code'] as num).toInt();

      if (!mounted) return;

      setState(() {
        _temperature = temperature;
        _weatherText = _weatherDescription(weatherCode);
        _weatherIcon = _weatherIconForCode(weatherCode);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _weatherText = 'Hava durumu';
        _weatherIcon = Icons.cloud_outlined;
        _loading = false;
      });
    }
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Açık';
    if (code <= 3) return 'Parçalı bulutlu';
    if (code <= 48) return 'Sisli';
    if (code <= 57) return 'Çiseleme';
    if (code <= 67) return 'Yağmurlu';
    if (code <= 77) return 'Karlı';
    if (code <= 82) return 'Sağanak';
    if (code <= 86) return 'Kar sağanağı';
    if (code >= 95) return 'Fırtınalı';

    return 'Hava durumu';
  }

  IconData _weatherIconForCode(int code) {
    if (code == 0) {
      return Icons.wb_sunny_outlined;
    }

    if (code <= 3) {
      return Icons.cloud_outlined;
    }

    if (code <= 48) {
      return Icons.foggy;
    }

    if (code <= 57) {
      return Icons.grain;
    }

    if (code <= 67) {
      return Icons.water_drop_outlined;
    }

    if (code <= 77) {
      return Icons.ac_unit;
    }

    if (code <= 82) {
      return Icons.umbrella_outlined;
    }

    if (code <= 86) {
      return Icons.ac_unit;
    }

    if (code >= 95) {
      return Icons.thunderstorm_outlined;
    }

    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Text(
        'Hava durumu',
        style: TextStyle(
          color: Colors.white,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _weatherIcon,
          color: Colors.white,
          size: 22,
        ),
        const SizedBox(width: 6),
        Text(
          _temperature == null
              ? _weatherText
              : '${_temperature!.round()}°  $_weatherText',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
