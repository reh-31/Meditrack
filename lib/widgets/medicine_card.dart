import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../models/medicine.dart';
import '../utils/date_utils.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MedicineTypeChip — small coloured badge for medicine type
/// ─────────────────────────────────────────────────────────────────────────────
class MedicineTypeChip extends StatelessWidget {
  final String type;
  final bool small;

  const MedicineTypeChip({super.key, required this.type, this.small = false});

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return AppColors.tablet;
      case 'capsule':
        return AppColors.capsule;
      case 'syrup':
        return AppColors.syrup;
      case 'injection':
        return AppColors.injection;
      case 'drops':
        return AppColors.drops;
      case 'cream':
        return AppColors.cream;
      default:
        return AppColors.other;
    }
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.circle_outlined;
      case 'capsule':
        return Icons.medication_outlined;
      case 'syrup':
        return Icons.local_drink_outlined;
      case 'injection':
        return Icons.vaccines_outlined;
      case 'drops':
        return Icons.water_drop_outlined;
      case 'cream':
        return Icons.spa_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(type);
    final icon = _iconForType(type);
    final double fontSize = small ? 10 : 12;
    final double iconSize = small ? 12 : 14;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// MedicineCard — main list tile for a medicine
/// ─────────────────────────────────────────────────────────────────────────────
class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onMarkTaken;
  final VoidCallback onDelete;
  final int index;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onMarkTaken,
    required this.onDelete,
    required this.index,
  });

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return AppColors.tablet;
      case 'capsule':
        return AppColors.capsule;
      case 'syrup':
        return AppColors.syrup;
      case 'injection':
        return AppColors.injection;
      case 'drops':
        return AppColors.drops;
      case 'cream':
        return AppColors.cream;
      default:
        return AppColors.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(medicine.type);
    final taken = medicine.takenToday;

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 60).ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
          duration: 350.ms,
          delay: (index * 60).ms,
        ),
      ],
      child: Dismissible(
        key: Key(medicine.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (_) async {
          return await _showDeleteDialog(context);
        },
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: color.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: taken
                    ? AppColors.success.withValues(alpha: 0.25)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent color indicator
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: taken ? AppColors.success : color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Icon container - Squircle style
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: (taken ? AppColors.success : color)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (taken ? AppColors.success : color)
                                    .withValues(alpha: 0.12),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              taken
                                  ? Icons.check_circle_rounded
                                  : Icons.medication_rounded,
                              color: taken ? AppColors.success : color,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Info details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        medicine.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (taken)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check,
                                                color: AppColors.success,
                                                size: 10),
                                            SizedBox(width: 3),
                                            Text(
                                              'Taken',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      medicine.dosage,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '•',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    MedicineTypeChip(
                                        type: medicine.type, small: true),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppDateUtils.formatTimeString(
                                          medicine.reminderTime),
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.repeat_rounded,
                                      size: 14,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      medicine.frequencyLabel,
                                      style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Interactive Take Action Button
                          GestureDetector(
                            onTap: taken ? null : onMarkTaken,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: taken
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: taken
                                      ? AppColors.success.withValues(alpha: 0.2)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                taken
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: taken ? AppColors.success : AppColors.textHint,
                                size: taken ? 22 : 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Medicine'),
        content: Text(
            'Are you sure you want to delete "${medicine.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
