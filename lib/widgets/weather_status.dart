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
    if (code == 0) return 'Açık';

    if (code == 1 || code == 2) {
      return 'Parçalı bulutlu';
    }

    if (code == 3) return 'Kapalı';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        if (!width.isFinite || !height.isFinite) {
          return const SizedBox.shrink();
        }

        final horizontalPadding = width * 0.045;
        final verticalPadding = height * 0.055;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
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
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: height * 0.22,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _locationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF00BFFF),
                            fontSize: width * 0.052,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width * 0.34,
                            height: height * 0.58,
                            child: CustomPaint(
                              painter: _WeatherPainter(
                                code: _weatherCode,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: width * 0.035,
                          ),

                          Expanded(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (_temperature != null)
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${_temperature!.round()}°C',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: width * 0.09,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: height * 0.025,
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _weatherText,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color:
                                          const Color(0xFF00BFFF),
                                      fontSize: width * 0.052,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final int code;

  const _WeatherPainter({
    required this.code,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / 90,
      size.height / 70,
    );

    canvas.save();

    canvas.translate(
      size.width / 2,
      size.height / 2,
    );

    canvas.scale(scale);

    if (code == 0) {
      _drawSunny(canvas);
    } else if (code == 1 || code == 2) {
      _drawPartlyCloudy(canvas);
    } else if (code == 3) {
      _drawCloudy(canvas);
    } else if (code == 45 || code == 48) {
      _drawFog(canvas);
    } else if (code >= 51 && code <= 57) {
      _drawRain(canvas, light: true);
    } else if (code >= 61 && code <= 67) {
      _drawRain(canvas);
    } else if (code >= 71 && code <= 77) {
      _drawSnow(canvas);
    } else if (code >= 80 && code <= 82) {
      _drawRain(canvas);
    } else if (code == 85 || code == 86) {
      _drawSnow(canvas);
    } else if (code == 95 ||
        code == 96 ||
        code == 99) {
      _drawStorm(canvas);
    } else {
      _drawCloudy(canvas);
    }

    canvas.restore();
  }

  void _drawSunny(Canvas canvas) {
    final rayPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;

      canvas.drawLine(
        Offset(
          math.cos(angle) * 25,
          math.sin(angle) * 25,
        ),
        Offset(
          math.cos(angle) * 34,
          math.sin(angle) * 34,
        ),
        rayPaint,
      );
    }

    final sunPaint = Paint()
      ..color = const Color(0xFF00BFFF);

    canvas.drawCircle(
      Offset.zero,
      19,
      sunPaint,
    );

    final innerPaint = Paint()
      ..color = const Color(0xFF08131C);

    canvas.drawCircle(
      Offset.zero,
      12,
      innerPaint,
    );
  }

  void _drawPartlyCloudy(Canvas canvas) {
    _drawSun(
      canvas,
      const Offset(-13, -12),
    );

    _drawCloud(
      canvas,
      const Offset(9, 10),
    );
  }

  void _drawCloudy(Canvas canvas) {
    _drawCloud(
      canvas,
      Offset.zero,
    );
  }

  void _drawCloud(
    Canvas canvas,
    Offset offset,
  ) {
    final darkPaint = Paint()
      ..color = const Color(0xFF718B99);

    final lightPaint = Paint()
      ..color = const Color(0xFFB9D5E5);

    canvas.drawCircle(
      Offset(
        offset.dx - 18,
        offset.dy + 8,
      ),
      12,
      darkPaint,
    );

    canvas.drawCircle(
      Offset(
        offset.dx + 3,
        offset.dy + 4,
      ),
      18,
      lightPaint,
    );

    canvas.drawCircle(
      Offset(
        offset.dx + 22,
        offset.dy + 10,
      ),
      13,
      lightPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          offset.dx + 5,
          offset.dy + 15,
        ),
        width: 62,
        height: 25,
      ),
      lightPaint,
    );
  }

  void _drawSun(
    Canvas canvas,
    Offset offset,
  ) {
    final sunPaint = Paint()
      ..color = const Color(0xFF00BFFF);

    canvas.drawCircle(
      offset,
      14,
      sunPaint,
    );

    final rayPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;

      canvas.drawLine(
        Offset(
          offset.dx + math.cos(angle) * 20,
          offset.dy + math.sin(angle) * 20,
        ),
        Offset(
          offset.dx + math.cos(angle) * 27,
          offset.dy + math.sin(angle) * 27,
        ),
        rayPaint,
      );
    }
  }

  void _drawRain(
    Canvas canvas, {
    required bool light,
  }) {
    _drawCloud(
      canvas,
      const Offset(0, -8),
    );

    final rainPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final count = light ? 3 : 4;

    for (int i = 0; i < count; i++) {
      final x = -24.0 + i * 16;

      canvas.drawLine(
        Offset(x, 22),
        Offset(x - 5, 34),
        rainPaint,
      );
    }
  }

  void _drawSnow(Canvas canvas) {
    _drawCloud(
      canvas,
      const Offset(0, -8),
    );

    final snowPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final x = -18.0 + i * 18;
      const y = 28.0;

      canvas.drawLine(
        Offset(x - 5, y),
        Offset(x + 5, y),
        snowPaint,
      );

      canvas.drawLine(
        Offset(x, y - 5),
        Offset(x, y + 5),
        snowPaint,
      );

      canvas.drawLine(
        Offset(x - 4, y - 4),
        Offset(x + 4, y + 4),
        snowPaint,
      );

      canvas.drawLine(
        Offset(x - 4, y + 4),
        Offset(x + 4, y - 4),
        snowPaint,
      );
    }
  }

  void _drawFog(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFB9D5E5)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(-30, -12),
      const Offset(30, -12),
      paint,
    );

    canvas.drawLine(
      const Offset(-25, 0),
      const Offset(35, 0),
      paint,
    );

    canvas.drawLine(
      const Offset(-32, 12),
      const Offset(25, 12),
      paint,
    );

    canvas.drawLine(
      const Offset(-20, 24),
      const Offset(32, 24),
      paint,
    );
  }

  void _drawStorm(Canvas canvas) {
    _drawCloud(
      canvas,
      const Offset(0, -10),
    );

    final lightningPaint = Paint()
      ..color = const Color(0xFF00BFFF);

    final path = Path()
      ..moveTo(5, 15)
      ..lineTo(-5, 15)
      ..lineTo(-13, 30)
      ..lineTo(-3, 28)
      ..lineTo(-8, 43)
      ..lineTo(9, 22)
      ..lineTo(0, 24)
      ..close();

    canvas.drawPath(
      path,
      lightningPaint,
    );

    final rainPaint = Paint()
      ..color = const Color(0xFF00BFFF)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(-22, 25),
      const Offset(-27, 35),
      rainPaint,
    );

    canvas.drawLine(
      const Offset(25, 25),
      const Offset(20, 35),
      rainPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _WeatherPainter oldDelegate,
  ) {
    return oldDelegate.code != code;
  }
}
