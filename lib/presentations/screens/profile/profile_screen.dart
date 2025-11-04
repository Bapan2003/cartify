import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qit/router/app_route.dart';

import '../../../providers/auth_providers.dart';
import '../../widgets/profile_avatar.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final ValueNotifier<bool> _isChanged = ValueNotifier(false);
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  File? _newProfileImage;

  late Map<String, dynamic> _initialData;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _isChanged.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final initialName = _initialData['name'] ?? '';
    final initialPhone = _initialData['phone'] ?? '';
    final hasChanged =
        name != initialName ||
        phone != initialPhone ||
        _newProfileImage != null;

    if (_isChanged.value != hasChanged) _isChanged.value = hasChanged;
  }

  Future<String?> _uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bool isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: isWeb ? Colors.grey[100] : null,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: auth.getUserDataStream(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final userData = snapshot.data!.data()!;
          _initialData = userData;
          print(userData);

          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';

          _nameController.removeListener(_checkChanges);
          _phoneController.removeListener(_checkChanges);
          _nameController.addListener(_checkChanges);
          _phoneController.addListener(_checkChanges);

          final content = ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: isWeb ? 6 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16).copyWith(top: 40),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    /// ✅ Profile avatar updates tracked
                    ProfileAvatar(
                      userData: userData,
                      onImageSelected: (file) async {
                        _newProfileImage = file;
                        _checkChanges();
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        userData['email'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),

                    /// ✅ Reactive Save Button (name, phone, or image change)
                    ValueListenableBuilder2<bool, bool>(
                      first: _isChanged,
                      second: _isLoading,
                      builder: (context, isChanged, isLoading, _) {
                        return Visibility(
                          visible: _isChanged.value,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isChanged
                                      ? Colors.orange
                                      : Colors.orange.withOpacity(0.5),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: !isChanged || isLoading
                                    ? null
                                    : () async {
                                        _isLoading.value = true;
                                        try {
                                          String? imageUrl =
                                              userData['photoUrl'];
                                          if (_newProfileImage != null) {
                                            final uid = auth.user?.uid ?? '';
                                            imageUrl =
                                                await _uploadProfileImage(
                                                  uid,
                                                  _newProfileImage!,
                                                );
                                          }

                                          await auth.updateProfile(
                                            _nameController.text.trim(),
                                            _phoneController.text.trim(),
                                            photo: imageUrl,
                                          );

                                          _newProfileImage = null;
                                          _isChanged.value = false;

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Profile updated!",
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Failed to update profile: $e",
                                                ),
                                              ),
                                            );
                                          }
                                        } finally {
                                          _isLoading.value = false;
                                        }
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  isLoading ? "Saving..." : "Save Changes",
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );

          return Stack(
            children: [
              isWeb
                  ? Align(alignment: Alignment.topCenter, child: content)
                  : content,
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50, left: 24, right: 24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      try {
                        await auth.signOut();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) context.go(AppRoute.login);
                        });
                      } catch (e) {
                        if (Theme.of(context).platform == TargetPlatform.iOS) {
                          showCupertinoDialog(
                            context: context,
                            builder: (_) => CupertinoAlertDialog(
                              title: const Text("Logout Failed"),
                              content: Text(e.toString()),
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
                            SnackBar(content: Text("Logout failed: $e")),
                          );
                        }
                      }
                    },
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade600, Colors.orange.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )

            ],
          );
        },
      ),
    );
  }
}

/// ✅ Utility: Combine two ValueListenables in one builder
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (ctx, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (ctx, b, __) => builder(ctx, a, b, child),
        );
      },
    );
  }
}
