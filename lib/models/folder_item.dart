class FolderItem {
  final String folderName;

  const FolderItem({
    required this.folderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'folderName': folderName,
    };
  }

  factory FolderItem.fromMap(Map<String, dynamic> map) {
    return FolderItem(
      folderName: map['folderName'] as String,
    );
  }
}
