import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityStatus extends StatefulWidget {
  const ConnectivityStatus({super.key});

  @override
  State<ConnectivityStatus> createState() => _ConnectivityStatusState();
}

class _ConnectivityStatusState extends State<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isWifiConnected = false;

  @override
  void initState() {
    super.initState();

    _checkConnectivity();

    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();

    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results,
  ) {
    if (!mounted) return;

    setState(() {
      _isWifiConnected = results.contains(
        ConnectivityResult.wifi,
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xFF00BFFF);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isWifiConnected ? Icons.wifi : Icons.wifi_off,
          color: iconColor,
          size: 27,
        ),
        const SizedBox(width: 13),
        const Icon(
          Icons.bluetooth,
          color: iconColor,
          size: 27,
        ),
        const SizedBox(width: 13),
        const Icon(
          Icons.signal_cellular_alt,
          color: iconColor,
          size: 27,
        ),
      ],
    );
  }
}
