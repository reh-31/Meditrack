import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AddMedicineScreen — form to add or edit a medicine
/// Pass [medicine] to edit an existing one, leave null for new.
/// ─────────────────────────────────────────────────────────────────────────────
class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine; // null = add mode, non-null = edit mode

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _notesController;

  late String _selectedType;
  late String _selectedFrequency;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;

  bool get _isEditMode => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _nameController = TextEditingController(text: m?.name ?? '');
    _dosageController = TextEditingController(text: m?.dosage ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
    _selectedType = m?.type ?? AppStrings.medicineTypes.first;
    _selectedFrequency = m?.frequency ?? 'daily';

    if (m != null) {
      final parts = m.reminderTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditMode
            ? AppStrings.editMedicineTitle
            : AppStrings.addMedicineTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Name field
            _buildSectionLabel('Medicine Name', Icons.medication_rounded),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: AppStrings.medicineNameHint,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? AppStrings.required : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 18),

            // Dosage field
            _buildSectionLabel('Dosage', Icons.scale_rounded),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _dosageController,
              hint: AppStrings.dosageHint,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? AppStrings.required : null,
            ),
            const SizedBox(height: 18),

            // Medicine Type
            _buildSectionLabel('Medicine Type', Icons.category_rounded),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            const SizedBox(height: 18),

            // Reminder Time
            _buildSectionLabel('Reminder Time', Icons.alarm_rounded),
            const SizedBox(height: 8),
            _buildTimePicker(),
            const SizedBox(height: 18),

            // Frequency
            _buildSectionLabel('Frequency', Icons.repeat_rounded),
            const SizedBox(height: 8),
            _buildFrequencySelector(),
            const SizedBox(height: 18),

            // Notes
            _buildSectionLabel('Notes (Optional)', Icons.notes_rounded),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _notesController,
              hint: AppStrings.notesHint,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save button
            _buildSaveButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────── Widgets ─────────────────────────────────

  Widget _buildHeaderCard() {
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms),
        SlideEffect(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
          duration: 400.ms,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isEditMode ? Icons.edit_rounded : Icons.add_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Medicine' : 'New Medicine',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditMode
                        ? 'Update the details below'
                        : 'Fill in the details to set up a reminder',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(hintText: hint),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppStrings.medicineTypes.map((type) {
        final selected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: _buildTypeChipItem(type, selected),
        );
      }).toList(),
    );
  }

  Widget _buildTypeChipItem(String type, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1.5,
        ),
        boxShadow: selected ? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Text(
        type,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedTime == null
                ? AppColors.error.withValues(alpha: 0.5)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.alarm_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Tap to pick a time',
                style: TextStyle(
                  color: _selectedTime != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  fontSize: 15,
                  fontWeight: _selectedTime != null
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    const frequencies = [
      {'value': 'daily', 'label': 'Once Daily', 'icon': Icons.looks_one_rounded},
      {
        'value': 'twice_daily',
        'label': 'Twice Daily',
        'icon': Icons.looks_two_rounded
      },
      {
        'value': 'thrice_daily',
        'label': 'Thrice Daily',
        'icon': Icons.looks_3_rounded
      },
      {'value': 'weekly', 'label': 'Weekly', 'icon': Icons.date_range_rounded},
    ];

    return Column(
      children: frequencies.map((f) {
        final value = f['value'] as String;
        final label = f['label'] as String;
        final icon = f['icon'] as IconData;
        final selected = _selectedFrequency == value;

        return GestureDetector(
          onTap: () => setState(() => _selectedFrequency = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? AppColors.primary : AppColors.textHint,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveForm,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                _isEditMode ? Icons.save_rounded : Icons.add_circle_rounded),
        label: Text(_isEditMode ? AppStrings.update : AppStrings.save),
      ),
    );
  }

  // ─────────────────────────────── Actions ─────────────────────────────────

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pickTime),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<MedicineProvider>();
      final timeString =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      if (_isEditMode) {
        final updated = widget.medicine!.copyWith(
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          type: _selectedType,
          reminderTime: timeString,
          frequency: _selectedFrequency,
          notes: _notesController.text.trim(),
        );
        await provider.updateMedicine(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.medicineUpdated),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await provider.addMedicine(
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          type: _selectedType,
          reminderTime: timeString,
          frequency: _selectedFrequency,
          notes: _notesController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.medicineSaved),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
