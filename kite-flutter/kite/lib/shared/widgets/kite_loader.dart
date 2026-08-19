import 'package:flutter/material.dart';

class KiteLoader extends StatefulWidget {
  final double size;

  const KiteLoader({super.key, this.size = 48.0});

  @override
  State<KiteLoader> createState() => _KiteLoaderState();
}

class _KiteLoaderState extends State<KiteLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.9), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size + 24,
      height: widget.size + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Outer Pulse Ring
          SizedBox(
            width: widget.size + 16,
            height: widget.size + 16,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                primaryColor.withValues(alpha: 0.6),
              ),
            ),
          ),

          // Animated Soaring Kite Icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    size: widget.size,
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
