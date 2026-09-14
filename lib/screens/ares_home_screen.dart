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

  Widget _panelCover({
    required double left,
    required double top,
    required double width,
    required double height,
    double radius = 4,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
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

                  // Statik görseldeki canlı olarak değişecek metinlerin yalnızca
                  // iç alanlarını temizle; çerçeveler ve diğer tasarım korunur.
                  _panelCover(
                    left: width * 0.050,
                    top: height * 0.060,
                    width: width * 0.260,
                    height: height * 0.050,
                  ),
                  _panelCover(
                    left: width * 0.205,
                    top: height * 0.220,
                    width: width * 0.155,
                    height: height * 0.220,
                  ),
                  _panelCover(
                    left: width * 0.645,
                    top: height * 0.220,
                    width: width * 0.180,
                    height: height * 0.220,
                  ),
                  _panelCover(
                    left: width * 0.775,
                    top: height * 0.045,
                    width: width * 0.195,
                    height: height * 0.055,
                  ),

                  // CANLI SAAT / TARİH / GÜN
                  Positioned(
                    left: width * 0.050,
                    top: height * 0.055,
                    width: width * 0.260,
                    height: height * 0.060,
                    child: const Center(
                      child: LiveClock(),
                    ),
                  ),

                  // CANLI TAKVİM
                  Positioned(
                    left: width * 0.205,
                    top: height * 0.220,
                    width: width * 0.155,
                    height: height * 0.220,
                    child: const LiveCalendar(),
                  ),

                  // CANLI HAVA DURUMU
                  Positioned(
                    left: width * 0.645,
                    top: height * 0.220,
                    width: width * 0.180,
                    height: height * 0.220,
                    child: const Center(
                      child: WeatherStatus(),
                    ),
                  ),

                  // CANLI BAĞLANTI DURUMU
                  Positioned(
                    left: width * 0.775,
                    top: height * 0.045,
                    width: width * 0.125,
                    height: height * 0.055,
                    child: const Center(
                      child: ConnectivityStatus(),
                    ),
                  ),

                  // CANLI BATARYA
                  Positioned(
                    left: width * 0.905,
                    top: height * 0.045,
                    width: width * 0.065,
                    height: height * 0.055,
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

                  // ARES
                  Positioned(
                    left: width * 0.275,
                    top: height * 0.700,
                    width: width * 0.215,
                    height: height * 0.115,
                    child: _folderArea(
                      context,
                      'ARES',
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

                  // GERÇEK ANDROID SİSTEM NAVİGASYON ALANI İÇİN ARES ÇERÇEVESİ
                  // Buradaki ikonlar Flutter tarafından çizilmez; Android'in gerçek
                  // Geri / Ana ekran / Son uygulamalar kontrolleri bu alanın üstünde
                  // sistem tarafından gösterilir.
                  Positioned(
                    left: width * 0.355,
                    right: width * 0.355,
                    bottom: 2,
                    height: 54,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xCC031522),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF00BFFF),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x9900BFFF),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
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
