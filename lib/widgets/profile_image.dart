import 'dart:io';

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/account.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';

class ProfileImage extends StatelessWidget {
  final Account? account;
  final SportCategory currentSport;
  final double radius;
  final File? localFile;

  const ProfileImage({
    Key? key,
    required this.account,
    required this.currentSport,
    this.radius = 60,
    this.localFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = ATLColors.getPrimaryColor(currentSport);

    ImageProvider<Object>? imageProvider;

    // Local picked file takes precedence
    if (localFile != null) {
      try {
        if (localFile!.path.isNotEmpty && File(localFile!.path).existsSync()) {
          imageProvider = FileImage(localFile!);
        }
      } catch (_) {}
    }

    final url = account?.imageUrl;
    if (imageProvider == null && url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        imageProvider = NetworkImage(url);
      } else if (url.startsWith('/')) {
        // Build full url using storageBaseUrl
        try {
          final full = '${AppConfig.storageBaseUrl}\$url';
          imageProvider = NetworkImage(full);
        } catch (_) {
          imageProvider = null;
        }
      }
    }

    if (imageProvider != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color.withOpacity(0.2),
        backgroundImage: imageProvider,
      );
    }

    // Placeholder with initials
    String? initials;
    if (account != null) {
      final parts = '${account?.name ?? ''} ${account?.surname ?? ''}'
          .trim()
          .split(RegExp(r"\\s+"));
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (initials == null || initials.isEmpty) {
        initials = (account?.username ?? '')
            .trim()
            .split(RegExp(r"\\s+"))
            .where((s) => s.isNotEmpty)
            .map((s) => s[0])
            .take(2)
            .join()
            .toUpperCase();
      }
    }

    if (initials != null && initials.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.2),
      child: Icon(
        Icons.person,
        color: color,
        size: radius,
      ),
    );
  }
}
