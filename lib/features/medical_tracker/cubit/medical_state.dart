// ============================================================
// medical_state.dart
// lib/features/medical_tracker/cubit/medical_state.dart
//
// PURPOSE:
//   Defines all possible UI states for the medical tracker
//   feature. The MedicalCubit emits these states in response
//   to CRUD operations and data loading events.
//
// STATES:
//   MedicalInitial → before any action has been taken
//   MedicalLoading → async operation in progress
//   MedicalLoaded  → records fetched successfully from SQLite
//   MedicalError   → operation failed, message describes why
//
// RULES:
//   - All states are immutable
//   - MedicalLoaded carries the full records list
//   - MedicalError carries a user-facing message string
//   - No business logic lives here — states are pure data
// ============================================================

import '../../../data/models/medical_record_model.dart';

// ══════════════════════════════════════════════════════════════
// BASE STATE
// ══════════════════════════════════════════════════════════════

abstract class MedicalState {}

// ══════════════════════════════════════════════════════════════
// INITIAL
// Emitted once when MedicalCubit is first created.
// The UI renders nothing or a prompt to load data.
// ══════════════════════════════════════════════════════════════

class MedicalInitial extends MedicalState {}

// ══════════════════════════════════════════════════════════════
// LOADING
// Emitted at the start of every async operation:
//   loadMedicalRecords / addMedicalRecord /
//   updateMedicalRecord / deleteMedicalRecord
// The UI should show a loading indicator while in this state.
// ══════════════════════════════════════════════════════════════

class MedicalLoading extends MedicalState {}

// ══════════════════════════════════════════════════════════════
// LOADED
// Emitted after a successful read from SQLite.
// Carries the full list of records for the current user.
// An empty list is valid — it means the user has no records.
// ══════════════════════════════════════════════════════════════

class MedicalLoaded extends MedicalState {
  // The complete list of medical records for the current user.
  // Ordered by createdAt DESC as returned by LocalMedicalService.
  final List<MedicalRecordModel> records;

  MedicalLoaded(this.records);
}

// ══════════════════════════════════════════════════════════════
// ERROR
// Emitted when any CRUD operation throws an exception.
// message is a user-facing string shown in the UI.
// The UI should display the message and allow retry.
// ══════════════════════════════════════════════════════════════

class MedicalError extends MedicalState {
  // Human-readable error description shown to the user.
  final String message;

  MedicalError(this.message);
}
