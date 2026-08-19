import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kite/features/auth/presentation/controllers/register_controller.dart';
import 'package:kite/features/auth/presentation/controllers/register_state.dart';
import 'package:kite/features/auth/presentation/screens/login_page.dart';
import 'package:kite/features/auth/presentation/widgets/register_bio_details.dart';
import 'package:kite/features/auth/presentation/widgets/register_credentials.dart';
import 'package:kite/features/auth/presentation/widgets/register_profile_details.dart';
import 'package:kite/features/auth/presentation/widgets/step_progress_header.dart';
import 'package:kite/features/main/presentation/screens/main_navigation_page.dart';
import 'package:kite/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:kite/shared/di/injection_container.dart';
import 'package:kite/shared/widgets/kite_loader.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _registerController;
  late final List<Widget> _registerWidgets;

  final List<String> _stepTitles = const [
    'Credentials',
    'Personal Info',
    'About You',
  ];

  @override
  void initState() {
    super.initState();
    _registerController = sl<RegisterController>();
    _registerWidgets = [
      RegisterCredentials(controller: _registerController),
      RegisterProfileDetails(controller: _registerController),
      RegisterBioDetails(controller: _registerController),
    ];

    _registerController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _registerController.value;

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
      context.read<UserProfileProvider>().fetchUserProfile();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _registerController.removeListener(_onStateChanged);
    _registerController.dispose();
    super.dispose();
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
          Positioned.fill(
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.55),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.6),
                  radius: 1.3,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.22),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.15),
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Registration',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 20),

                    ValueListenableBuilder<RegisterState>(
                      valueListenable: _registerController,
                      builder: (context, state, child) {
                        return StepProgressHeader(
                          currentStep: state.stepIndex,
                          totalSteps: 3,
                          stepTitles: _stepTitles,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22.0,
                            vertical: 24.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ValueListenableBuilder<RegisterState>(
                                valueListenable: _registerController,
                                builder: (context, state, child) {
                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder:
                                        (
                                          Widget child,
                                          Animation<double> animation,
                                        ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.15, 0.0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                    child: KeyedSubtree(
                                      key: ValueKey<int>(state.stepIndex),
                                      child: _registerWidgets[state.stepIndex],
                                    ),
                                  );
                                },
                              ),
                              const _SignInRow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<RegisterState>(
            valueListenable: _registerController,
            builder: (context, state, child) {
              if (state.isLoading) {
                return const _GlassmorphicRegisterLoadingOverlay(
                  message: 'Hang on tight...',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _SignInRow extends StatelessWidget {
  const _SignInRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            'Sign in',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _GlassmorphicRegisterLoadingOverlay extends StatelessWidget {
  final String message;

  const _GlassmorphicRegisterLoadingOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KiteLoader(size: 42),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
}
