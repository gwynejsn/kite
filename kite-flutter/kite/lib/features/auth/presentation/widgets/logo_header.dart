import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String message;
  const HeaderWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Title - Larger KITE
        Text(
          'KITE',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle / Greeting
        Text(
          message,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: const Color(0xFFFFD200), // Vibrant yellow accent
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
