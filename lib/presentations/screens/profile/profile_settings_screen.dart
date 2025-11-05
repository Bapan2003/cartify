import 'package:flutter/material.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qit/presentations/widgets/gradient_bar.dart';

import '../../../providers/profile_provider.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  void _openEditDetailsSheet(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: provider.pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: provider.pickedImage != null
                      ? (kIsWeb
                            ? NetworkImage(provider.pickedImage!.path)
                            : FileImage(File(provider.pickedImage!.path))
                                  as ImageProvider)
                      : (provider.profileImage != null
                            ? NetworkImage(provider.profileImage!)
                            : null),
                  child:
                      provider.pickedImage == null &&
                          provider.profileImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: provider.name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => provider.name = val,
              ),
              const SizedBox(height: 20),
              provider.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: provider.updateProfile,
                      child: const Text('Save'),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void showChangePasswordSheet(BuildContext context) {
    final _formKeyPassword = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) => Form(
            key: _formKeyPassword,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        provider.currentPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => provider.toggleVisibility('current'),
                    ),
                  ),
                  obscureText: !provider.currentPasswordVisible,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter current password'
                      : null,
                  onChanged: (val) => provider.setPassword('current', val??''),
                  onSaved: (val) => provider.setPassword('current', val??''),
                ),
                const SizedBox(height: 10),

                // New Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        provider.newPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => provider.toggleVisibility('new'),

                    ),
                  ),
                  obscureText: !provider.newPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Enter new password';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  onChanged: (val) => provider.setPassword('new', val??''),
                  onSaved: (val) => provider.setPassword('new', val??''),
                ),
                const SizedBox(height: 10),

                // Confirm Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        provider.confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => provider.toggleVisibility('confirm'),

                    ),
                  ),
                  obscureText: !provider.confirmPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Confirm password';
                    if (value != provider.newPassword)
                      return 'Passwords do not match';
                    return null;
                  },
                  onChanged: (val) => provider.setPassword('confirm', val??''),
                  onSaved: (val) => provider.setPassword('confirm', val??''),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKeyPassword.currentState!.validate()) {
                      _formKeyPassword.currentState!.save();
                      final error = await provider.changePassword();
                      if (error != null) {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password changed successfully'),
                          ),
                        );
                      }
                    }
                  },
                  child: provider.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Change Password'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'),flexibleSpace: const GradientBar(),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return isWide
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildCard(
                              context,
                              'Edit Details',
                              provider.name,
                              provider.profileImage,
                              _openEditDetailsSheet,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildCard(
                              context,
                              'Change Password',
                              '',
                              null,
                              showChangePasswordSheet,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCard(
                            context,
                            'Edit Details',
                            provider.name,
                            provider.profileImage,
                            _openEditDetailsSheet,
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            context,
                            'Change Password',
                            '',
                            null,
                            showChangePasswordSheet,
                          ),
                        ],
                      );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String subtitle,
    String? image,
    Function onTap,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        leading: image != null
            ? CircleAvatar(backgroundImage: NetworkImage(image))
            : null,
        trailing: const Icon(Icons.edit),
        onTap: () => onTap(context),
      ),
    );
  }
}
