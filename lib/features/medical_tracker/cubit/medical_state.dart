import '../../../data/models/medical_record_model.dart';

abstract class MedicalState {}

class MedicalInitial extends MedicalState {}


class MedicalLoading extends MedicalState {}


class MedicalLoaded extends MedicalState {
  // The complete list of medical records for the current user.
  // Ordered by createdAt DESC as returned by LocalMedicalService.
  final List<MedicalRecordModel> records;

  MedicalLoaded(this.records);
}


class MedicalError extends MedicalState {
  // Human-readable error description shown to the user.
  final String message;

  MedicalError(this.message);
}
