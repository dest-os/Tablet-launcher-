import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/folder_item.dart';

class FolderStorageService {
  const FolderStorageService();

  static const String _storageKey = 'ares_folders';

  Future<List<FolderItem>> getFolders() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final jsonString = preferences.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => FolderItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFolders(List<FolderItem> folders) async {
    final preferences = await SharedPreferences.getInstance();

    final data = folders
        .map((folder) => folder.toMap())
        .toList();

    await preferences.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  Future<void> addFolder(FolderItem folder) async {
    final folders = await getFolders();

    final alreadyExists = folders.any(
      (item) => item.folderName == folder.folderName,
    );

    if (alreadyExists) {
      return;
    }

    folders.add(folder);

    await saveFolders(folders);
  }

  Future<void> removeFolder(String folderName) async {
    final folders = await getFolders();

    folders.removeWhere(
      (item) => item.folderName == folderName,
    );

    await saveFolders(folders);
  }

  Future<bool> folderExists(String folderName) async {
    final folders = await getFolders();

    return folders.any(
      (item) => item.folderName == folderName,
    );
  }

  Future<void> clearFolders() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_storageKey);
  }
}
