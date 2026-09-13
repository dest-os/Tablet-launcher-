import 'package:flutter/material.dart';

import '../widgets/ares_background.dart';
import '../widgets/live_clock.dart';
import '../widgets/live_calendar.dart';
import '../widgets/weather_status.dart';
import '../widgets/connectivity_status.dart';
import '../widgets/battery_status.dart';
import '../widgets/folder_content.dart';

class AresHomeScreen extends StatelessWidget {
  const AresHomeScreen({super.key});

  void _openFolder(
    BuildContext context,
    String folderName,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF10151B),
          insetPadding: const EdgeInsets.all(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            width: 900,
            height: 600,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FolderContent(
                folderName: folderName,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _folderArea(
    BuildContext context,
    String folderName,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _openFolder(
          context,
          folderName,
        );
      },
      child: const SizedBox.expand(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  const AresBackground(),

                  // CANLI SAAT / TARİH / GÜN
                  Positioned(
                    left: width * 0.035,
                    top: height * 0.055,
                    width: width * 0.285,
                    height: height * 0.075,
                    child: const Center(
                      child: LiveClock(),
                    ),
                  ),

                  // CANLI TAKVİM
                  Positioned(
                    left: width * 0.195,
                    top: height * 0.205,
                    width: width * 0.185,
                    height: height * 0.245,
                    child: const LiveCalendar(),
                  ),

                  // CANLI HAVA DURUMU
                  Positioned(
                    left: width * 0.635,
                    top: height * 0.205,
                    width: width * 0.205,
                    height: height * 0.245,
                    child: const Center(
                      child: WeatherStatus(),
                    ),
                  ),

                  // CANLI BAĞLANTI DURUMU
                  Positioned(
                    left: width * 0.765,
                    top: height * 0.035,
                    width: width * 0.125,
                    height: height * 0.075,
                    child: const Center(
                      child: ConnectivityStatus(),
                    ),
                  ),

                  // CANLI BATARYA
                  Positioned(
                    left: width * 0.900,
                    top: height * 0.035,
                    width: width * 0.075,
                    height: height * 0.075,
                    child: const Center(
                      child: BatteryStatus(),
                    ),
                  ),

                  // SOSYAL
                  Positioned(
                    left: width * 0.035,
                    top: height * 0.700,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'SOSYAL',
                    ),
                  ),

                  // OYUNLAR
                  Positioned(
                    left: width * 0.275,
                    top: height * 0.700,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'OYUNLAR',
                    ),
                  ),

                  // MEDYA
                  Positioned(
                    left: width * 0.515,
                    top: height * 0.700,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'MEDYA',
                    ),
                  ),

                  // ARAÇLAR
                  Positioned(
                    left: width * 0.755,
                    top: height * 0.700,
                    width: width * 0.210,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'ARAÇLAR',
                    ),
                  ),

                  // İŞ
                  Positioned(
                    left: width * 0.035,
                    top: height * 0.835,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'İŞ',
                    ),
                  ),

                  // SİSTEM
                  Positioned(
                    left: width * 0.275,
                    top: height * 0.835,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'SİSTEM',
                    ),
                  ),

                  // İNTERNET
                  Positioned(
                    left: width * 0.515,
                    top: height * 0.835,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'İNTERNET',
                    ),
                  ),

                  // DİĞER
                  Positioned(
                    left: width * 0.755,
                    top: height * 0.835,
                    width: width * 0.210,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'DİĞER',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
