import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// EmptyState — shown when no medicines or no history exists
/// ─────────────────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.medication_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Animate(
              effects: [
                ScaleEffect(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
                FadeEffect(duration: 400.ms),
              ],
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Title
            Animate(
              effects: [
                FadeEffect(duration: 500.ms, delay: 200.ms),
                SlideEffect(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                  duration: 500.ms,
                  delay: 200.ms,
                ),
              ],
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Animate(
              effects: [
                FadeEffect(duration: 500.ms, delay: 300.ms),
                SlideEffect(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                  duration: 500.ms,
                  delay: 300.ms,
                ),
              ],
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              Animate(
                effects: [
                  FadeEffect(duration: 500.ms, delay: 400.ms),
                  ScaleEffect(duration: 500.ms, delay: 400.ms),
                ],
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
