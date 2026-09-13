import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';

import '../models/shortcut_item.dart';
import '../services/app_launcher_service.dart';
import '../services/installed_apps_service.dart';
import '../services/shortcut_storage_service.dart';
import 'shortcut_tile.dart';

class FolderContent extends StatefulWidget {
  final String folderName;

  const FolderContent({
    super.key,
    required this.folderName,
  });

  @override
  State<FolderContent> createState() => _FolderContentState();
}

class _FolderContentState extends State<FolderContent> {
  final ShortcutStorageService _shortcutStorage =
      const ShortcutStorageService();

  final InstalledAppsService _installedAppsService =
      const InstalledAppsService();

  final AppLauncherService _appLauncherService =
      const AppLauncherService();

  List<ShortcutItem> _shortcuts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShortcuts();
  }

  Future<void> _loadShortcuts() async {
    final shortcuts = await _shortcutStorage.getShortcutsForFolder(
      widget.folderName,
    );

    if (!mounted) return;

    setState(() {
      _shortcuts = shortcuts;
      _loading = false;
    });
  }

  Future<void> _showAppSelector() async {
    List<AppInfo> apps = [];

    try {
      apps = await _installedAppsService.getLaunchableApps();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Uygulamalar alınamadı.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    final selectedApp = await showDialog<AppInfo>(
      context: context,
      builder: (dialogContext) {
        return _AppSelectorDialog(
          apps: apps,
        );
      },
    );

    if (selectedApp == null) return;

    final shortcut = ShortcutItem(
      packageName: selectedApp.packageName,
      appName: selectedApp.name,
      folderName: widget.folderName,
    );

    await _shortcutStorage.addShortcut(shortcut);

    await _loadShortcuts();
  }

  Future<void> _launchShortcut(ShortcutItem shortcut) async {
    final success = await _appLauncherService.launchApp(
      shortcut.packageName,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${shortcut.appName} açılamadı.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteShortcut(ShortcutItem shortcut) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF20252B),
          title: const Text(
            'Kısayolu Sil',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            '${shortcut.appName} kısayolunu silmek istiyor musun?',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'İptal',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Sil',
                style: TextStyle(
                  color: Color(0xFF00BFFF),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _shortcutStorage.removeShortcut(
      packageName: shortcut.packageName,
      folderName: widget.folderName,
    );

    await _loadShortcuts();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.folderName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _showAppSelector,
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Uygulama ekle',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _shortcuts.isEmpty
              ? const Center(
                  child: Text(
                    'Uygulama eklemek için + düğmesine bas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _shortcuts.length,
                  itemBuilder: (context, index) {
                    final shortcut = _shortcuts[index];

                    return ShortcutTile(
                      appName: shortcut.appName,
                      onTap: () => _launchShortcut(shortcut),
                      onLongPress: () => _deleteShortcut(shortcut),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AppSelectorDialog extends StatefulWidget {
  final List<AppInfo> apps;

  const _AppSelectorDialog({
    required this.apps,
  });

  @override
  State<_AppSelectorDialog> createState() => _AppSelectorDialogState();
}

class _AppSelectorDialogState extends State<_AppSelectorDialog> {
  final TextEditingController _searchController =
      TextEditingController();

  List<AppInfo> _filteredApps = [];

  @override
  void initState() {
    super.initState();

    _filteredApps = List<AppInfo>.from(widget
