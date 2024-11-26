import 'dart:convert';

import 'package:flutter/material.dart';

import '../../constants/assets_path.dart';
import '../../models/user.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.user,
    this.size,
  });

  final UserModel user;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final imageProvider = user.profileImage != null
        ? MemoryImage(base64Decode(user.profileImage!))
        : const AssetImage(ImagePath.profile) as ImageProvider;

    return Container(
      width: size ?? 60.0,
      height: size ?? 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
