import 'package:flutter/material.dart';

class StepProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.2);

    final double progress = (currentStep + 1) / totalSteps;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: inactiveColor,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            final isCurrent = index == currentStep;

            return Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? activeColor
                        : isActive
                        ? activeColor.withValues(alpha: 0.8)
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stepTitles[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent
                        ? activeColor
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
