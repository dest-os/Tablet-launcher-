import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledAppsService {
  const InstalledAppsService();

  Future<List<AppInfo>> getLaunchableApps() async {
    final apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      excludeNonLaunchableApps: true,
      withIcon: true,
    );

    apps.sort(
      (a, b) => a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          ),
    );

    return apps;
  }

  Future<bool> launchApp(String packageName) async {
    final result = await InstalledApps.startApp(packageName);
    return result ?? false;
  }
}
