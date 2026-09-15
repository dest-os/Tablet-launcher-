import 'dart:convert';
import 'dart:math' as math;

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

  int _weatherCode = 3;

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
        if (!mounted) return;

        setState(() {
          _locationName = 'Konum yok';
          _weatherText = 'Konum izni gerekli';
          _weatherCode = -1;
          _loading = false;
        });

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
      final current = data['current'];

      final temperature =
          (current['temperature_2m'] as num).toDouble();

      final weatherCode =
          (current['weather_code'] as num).toInt();

      if (!mounted) return;

      setState(() {
        _temperature = temperature;
        _weatherCode = weatherCode;
        _weatherText = _weatherDescription(weatherCode);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _weatherText = 'Hava durumu';
        _weatherCode = 3;
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
      // Konum adı alınamazsa mevcut isim korunur.
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330,
      height: 175,
      child: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF00BFFF),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 92,
                        height: 82,
                        child: CustomPaint(
                          painter: _WeatherPainter(
                            code: _weatherCode,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _locationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF00BFFF),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (_temperature != null)
                              Text(
                                '${_temperature!.round()}°C',
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(height: 3),
                            Text(
                              _weatherText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF00BFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final int code;

  _WeatherPainter({
    required this.code,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final scale = math.min(
      size.width / 92,
      size.height / 82,
    );

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.scale(scale);

    if (code == 0) {
      _drawSunny(canvas);
    } else if (code == 1 || code == 
