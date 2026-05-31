/// ─────────────────────────────────────────────────────────────────────────────
/// MediTrack String Constants
/// Centralised strings for easy localisation later.
/// ─────────────────────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MediTrack';
  static const String appTagline = 'Your Personal Medicine Companion';

  // Home
  static const String homeTitle = 'My Medicines';
  static const String searchHint = 'Search medicines…';
  static const String addMedicine = 'Add Medicine';
  static const String noMedicines = 'No medicines added yet';
  static const String noMedicinesSubtitle =
      'Tap the + button to add your first medicine reminder';
  static const String noSearchResults = 'No medicines match your search';

  // Add / Edit Medicine
  static const String addMedicineTitle = 'Add Medicine';
  static const String editMedicineTitle = 'Edit Medicine';
  static const String medicineName = 'Medicine Name';
  static const String medicineNameHint = 'e.g. Paracetamol';
  static const String dosage = 'Dosage';
  static const String dosageHint = 'e.g. 500mg';
  static const String medicineType = 'Medicine Type';
  static const String reminderTime = 'Reminder Time';
  static const String frequency = 'Frequency';
  static const String notes = 'Notes (optional)';
  static const String notesHint = 'Any special instructions…';
  static const String save = 'Save Medicine';
  static const String update = 'Update Medicine';
  static const String cancel = 'Cancel';

  // Frequency options
  static const String daily = 'Once Daily';
  static const String twiceDaily = 'Twice Daily';
  static const String thriceDaily = 'Thrice Daily';
  static const String weekly = 'Weekly';

  // Medicine types
  static const List<String> medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Cream',
    'Inhaler',
    'Patch',
    'Other',
  ];

  // Detail
  static const String markAsTaken = 'Mark as Taken';
  static const String alreadyTaken = 'Already Taken Today';
  static const String editMedicine = 'Edit';
  static const String deleteMedicine = 'Delete';
  static const String confirmDelete = 'Delete Medicine';
  static const String confirmDeleteMsg =
      'Are you sure you want to delete this medicine? This action cannot be undone.';
  static const String delete = 'Delete';

  // History
  static const String historyTitle = 'Intake History';
  static const String noHistory = 'No history yet';
  static const String noHistorySubtitle =
      'Mark medicines as taken to build your history';
  static const String takenToday = 'Taken Today';
  static const String weeklyStreak = 'This Week';
  static const String totalDoses = 'Total Doses';
  static const String filterByDate = 'Filter by Date';
  static const String clearFilter = 'Clear Filter';

  // Notifications
  static const String notifTitle = 'Time to take your medicine!';
  static const String notifBody = 'Don\'t forget your dose of ';
  static const String channelId = 'meditrack_reminders';
  static const String channelName = 'Medicine Reminders';
  static const String channelDesc =
      'Scheduled reminders to take your medicines on time.';

  // Validation
  static const String required = 'This field is required';
  static const String pickTime = 'Please pick a reminder time';

  // Snackbars
  static const String medicineSaved = 'Medicine saved successfully!';
  static const String medicineUpdated = 'Medicine updated successfully!';
  static const String medicineDeleted = 'Medicine deleted';
  static const String markedAsTaken = 'Marked as taken ✓';
}
