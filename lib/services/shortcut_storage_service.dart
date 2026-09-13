import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shortcut_item.dart';

class ShortcutStorageService {
  static const String _storageKey = 'ares_shortcuts';

  const ShortcutStorageService();

  Future<List<ShortcutItem>> getShortcuts() async {
    final preferences = await SharedPreferences.getInstance();

    final savedData = preferences.getString(_storageKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(savedData);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => ShortcutItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveShortcuts(List<ShortcutItem> shortcuts) async {
    final preferences = await SharedPreferences.getInstance();

    final data = shortcuts
        .map((shortcut) => shortcut.toMap())
        .toList();

    await preferences.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  Future<void> addShortcut(ShortcutItem shortcut) async {
    final shortcuts = await getShortcuts();

    final alreadyExists = shortcuts.any(
      (item) =>
          item.packageName == shortcut.packageName &&
          item.folderName == shortcut.folderName,
    );

    if (alreadyExists) {
      return;
    }

    shortcuts.add(shortcut);

    await saveShortcuts(shortcuts);
  }

  Future<void> removeShortcut({
    required String packageName,
    required String folderName,
  }) async {
    final shortcuts = await getShortcuts();

    shortcuts.removeWhere(
      (item) =>
          item.packageName == packageName &&
          item.folderName == folderName,
    );

    await saveShortcuts(shortcuts);
  }

  Future<List<ShortcutItem>> getShortcutsForFolder(
    String folderName,
  ) async {
    final shortcuts = await getShortcuts();

    return shortcuts
        .where((item) => item.folderName == folderName)
        .toList();
  }

  Future<void> clearFolder(String folderName) async {
    final shortcuts = await getShortcuts();

    shortcuts.removeWhere(
      (item) => item.folderName == folderName,
    );

    await saveShortcuts(shortcuts);
  }
}
