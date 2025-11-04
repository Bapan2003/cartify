import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Function(File? imageFile)? onImageSelected;
  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  ProfileAvatar({
    Key? key,
    required this.userData,
    this.onImageSelected,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);
        _selectedImage.value = file;
        if (onImageSelected != null) onImageSelected!(file);
      }
    } catch (e) {
      _showSnack(context, "Failed to pick image: $e");
    }
  }

  void _showSnack(BuildContext context, String message) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = userData['photoUrl']?.toString() ?? '';

    final isCupertino = Theme.of(context).platform == TargetPlatform.iOS;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: ValueListenableBuilder<File?>(
          valueListenable: _selectedImage,
          builder: (context, file, _) {
            ImageProvider? imageProvider;

            // ✅ Priority: Picked image → Network image
            if (file != null) {
              imageProvider = FileImage(file);
            } else if (photoUrl.isNotEmpty) {
              // ✅ Force unique key to reload image on web when updated
              imageProvider = NetworkImage(photoUrl);
            }

            // ✅ Ensure web network image loads
            final avatar = ClipOval(
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey[200],
                child: imageProvider != null
                    ? Image(
                  key: ValueKey(photoUrl),
                  image: imageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );

            final editButton = GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  isCupertino ? CupertinoIcons.pencil : Icons.edit,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final avatarSize = isWide ? 100.0 : 70.0;

                return Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: ClipOval(child: avatar),
                      ),
                      Positioned(
                        bottom: -0,
                        right: isWide ? 5 : 0,
                        child: editButton,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );

  }
}
