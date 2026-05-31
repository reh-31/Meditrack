import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/medicine_history.dart';
import '../providers/medicine_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HistoryScreen — grouped intake history with stats and date filter
/// ─────────────────────────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (_filterDate != null)
            TextButton.icon(
              onPressed: () => setState(() => _filterDate = null),
              icon: const Icon(Icons.close, color: Colors.white, size: 16),
              label: const Text(
                AppStrings.clearFilter,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          IconButton(
            icon: Icon(
              _filterDate != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: Colors.white,
            ),
            onPressed: _pickFilterDate,
            tooltip: AppStrings.filterByDate,
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          // Stats row
          final stats = _buildStatsRow(provider);

          // Filtered history
          List<MedicineHistory> history;
          if (_filterDate != null) {
            history = provider.historyForDate(_filterDate!);
          } else {
            history = provider.history;
          }

          if (history.isEmpty) {
            return Column(
              children: [
                stats,
                Expanded(
                  child: EmptyState(
                    title: AppStrings.noHistory,
                    subtitle: AppStrings.noHistorySubtitle,
                    icon: Icons.history_rounded,
                  ),
                ),
              ],
            );
          }

          // Group history by smart date
          final grouped = AppDateUtils.groupByDate<MedicineHistory>(
            history,
            (h) => h.takenAt,
          );
          final keys = grouped.keys.toList();

          return Column(
            children: [
              stats,
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100, top: 4),
                  itemCount: keys.length,
                  itemBuilder: (context, sectionIndex) {
                    final dateKey = keys[sectionIndex];
                    final items = grouped[dateKey]!;

                    return Animate(
                      effects: [
                        FadeEffect(
                          duration: 300.ms,
                          delay: (sectionIndex * 50).ms,
                        ),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    dateKey,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.primary.withOpacity(0.2),
                                    thickness: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${items.length} dose${items.length > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // History items
                          ...items.asMap().entries.map((entry) {
                            return _buildHistoryTile(entry.value, entry.key);
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(MedicineProvider provider) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: AppStrings.takenToday,
              value: provider.todayDoseCount.toString(),
              icon: Icons.today_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              label: AppStrings.weeklyStreak,
              value: provider.weeklyDoseCount.toString(),
              icon: Icons.calendar_view_week_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              label: AppStrings.totalDoses,
              value: provider.totalDoseCount.toString(),
              icon: Icons.analytics_rounded,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(MedicineHistory history, int index) {
    Color typeColor;
    switch (history.medicineType.toLowerCase()) {
      case 'tablet':
        typeColor = AppColors.tablet;
        break;
      case 'capsule':
        typeColor = AppColors.capsule;
        break;
      case 'syrup':
        typeColor = AppColors.syrup;
        break;
      case 'injection':
        typeColor = AppColors.injection;
        break;
      case 'drops':
        typeColor = AppColors.drops;
        break;
      case 'cream':
        typeColor = AppColors.cream;
        break;
      default:
        typeColor = AppColors.other;
    }

    return Animate(
      effects: [
        FadeEffect(duration: 250.ms, delay: (index * 40).ms),
        SlideEffect(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
          duration: 250.ms,
          delay: (index * 40).ms,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: typeColor.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            // Check icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.medicineName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${history.medicineDosage} · ${history.medicineType}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppDateUtils.formatTime(history.takenAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'taken',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
    }
  }
}
