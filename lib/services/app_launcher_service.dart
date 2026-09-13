import 'package:installed_apps/installed_apps.dart';

class AppLauncherService {
  const AppLauncherService();

  Future<bool> launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
      return true;
    } catch (_) {
      return false;
    }
  }
}
