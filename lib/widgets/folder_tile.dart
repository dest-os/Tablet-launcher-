import 'package:flutter/material.dart';

class FolderTile extends StatelessWidget {
  final String folderName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FolderTile({
    super.key,
    required this.folderName,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.folder,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 90,
            child: Text(
              folderName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
