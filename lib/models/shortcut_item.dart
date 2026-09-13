class ShortcutItem {
  final String packageName;
  final String appName;
  final String folderName;

  const ShortcutItem({
    required this.packageName,
    required this.appName,
    required this.folderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'appName': appName,
      'folderName': folderName,
    };
  }

  factory ShortcutItem.fromMap(Map<String, dynamic> map) {
    return ShortcutItem(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      folderName: map['folderName'] as String,
    );
  }
}
