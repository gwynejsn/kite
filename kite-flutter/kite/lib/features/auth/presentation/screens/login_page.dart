import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kite/features/auth/data/datasources/auth_data_source.dart';
import 'package:kite/features/auth/data/repositories/auth_repository_imp.dart';
import 'package:kite/features/auth/presentation/controllers/login_controller.dart';
import 'package:kite/features/auth/presentation/controllers/login_state.dart';
import 'package:kite/features/auth/presentation/screens/register_page.dart';
import 'package:kite/features/auth/presentation/widgets/logo_header.dart';
import 'package:kite/features/conversation/presentation/screens/conversation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginController _loginController;
  bool _isPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    final authDataSource = AuthDataSource(http.Client());
    final authRepository = AuthRepositoryImpl(authDataSource);
    _loginController = LoginController(authRepository);

    _loginController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _loginController.value;

    if (state.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (state.isSuccess && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConversationPage()),
      );
    }
  }

  @override
  void dispose() {
    _loginController.removeListener(_onStateChanged);
    _loginController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      _loginController.login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kite-kids.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // image overlay
          Positioned.fill(
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.50),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeaderWidget(message: "Welcome back!"),
                    const SizedBox(height: 32),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 24.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: ValueListenableBuilder<LoginState>(
                              valueListenable: _loginController,
                              builder: (context, state, child) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      enabled: !state.isLoading,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'example@kite.com',
                                        prefixIcon: Icon(Icons.email_outlined),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Email is required!';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _isPasswordObscured,
                                      textInputAction: TextInputAction.done,
                                      enabled: !state.isLoading,
                                      onFieldSubmitted: (_) => _submitForm(),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordObscured
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordObscured =
                                                  !_isPasswordObscured;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required!';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          52,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: state.isLoading
                                          ? null
                                          : _submitForm,
                                      child: state.isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 20),
                                    const _SignUpRow(),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpRow extends StatelessWidget {
  const _SignUpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            'Sign up',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
