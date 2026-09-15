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

  int _weatherCode = -1;

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
            _weatherCode = -1;
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
        _weatherCode = weatherCode;
        _weatherText = _weatherDescription(weatherCode);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _weatherText = 'Hava durumu';
        _weatherCode = -1;
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
      // Konum adı alınamazsa mevcut değer korunur.
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

  Widget _weatherVisual() {
    final code = _weatherCode;

    if (code == 0) {
      return const _SunIcon();
    }

    if (code == 1 || code == 2) {
      return const _PartlyCloudyIcon();
    }

    if (code == 3) {
      return const _CloudIcon();
    }

    if (code == 45 || code == 48) {
      return const _FogIcon();
    }

    if (code >= 51 && code <= 57) {
      return const _DrizzleIcon();
    }

    if (code >= 61 && code <= 67) {
      return const _RainIcon();
    }

    if (code >= 71 && code <= 77) {
      return const _SnowIcon();
    }

    if (code >= 80 && code <= 82) {
      return const _RainIcon();
    }

    if (code == 85 || code == 86) {
      return const _SnowIcon();
    }

    if (code == 95 || code == 96 || code == 99) {
      return const _StormIcon();
    }

    return const _CloudIcon();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 300,
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF00BFFF),
          ),
        ),
      );
    }

    return SizedBox(
      width: 330,
      height: 175,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 105,
            height: 105,
            child: _weatherVisual(),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _locationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF00CFFF),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                if (_temperature != null)
                  Text(
                    '${_temperature!.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  _weatherText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF00BFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SunIcon extends StatelessWidget {
  const _SunIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SunPainter(),
    );
  }
}

class _PartlyCloudyIcon extends StatelessWidget {
  const _PartlyCloudyIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PartlyCloudyPainter(),
    );
  }
}

class _CloudIcon extends StatelessWidget {
  const _CloudIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CloudPainter(),
    );
  }
}

class _FogIcon extends StatelessWidget {
  const _FogIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FogPainter(),
    );
  }
}

class _DrizzleIcon extends StatelessWidget {
  const _DrizzleIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainPainter(light: true),
    );
  }
}

class _RainIcon extends StatelessWidget {
  const _RainIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RainPainter(),
    );
  }
}

class _SnowIcon extends StatelessWidget {
  const _SnowIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SnowPainter(),
    );
  }
}

class _StormIcon extends StatelessWidget {
  const _StormIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StormPainter(),
    );
  }
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.48,
      size.height * 0.45,
    );

    final radius = size.width * 0.20;

    final sunPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sunPaint);

    final rayPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * 3.1415926535 / 4;

      final start = Offset(
        center.dx + radius * 1.45 * _cos(angle),
        center.dy + radius * 1.45 * _sin(angle),
      );

      final end = Offset(
        center.dx + radius * 2.05 * _cos(angle),
        center.dy + radius * 2.05 * _sin(angle),
      );

      canvas.drawLine(start, end, rayPaint);
    }
  }

  double _cos(double value) {
    return _trig(value, true);
  }

  double _sin(double value) {
    return _trig(value, false);
  }

  double _trig(double value, bool cosine) {
    if (cosine) {
      if (value == 0) return 1;
      if (value == 1.57079632675) return 0;
      if (value == 3.1415926535) return -1;
      if (value == 4.71238898025) return 0;
      return 0;
    }

    if (value == 0) return 0;
    if (value == 1.57079632675) return 1;
    if (value == 3.1415926535) return 0;
    if (value == 4.71238898025) return -1;
    return 0;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB9D7E8)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFF78909C)
      ..style = PaintingStyle.fill;

    final base = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.13,
        size.height * 0.47,
        size.width * 0.74,
        size.height * 0.27,
      ),
      const Radius.circular(24),
    );

    canvas.drawRRect(base, shadowPaint);

    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.47),
      size.width * 0.19,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.40),
      size.width * 0.24,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.50),
      size.width * 0.16,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _PartlyCloudyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sunCenter = Offset(
      size.width * 0.35,
      size.height * 0.34,
    );

    final sunPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      sunCenter,
      size.width * 0.18,
      sunPaint,
    );

    final cloudPaint = Paint()
      ..color = const Color(0xFFB9D7E8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.53, size.height * 0.55),
      size.width * 0.22,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.70, size.height * 0.52),
      size.width * 0.17,
      cloudPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.28,
          size.height * 0.53,
          size.width * 0.58,
          size.height * 0.22,
        ),
        const Radius.circular(20),
      ),
      cloudPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _FogPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.30 + i * 0.14);

      canvas.drawLine(
        Offset(size.width * 0.18, y),
        Offset(size.width * 0.82, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _RainPainter extends CustomPainter {
  final bool light;

  _RainPainter({
    this.light = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.39),
      size.width * 0.20,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.38),
      size.width * 0.22,
      cloudPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.20,
          size.height * 0.43,
          size.width * 0.63,
          size.height * 0.25,
        ),
        const Radius.circular(20),
      ),
      cloudPaint,
    );

    final rainPaint = Paint()
      ..color = const Color(0xFF29B6F6)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final count = light ? 3 : 4;

    for (int i = 0; i < count; i++) {
      final x = size.width * (0.31 + i * 0.14);

      canvas.drawLine(
        Offset(x, size.height * 0.76),
        Offset(x - 5, size.height * 0.91),
        rainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _SnowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.38),
      size.width * 0.20,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.38),
      size.width * 0.22,
      cloudPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.19,
          size.height * 0.43,
          size.width * 0.64,
          size.height * 0.24,
        ),
        const Radius.circular(20),
      ),
      cloudPaint,
    );

    final snowPaint = Paint()
      ..color = const Color(0xFFE1F5FE)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.34, size.height * 0.80),
      Offset(size.width * 0.50, size.height * 0.87),
      Offset(size.width * 0.66, size.height * 0.80),
    ];

    for (final point in points) {
      canvas.drawCircle(point, 5, snowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _StormPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFF607D8B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.35),
      size.width * 0.21,
      cloudPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.36),
      size.width * 0.23,
      cloudPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.18,
          size.height * 0.40,
          size.width * 0.66,
          size.height * 0.25,
        ),
        const Radius.circular(20),
      ),
      cloudPaint,
    );

    final lightning = Paint()
      ..color = const Color(0xFFFFD740)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.53, size.height * 0.63)
      ..lineTo(size.width * 0.40, size.height * 0.84)
      ..lineTo(size.width * 0.52, size.height * 0.81)
      ..lineTo(size.width * 0.45, size.height * 0.98)
      ..lineTo(size.width * 0.68, size.height * 0.70)
      ..lineTo(size.width * 0.55, size.height * 0.73)
      ..close();

    canvas.drawPath(path, lightning);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
