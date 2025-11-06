import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qit/providers/dashboard_provider.dart';
import 'package:qit/router/app_route.dart';

import '../../../providers/auth_providers.dart';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/cupertino.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  // ✅ ValueNotifier for password visibility
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  // ✅ Form key
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return defaultTargetPlatform == TargetPlatform.iOS
        ? _buildCupertinoLogin(context, isWeb, size)
        : _buildMaterialLogin(context, isWeb, size);
  }

  // -------------------- MATERIAL --------------------
  Widget _buildMaterialLogin(BuildContext context, bool isWeb, Size size) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Cartify",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    Selector<AuthProvider, bool>(
                      selector: (_, provider) => provider.isLoginMode,
                      builder: (ctx, isLoginMode, _) {
                        if (!isLoginMode) {
                          // Show extra fields only when signing up
                          return Column(
                            children: [
                              _ValidatedTextField(
                                controller: _nameController,
                                label: "Full Name",
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Name is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // _ValidatedTextField(
                              //   controller: _phoneController,
                              //   label: "Phone Number",
                              //   keyboardType: TextInputType.phone,
                              //   validator: (value) {
                              //     if (value == null || value.isEmpty) {
                              //       return "Phone number is required";
                              //     }
                              //     if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              //       return "Enter a valid 10-digit phone number";
                              //     }
                              //     return null;
                              //   },
                              // ),
                              const SizedBox(height: 12),
                            ],
                          );
                        } else {
                          // Return empty space when in login mode
                          return const SizedBox.shrink();
                        }
                      },
                    ),

                    // Email Field
                    _ValidatedTextField(
                      controller: _emailController,
                      label: "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password Field with toggle
                    ValueListenableBuilder<bool>(
                      valueListenable: _obscurePassword,
                      builder: (context, obscure, _) {
                        return _ValidatedTextField(
                          controller: _passwordController,
                          label: "Password",
                          obscure: obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => _obscurePassword.value = !obscure,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Auth button
                    Selector<AuthProvider, bool>(
                      selector: (_, provider) => provider.isLoading,
                      builder: (ctx, isLoading, _) {
                        return isLoading
                            ? const CircularProgressIndicator()
                            : Selector<AuthProvider, bool>(
                                selector: (_, provider) => provider.isLoginMode,
                                builder: (ctx, isLoginMode, _) {
                                  return ElevatedButton(
                                    onPressed: () => _onAuthPressed(
                                      context,
                                      context.read<AuthProvider>(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        50,
                                      ),
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      isLoginMode ? "Login" : "Sign Up",
                                    ),
                                  );
                                },
                              );
                      },
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Mode toggle text
                    Selector<AuthProvider, bool>(
                      selector: (_, provider) => provider.isLoginMode,
                      builder: (ctx, isLoginMode, _) {
                        return TextButton(
                          onPressed: () =>
                              context.read<AuthProvider>().toggleMode(),
                          child: Text(
                            isLoginMode
                                ? "Don't have an account? Sign Up"
                                : "Already have an account? Login",
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text("Or"),
                    const SizedBox(height: 8),

                    // Google login
                    OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await context.read<AuthProvider>().signInWithGoogle();
                          if (context.mounted) context.go(AppRoute.dashboard);
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                      ),
                      label: const Text("Sign in with Google"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- CUPERTINO --------------------
  Widget _buildCupertinoLogin(BuildContext context, bool isWeb, Size size) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text("Cartify")),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.shopping_cart,
                        size: 80,
                        color: CupertinoColors.activeOrange,
                      ),
                      const SizedBox(height: 24),

                      Selector<AuthProvider, bool>(
                        selector: (_, provider) => provider.isLoginMode,
                        builder: (ctx, isLoginMode, _) {
                          if (isLoginMode) return const SizedBox.shrink();

                          return Column(
                            children: [
                              CupertinoTextField(
                                controller: _nameController,
                                placeholder: "Full Name",
                                padding: const EdgeInsets.all(16),
                              ),
                              const SizedBox(height: 12),
                              // CupertinoTextField(
                              //   controller: _phoneController,
                              //   placeholder: "Phone Number",
                              //   keyboardType: TextInputType.phone,
                              //   padding: const EdgeInsets.all(16),
                              // ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),


                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: "Email",
                        keyboardType: TextInputType.emailAddress,
                        padding: const EdgeInsets.all(16),
                      ),
                      const SizedBox(height: 12),

                      ValueListenableBuilder<bool>(
                        valueListenable: _obscurePassword,
                        builder: (ctx, obscure, _) {
                          return CupertinoTextField(
                            controller: _passwordController,
                            placeholder: "Password",
                            obscureText: obscure,
                            padding: const EdgeInsets.all(16),
                            suffix: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Icon(
                                obscure
                                    ? CupertinoIcons.eye_slash
                                    : CupertinoIcons.eye,
                                color: CupertinoColors.systemGrey,
                              ),
                              onPressed: () =>
                                  _obscurePassword.value = !obscure,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      Selector<AuthProvider, bool>(
                        selector: (_, provider) => provider.isLoading,
                        builder: (ctx, isLoading, _) {
                          if (isLoading) {
                            return const CupertinoActivityIndicator();
                          }

                          return Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isLoginMode,
                            builder: (ctx, isLoginMode, _) {
                              return Column(
                                children: [
                                  CupertinoButton.filled(
                                    onPressed: () => _onAuthPressed(
                                      context,
                                      context.read<AuthProvider>(),
                                    ),
                                    child: Text(isLoginMode ? "Login" : "Sign Up"),
                                  ),
                                  CupertinoButton(
                                    onPressed: () =>
                                        context.read<AuthProvider>().toggleMode(),
                                    child: Text(
                                      isLoginMode
                                          ? "Don't have an account? Sign Up"
                                          : "Already have an account? Login",
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),


                      const SizedBox(height: 16),
                      const Text(
                        "OR",
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoButton(
                        color: CupertinoColors.systemGrey4,
                        onPressed: () async {
                          try {
                            await context.read<AuthProvider>().signInWithGoogle();
                            if (context.mounted) context.go(AppRoute.dashboard);
                          } catch (e) {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text("Error"),
                                content: Text(e.toString()),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("OK"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: const Text("Sign in with Google"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onAuthPressed(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (auth.isLoginMode) {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await auth.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
          // _phoneController.text.trim(),
        );
      }


      if (!context.mounted) return;
      context.go(AppRoute.dashboard);
      context.read<DashboardProvider>().setIndex(0);
    } catch (e) {
      final msg = e.toString();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text("Error"),
            content: Text(msg),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }
}

// ✅ Custom text field with validation
class _ValidatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ValidatedTextField({
    required this.controller,
    required this.label,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
