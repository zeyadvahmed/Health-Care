import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/indicators/loading_widget.dart';
import '../cubit/medical_cubit.dart';
import '../cubit/medical_state.dart';
import 'widgets/medication_card.dart';
import 'add_medication_screen.dart';

class MedicalTrackerScreen extends StatefulWidget {
  // userId and uid must be passed from the parent (e.g. HomeScreen)
  // after authentication — never hardcoded here.
  final String userId;
  final String uid;

  const MedicalTrackerScreen({
    super.key,
    required this.userId,
    required this.uid,
  });

  @override
  State<MedicalTrackerScreen> createState() => _MedicalTrackerScreenState();
}

class _MedicalTrackerScreenState extends State<MedicalTrackerScreen> {
  @override
  void initState() {
    super.initState();
    // Load records once on mount — cubit handles the rest
    context.read<MedicalCubit>().loadMedicalRecords(widget.userId);
  }


  Future<void> _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MedicalCubit>(),
          child: AddMedicationScreen(
            userId: widget.userId,
            uid: widget.uid,
          ),
        ),
      ),
    );
    // Reload after returning — covers both save and cancel
    if (mounted) {
      context.read<MedicalCubit>().loadMedicalRecords(widget.userId);
    }
  }

  Future<void> _navigateToEdit(String recordId) async {
    final record = await context
        .read<MedicalCubit>()
        .getMedicalRecordById(recordId);
    if (record == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MedicalCubit>(),
          child: AddMedicationScreen(
            userId: widget.userId,
            uid: widget.uid,
            existingRecord: record,
          ),
        ),
      ),
    );
    if (mounted) {
      context.read<MedicalCubit>().loadMedicalRecords(widget.userId);
    }
  }


  void _confirmDelete(String recordId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Medication',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this medication? This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MedicalCubit>().deleteMedicalRecord(
                    recordId,
                    widget.userId,
                    widget.uid,
                  );
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: const Text(AppStrings.medicalTracker),
        backgroundColor: const Color(0xFFF6F7F8),
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: BlocBuilder<MedicalCubit, MedicalState>(
        builder: (context, state) {
          // ── Loading state ──────────────────────────────
          if (state is MedicalLoading) {
            return const LoadingWidget(message: 'Loading medications...');
          }

          // ── Error state ────────────────────────────────
          if (state is MedicalError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<MedicalCubit>()
                  .loadMedicalRecords(widget.userId),
            );
          }

          // ── Loaded state ───────────────────────────────
          if (state is MedicalLoaded) {
            final records = state.records;
            final takenCount =
                records.where((r) => r.isTaken).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Daily progress card ──────────────
                  _DailyProgressCard(
                    total: records.length,
                    taken: takenCount,
                  ),
                  const SizedBox(height: 24),

                  // ── Section header ───────────────────
                  const Text(
                    AppStrings.medications,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Empty state ──────────────────────
                  if (records.isEmpty)
                    _EmptyMedicationsView(onAdd: _navigateToAdd)
                  else
                    // ── Medication list ──────────────
                    ListView.builder(
                      itemCount: records.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return MedicationCard(
                          medicationName: record.name,
                          dosage: record.dosage,
                          frequency: record.frequency,
                          reminderTime: record.scheduleTimes.join(', '),
                          isTaken: record.isTaken,
                          onEdit: () => _navigateToEdit(record.id),
                          onDelete: () => _confirmDelete(record.id),
                          onToggleTaken: () {
                            context.read<MedicalCubit>().updateMedicalRecord(
                                  record.copyWith(isTaken: !record.isTaken),
                                  widget.uid,
                                );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          }

          // ── Initial state — show nothing until load ────
          return const SizedBox.shrink();
        },
      ),

      // ── FAB — add new medication ───────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: const Color(0xFF0D2137),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}


class _DailyProgressCard extends StatelessWidget {
  final int total;
  final int taken;

  const _DailyProgressCard({
    required this.total,
    required this.taken,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : taken / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.steelColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // ── Text side ────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$taken of $total Done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ── Icon badge ────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyMedicationsView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyMedicationsView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.steelColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                size: 40,
                color: AppColors.steelColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No medications yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to add your first medication',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.steelColor),
              label: const Text(
                AppStrings.tryAgain,
                style: TextStyle(
                  color: AppColors.steelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
