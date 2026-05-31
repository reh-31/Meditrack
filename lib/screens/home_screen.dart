import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../widgets/empty_state.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';
import 'history_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// HomeScreen — main landing screen with medicine list
/// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<MedicineProvider>().clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0 ? _buildHomeBody() : const HistoryScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeBody() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverAppBar(innerBoxIsScrolled),
      ],
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final medicines = provider.medicines;

          if (medicines.isEmpty) {
            return EmptyState(
              title: _isSearching
                  ? AppStrings.noSearchResults
                  : AppStrings.noMedicines,
              subtitle: _isSearching
                  ? 'Try a different search term'
                  : AppStrings.noMedicinesSubtitle,
              icon: _isSearching
                  ? Icons.search_off_rounded
                  : Icons.medication_outlined,
              actionLabel:
                  _isSearching ? null : AppStrings.addMedicine,
              onAction: _isSearching ? null : _navigateToAddMedicine,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                return MedicineCard(
                  medicine: medicine,
                  index: index,
                  onTap: () => _navigateToDetail(medicine.id),
                  onMarkTaken: () => _markAsTaken(medicine.id),
                  onDelete: () => _deleteMedicine(medicine.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: innerBoxIsScrolled ? 4 : 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Personalized greeting layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay Healthy,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Search button glass circle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              key: ValueKey(_isSearching),
                              color: Colors.white,
                            ),
                          ),
                          onPressed: _toggleSearch,
                          tooltip: 'Search',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Glassmorphic modern stats row
                  Consumer<MedicineProvider>(
                    builder: (_, prov, __) {
                      final count = prov.medicines.length;
                      final taken = prov.todayDoseCount;
                      return Row(
                        children: [
                          _buildStatPill(
                              '$count', 'medications', Icons.medication_rounded),
                          const SizedBox(width: 10),
                          _buildStatPill(
                              '$taken', 'taken today', Icons.check_circle_rounded),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        title: _isSearching
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 16),
                    border: InputBorder.none,
                    filled: false,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (v) =>
                      context.read<MedicineProvider>().updateSearchQuery(v),
                ),
              )
            : const Text(
                AppStrings.homeTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildStatPill(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
        ],
      ),
    );
  }

  // ───────────────────────────── Navigation ─────────────────────────────────

  Future<void> _navigateToAddMedicine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
  }

  Future<void> _navigateToDetail(String medicineId) async {
    final provider = context.read<MedicineProvider>();
    final medicine = provider.medicines.firstWhere((m) => m.id == medicineId);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineDetailScreen(medicine: medicine),
      ),
    );
  }

  Future<void> _markAsTaken(String medicineId) async {
    final provider = context.read<MedicineProvider>();
    final medicine = provider.medicines.firstWhere((m) => m.id == medicineId);
    if (medicine.takenToday) return;

    try {
      await provider.markAsTaken(medicine);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${medicine.name} — ${AppStrings.markedAsTaken}'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')),
        );
      }
    }
  }

  Future<void> _deleteMedicine(String medicineId) async {
    try {
      await context.read<MedicineProvider>().deleteMedicine(medicineId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.medicineDeleted)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete medicine')),
        );
      }
    }
  }

  // FAB is attached to the Scaffold through the main app
}
