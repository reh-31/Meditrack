import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/medicine_card.dart';
import 'add_medicine_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// MedicineDetailScreen — full detail view with edit and mark-as-taken actions
/// ─────────────────────────────────────────────────────────────────────────────
class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  late Medicine _medicine;
  bool _isMarkingTaken = false;

  @override
  void initState() {
    super.initState();
    _medicine = widget.medicine;
  }

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
    final color = _typeColor(_medicine.type);
    final taken = _medicine.takenToday;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Stylish app bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: _navigateToEdit,
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _confirmDelete,
                tooltip: 'Delete',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Medicine icon
                            Hero(
                              tag: 'medicine_${_medicine.id}',
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.medication_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _medicine.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _medicine.dosage,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                _medicine.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info chips
                  Animate(
                    effects: [
                      FadeEffect(duration: 400.ms, delay: 100.ms),
                      SlideEffect(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                        duration: 400.ms,
                        delay: 100.ms,
                      ),
                    ],
                    child: Row(
                      children: [
                        MedicineTypeChip(type: _medicine.type),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.repeat_rounded,
                          _medicine.frequencyLabel,
                          AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        if (taken)
                          _buildInfoChip(
                            Icons.check_circle,
                            'Taken',
                            AppColors.success,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details card
                  Animate(
                    effects: [
                      FadeEffect(duration: 400.ms, delay: 150.ms),
                      SlideEffect(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                        duration: 400.ms,
                        delay: 150.ms,
                      ),
                    ],
                    child: _buildDetailsCard(color),
                  ),
                  const SizedBox(height: 20),

                  // Notes card
                  if (_medicine.notes.isNotEmpty) ...[
                    Animate(
                      effects: [
                        FadeEffect(duration: 400.ms, delay: 200.ms),
                      ],
                      child: _buildNotesCard(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Mark as taken button
                  Animate(
                    effects: [
                      FadeEffect(duration: 400.ms, delay: 250.ms),
                      ScaleEffect(duration: 400.ms, delay: 250.ms),
                    ],
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed:
                            (taken || _isMarkingTaken) ? null : _markAsTaken,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              taken ? AppColors.success : AppColors.primary,
                          disabledBackgroundColor: taken
                              ? AppColors.success.withOpacity(0.6)
                              : null,
                          foregroundColor: Colors.white,
                        ),
                        icon: _isMarkingTaken
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                taken
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline_rounded,
                              ),
                        label: Text(
                          taken
                              ? AppStrings.alreadyTaken
                              : AppStrings.markAsTaken,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.medication_rounded,
            'Medicine Name',
            _medicine.name,
            color,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.scale_rounded,
            'Dosage',
            _medicine.dosage,
            color,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.category_rounded,
            'Type',
            _medicine.type,
            color,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.access_time_rounded,
            'Reminder Time',
            AppDateUtils.formatTimeString(_medicine.reminderTime),
            AppColors.accent,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.repeat_rounded,
            'Frequency',
            _medicine.frequencyLabel,
            AppColors.primary,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Added On',
            AppDateUtils.formatDate(_medicine.createdAt),
            AppColors.textSecondary,
          ),
          if (_medicine.lastTakenAt != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              Icons.check_circle_rounded,
              'Last Taken',
              AppDateUtils.formatDateTime(_medicine.lastTakenAt!),
              AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _medicine.notes,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── Actions ─────────────────────────────────

  Future<void> _markAsTaken() async {
    setState(() => _isMarkingTaken = true);
    try {
      await context.read<MedicineProvider>().markAsTaken(_medicine);
      // Refresh local state
      final provider = context.read<MedicineProvider>();
      final updated =
          provider.medicines.firstWhere((m) => m.id == _medicine.id,
          orElse: () => _medicine);
      setState(() => _medicine = updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${_medicine.name} — ${AppStrings.markedAsTaken}'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isMarkingTaken = false);
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicineScreen(medicine: _medicine),
      ),
    );
    if (result == true && mounted) {
      final provider = context.read<MedicineProvider>();
      final updated = provider.medicines.firstWhere(
        (m) => m.id == _medicine.id,
        orElse: () => _medicine,
      );
      setState(() => _medicine = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.confirmDelete),
        content: Text(AppStrings.confirmDeleteMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<MedicineProvider>().deleteMedicine(_medicine.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
