import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/hydration_entry_model.dart';
import '../../../shared/widgets/indicators/loading_widget.dart';
import '../cubit/hydration_cubit.dart';
import '../cubit/hydration_state.dart';
import '../../hydration/ui/add_water_screen.dart';
import '../../../shared/widgets/cards/water_entry_card.dart';

class HydrationScreen extends StatefulWidget {
  final String userId;
  final String uid;

  // Daily goal in ml — passed from profile or defaults to 2000
  final int dailyGoalMl;

  const HydrationScreen({
    super.key,
    required this.userId,
    required this.uid,
    this.dailyGoalMl = 2000,
  });

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HydrationCubit>().loadHydrationEntries(widget.userId);
  }

  Future<void> _navigateToAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<HydrationCubit>(),
          child: AddWaterScreen(
            userId: widget.userId,
            uid: widget.uid,
          ),
        ),
      ),
    );
    if (mounted) {
      context.read<HydrationCubit>().loadHydrationEntries(widget.userId);
    }
  }

  Future<void> _navigateToEdit(HydrationEntryModel entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<HydrationCubit>(),
          child: AddWaterScreen(
            userId: widget.userId,
            uid: widget.uid,
            existingEntry: entry,
          ),
        ),
      ),
    );
    if (mounted) {
      context.read<HydrationCubit>().loadHydrationEntries(widget.userId);
    }
  }

  void _confirmDelete(String entryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Entry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: const Text(
          'Are you sure you want to remove this water entry?',
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
              context.read<HydrationCubit>().deleteHydrationEntry(
                    entryId,
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

  void _quickAdd(int amountMl) {
    final now = DateTime.now();
    final entry = HydrationEntryModel(
      id: const Uuid().v4(),
      userId: widget.userId,
      amountMl: amountMl,
      type: 'Water',
      dailyGoalMl: widget.dailyGoalMl,
      timestamp: now,
      updatedAt: now,
      isSynced: false,
    );
    context.read<HydrationCubit>().addHydrationEntry(entry, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HydrationCubit, HydrationState>(
      listener: (context, state) {
        if (state is HydrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        appBar: AppBar(
          title: const Text(AppStrings.hydrationTracker),
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
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAdd,
          backgroundColor: AppColors.hydrationRing,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
        body: BlocBuilder<HydrationCubit, HydrationState>(
          builder: (context, state) {
            if (state is HydrationLoading) {
              return const LoadingWidget(
                  message: 'Loading hydration data...');
            }

            if (state is HydrationError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<HydrationCubit>()
                    .loadHydrationEntries(widget.userId),
              );
            }

            if (state is HydrationLoaded) {
              final entries = state.entries;
              final totalMl = entries.fold<int>(
                0,
                (sum, e) => sum + e.amountMl,
              );
              final remainingMl =
                  (widget.dailyGoalMl - totalMl).clamp(0, widget.dailyGoalMl);
              final progress =
                  (totalMl / widget.dailyGoalMl).clamp(0.0, 1.0);

              // Newest entries first in the list
              final sortedEntries = [...entries]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return RefreshIndicator(
                color: AppColors.hydrationRing,
                onRefresh: () async {
                  context
                      .read<HydrationCubit>()
                      .loadHydrationEntries(widget.userId);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  children: [
                    const SizedBox(height: 8),

                    Text(
                      'Stay hydrated throughout the day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF888888),
                          ),
                    ),
                    const SizedBox(height: 20),

                    _DailySummaryCard(
                      totalMl: totalMl,
                      goalMl: widget.dailyGoalMl,
                      remainingMl: remainingMl,
                      progress: progress,
                    ),
                    const SizedBox(height: 22),

                    const _SectionLabel('Quick Add'),
                    const SizedBox(height: 10),
                    _QuickAddRow(onAdd: _quickAdd),
                    const SizedBox(height: 24),

                    const _SectionLabel("Today's Intake"),
                    const SizedBox(height: 12),

                    if (sortedEntries.isEmpty)
                      _EmptyHydrationView(onAdd: _navigateToAdd)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = sortedEntries[index];
                          return WaterEntryCard(
                            entry: entry,
                            onEdit: () => _navigateToEdit(entry),
                            onDelete: () => _confirmDelete(entry.id),
                            onTap: () => _navigateToEdit(entry),
                          );
                        },
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final int totalMl;
  final int goalMl;
  final int remainingMl;
  final double progress;

  const _DailySummaryCard({
    required this.totalMl,
    required this.goalMl,
    required this.remainingMl,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.hydrationRing,
            AppColors.steelColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.hydrationRing.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: title + percentage ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            '$totalMl ml',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _StatChip(label: 'Goal', value: '$goalMl ml'),
              const SizedBox(width: 10),
              _StatChip(
                label: AppStrings.remaining,
                value: '$remainingMl ml',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddRow extends StatelessWidget {
  final ValueChanged<int> onAdd;

  const _QuickAddRow({required this.onAdd});

  static const List<int> _presets = [150, 250, 350, 500];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _presets.map((amount) {
          return GestureDetector(
            onTap: () => onAdd(amount),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.hydrationRing.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.hydrationRing.withOpacity(0.40),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 14,
                    color: AppColors.hydrationRing,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '+$amount ml',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hydrationRing,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }
}

class _EmptyHydrationView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyHydrationView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.hydrationRing.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_rounded,
                size: 40,
                color: AppColors.hydrationRing,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No water intake logged today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap + to log your first entry',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.hydrationRing,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Add Water Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
                  color: AppColors.hydrationRing),
              label: Text(
                AppStrings.tryAgain,
                style: TextStyle(
                  color: AppColors.hydrationRing,
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
