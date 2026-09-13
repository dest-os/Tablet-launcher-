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

  String _locationName = 'Konum';
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
            _locationName = 'Konum yok';
            _weatherText = 'Konum izni gerekli';
            _weatherIcon = Icons.location_off_outlined;
            _loading = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      await _loadLocationName(
        position.latitude,
        position.longitude,
      );

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

  Future<void> _loadLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$
