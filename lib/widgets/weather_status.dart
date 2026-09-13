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
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=10'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'DEST-OS-ARES-Tablet-Launcher/1.0',
        },
      );

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);
      final address = data['address'];

      if (address is! Map) {
        return;
      }

      final city = address['city'] ??
          address['town'] ??
          address['municipality'] ??
          address['village'] ??
          address['county'];

      if (city is String && city.isNotEmpty && mounted) {
        setState(() {
          _locationName = city;
        });
      }
    } catch (_) {
      // Konum adı alınamazsa varsayılan "Konum" metni korunur.
    }
  }

  String _weatherDescription(int code) {
    if (code == 0) {
      return 'Açık';
    }

    if (code == 1 || code == 2) {
      return 'Parçalı bulutlu';
    }

    if (code == 3) {
      return 'Kapalı';
    }

    if (code == 45 || code == 48) {
      return 'Sisli';
    }

    if (code >= 51 && code <= 57) {
      return 'Çisenti';
    }

    if (code >= 61 && code <= 67) {
      return 'Yağmurlu';
    }

    if (code >= 71 && code <= 77) {
      return 'Karlı';
    }

    if (code >= 80 && code <= 82) {
      return 'Sağanak yağışlı';
    }

    if (code == 85 || code == 86) {
      return 'Kar sağanağı';
    }

    if (code == 95) {
      return 'Gök gürültülü';
    }

    if (code == 96 || code == 99) {
      return 'Fırtınalı';
    }

    return 'Hava durumu';
  }

  IconData _weatherIconForCode(int code) {
    if (code == 0) {
      return Icons.wb_sunny_outlined;
    }

    if (code == 1 || code == 2) {
      return Icons.wb_cloudy_outlined;
    }

    if (code == 3) {
      return Icons.cloud_outlined;
    }

    if (code == 45 || code == 48) {
      return Icons.foggy;
    }

    if (code >= 51 && code <= 57) {
      return Icons.grain;
    }

    if (code >= 61 && code <= 67) {
      return Icons.water_drop_outlined;
    }

    if (code >= 71 && code <= 77) {
      return Icons.ac_unit;
    }

    if (code >= 80 && code <= 82) {
      return Icons.grain;
    }

    if (code == 85 || code == 86) {
      return Icons.ac_unit;
    }

    if (code == 95 || code == 96 || code == 99) {
      return Icons.thunderstorm_outlined;
    }

    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 8),
            Text('Hava durumu'),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _weatherIcon,
          size: 28,
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _locationName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_temperature != null)
                  Text(
                    '${_temperature!.round()}°C',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (_temperature != null)
                  const SizedBox(width: 6),
                Text(
                  _weatherText,
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
