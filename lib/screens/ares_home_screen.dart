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
    // ARES tasarımı 1672x941'lik tek bir referans koordinat sisteminde
    // hazırlanmıştır. Tüm arayüzü tek parça olarak ölçeklemek; saat,
    // takvim, hava durumu ve dokunma alanlarının birbirinden kaymasını
    // ekran oranından bağımsız olarak engeller.
    const designWidth = 1672.0;
    const designHeight = 941.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.center,
          child: SizedBox(
            width: designWidth,
            height: designHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AresBackground(),

                // CANLI SAAT / TARİH / GÜN
                Positioned(
                  left: designWidth * 0.035,
                  top: designHeight * 0.055,
                  width: designWidth * 0.285,
                  height: designHeight * 0.075,
                  child: const FittedBox(
                    fit: BoxFit.contain,
                    child: LiveClock(),
                  ),
                ),

                // CANLI TAKVİM
                Positioned(
                  left: designWidth * 0.195,
                  top: designHeight * 0.205,
                  width: designWidth * 0.185,
                  height: designHeight * 0.245,
                  child: const FittedBox(
                    fit: BoxFit.contain,
                    child: LiveCalendar(),
                  ),
                ),

                // CANLI HAVA DURUMU
                Positioned(
                  left: designWidth * 0.635,
                  top: designHeight * 0.205,
                  width: designWidth * 0.205,
                  height: designHeight * 0.245,
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: WeatherStatus(),
                    ),
                  ),
                ),

                // CANLI BAĞLANTI DURUMU
                Positioned(
                  left: designWidth * 0.765,
                  top: designHeight * 0.035,
                  width: designWidth * 0.125,
                  height: designHeight * 0.075,
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ConnectivityStatus(),
                    ),
                  ),
                ),

                // CANLI BATARYA
                Positioned(
                  left: designWidth * 0.900,
                  top: designHeight * 0.035,
                  width: designWidth * 0.075,
                  height: designHeight * 0.075,
                  child: const Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: BatteryStatus(),
                    ),
                  ),
                ),

                // SOSYAL
                Positioned(
                  left: designWidth * 0.035,
                  top: designHeight * 0.700,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'SOSYAL'),
                ),

                // ARES
                Positioned(
                  left: designWidth * 0.275,
                  top: designHeight * 0.700,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'ARES'),
                ),

                // MEDYA
                Positioned(
                  left: designWidth * 0.515,
                  top: designHeight * 0.700,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'MEDYA'),
                ),

                // ARAÇLAR
                Positioned(
                  left: designWidth * 0.755,
                  top: designHeight * 0.700,
                  width: designWidth * 0.210,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'ARAÇLAR'),
                ),

                // İŞ
                Positioned(
                  left: designWidth * 0.035,
                  top: designHeight * 0.835,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'İŞ'),
                ),

                // SİSTEM
                Positioned(
                  left: designWidth * 0.275,
                  top: designHeight * 0.835,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'SİSTEM'),
                ),

                // İNTERNET
                Positioned(
                  left: designWidth * 0.515,
                  top: designHeight * 0.835,
                  width: designWidth * 0.215,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'İNTERNET'),
                ),

                // DİĞER
                Positioned(
                  left: designWidth * 0.755,
                  top: designHeight * 0.835,
                  width: designWidth * 0.210,
                  height: designHeight * 0.115,
                  child: _folderArea(context, 'DİĞER'),
                ),

                // Gerçek Android gezinme kontrolleri sistem tarafından
                // gösterilir; bu alan yalnızca onların altındaki ARES
                // görünümünü sağlar. Tasarım ölçeğiyle birlikte ölçeklenir.
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 38,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xC7000000),
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFF00BFFF),
                            width: 1.5,
                          ),
                          left: BorderSide(
                            color: Color(0xFF0077A8),
                            width: 1,
                          ),
                          right: BorderSide(
                            color: Color(0xFF0077A8),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00BFFF),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
