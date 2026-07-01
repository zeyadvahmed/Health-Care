import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/activity_model.dart';
import '../../../shared/widgets/indicators/loading_widget.dart';
import '../../../shared/widgets/cards/activity_card.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';

class ActivityScreen extends StatefulWidget {
  final String userId;
  final String uid;
  final String userName;
  final String? avatarUrl;

  const ActivityScreen({
    super.key,
    required this.userId,
    required this.uid,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityCubit>().loadActivity(widget.userId, widget.uid);
  }

  String _levelTitle(int level) {
    if (level < 3) return 'Beginner';
    if (level < 6) return 'Explorer';
    if (level < 10) return 'Athlete';
    if (level < 15) return 'Champion';
    return 'Legend';
  }

  void _showLevelUpDialog(ActivityLevelUp state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.xpGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.congratulations,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.levelUpMessage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.steelColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Level ${state.oldLevel} → Level ${state.newLevel}  (+${state.earnedXp} XP)',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                AppStrings.levelUpSubtitle,
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Reload to show updated level in UI
                    context
                        .read<ActivityCubit>()
                        .loadActivity(widget.userId, widget.uid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.steelColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    AppStrings.collectContinue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityCubit, ActivityState>(
      listener: (context, state) {
        // ── Level-up → show dialog ─────────────────────
        if (state is ActivityLevelUp) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showLevelUpDialog(state),
          );
        }

        // ── Challenge completed → snackbar ────────────
        if (state is ChallengeCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Challenge complete: ${state.challenge.title}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        // ── Reward claimed → XP toast ─────────────────
        if (state is RewardClaimed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '+${state.xpAwarded} XP earned — ${state.challengeTitle}',
              ),
              backgroundColor: AppColors.xpGold,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        // ── Error → snackbar ──────────────────────────
        if (state is ActivityError) {
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
          title: const Text(AppStrings.activity),
          backgroundColor: const Color(0xFFF6F7F8),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: BlocBuilder<ActivityCubit, ActivityState>(
          // Only rebuild on data states — not on transient events
          buildWhen: (prev, curr) =>
              curr is ActivityLoaded ||
              curr is ActivityLoading ||
              curr is ActivityError,
          builder: (context, state) {
            if (state is ActivityLoading) {
              return const LoadingWidget(message: 'Loading activity...');
            }

            if (state is ActivityError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<ActivityCubit>()
                    .loadActivity(widget.userId, widget.uid),
              );
            }

            if (state is ActivityLoaded) {
              return RefreshIndicator(
                color: AppColors.steelColor,
                onRefresh: () => context
                    .read<ActivityCubit>()
                    .loadActivity(widget.userId, widget.uid),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    // ── Profile header ────────────────
                    _ProfileHeader(
                      activity: state.activity,
                      userName: widget.userName,
                      avatarUrl: widget.avatarUrl,
                      levelTitle: _levelTitle(state.activity.currentLevel),
                    ),
                    const SizedBox(height: 20),

                    // ── Progress card ─────────────────
                    _ProgressCard(activity: state.activity),
                    const SizedBox(height: 24),

                    // ── Daily Challenges ──────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.dailyChallenges,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            AppStrings.viewAll,
                            style: TextStyle(
                              color: AppColors.steelColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Dynamic challenge list from SQLite
                    if (state.challenges.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No challenges today',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.challenges.length,
                        itemBuilder: (context, index) {
                          return ActivityCard(
                            challenge: state.challenges[index],
                          );
                        },
                      ),

                    const SizedBox(height: 8),

                    // ── Friends Leaderboard ───────────
                    const Text(
                      AppStrings.friendsLeaderboard,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _LeaderboardCard(
                      currentUserXp: state.activity.totalXp,
                      userName: widget.userName,
                      avatarUrl: widget.avatarUrl,
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

class _ProfileHeader extends StatelessWidget {
  final ActivityModel activity;
  final String userName;
  final String? avatarUrl;
  final String levelTitle;

  const _ProfileHeader({
    required this.activity,
    required this.userName,
    required this.avatarUrl,
    required this.levelTitle,
  });

  String _formatXp(int n) =>
      n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.steelColor.withOpacity(0.15),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person_rounded,
                      size: 36, color: AppColors.steelColor)
                  : null,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.steelColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'LVL ${activity.currentLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              levelTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_formatXp(activity.totalXp)} XP Total',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final ActivityModel activity;

  const _ProgressCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = activity.currentLevel * 500;
    final xpForNextLevel = (activity.currentLevel + 1) * 500;
    final xpInLevel = activity.totalXp - xpForCurrentLevel;
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    final progress = xpNeeded <= 0 ? 1.0 : (xpInLevel / xpNeeded).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.steelColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.currentProgress,
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level ${activity.currentLevel + 1}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)),
                  ),
                ],
              ),
              Text(
                '$xpInLevel / $xpNeeded XP',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFDDE8F5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.steelColor),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Earn ${activity.xpToNextLevel} more XP to unlock next level',
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final int currentUserXp;
  final String userName;
  final String? avatarUrl;

  const _LeaderboardCard({
    required this.currentUserXp,
    required this.userName,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Sort-aware mock entries — current user rank is dynamic
    final others = [
      _LeaderEntry(rank: 1, name: 'Basmala Hisham', xp: 3120, isUser: false),
      _LeaderEntry(rank: 2, name: 'Omar Mohamed', xp: 2820, isUser: false),
    ];

    // Compute user rank dynamically based on real XP
    final userRank = others.where((e) => e.xp > currentUserXp).length + 1;

    final entries = [
      ...others,
      _LeaderEntry(
          rank: userRank, name: 'You', xp: currentUserXp, isUser: true),
    ]..sort((a, b) => b.xp.compareTo(a.xp));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.steelColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelColor.withOpacity(0.20)),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final isLast = e.key == entries.length - 1;
          return Column(
            children: [
              _LeaderboardRow(
                entry: e.value,
                avatarUrl: e.value.isUser ? avatarUrl : null,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: AppColors.steelColor.withOpacity(0.15),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LeaderEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isUser;
  const _LeaderEntry(
      {required this.rank,
      required this.name,
      required this.xp,
      required this.isUser});
}

class _LeaderboardRow extends StatelessWidget {
  final _LeaderEntry entry;
  final String? avatarUrl;
  const _LeaderboardRow({required this.entry, this.avatarUrl});

  String _fmt(int xp) => xp
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: entry.isUser
                    ? AppColors.steelColor
                    : const Color(0xFF888888),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.steelColor.withOpacity(0.15),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(Icons.person_rounded,
                    size: 20,
                    color: entry.isUser
                        ? AppColors.steelColor
                        : const Color(0xFF888888))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: entry.isUser
                    ? AppColors.steelColor
                    : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            '${_fmt(entry.xp)} XP',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.steelColor,
            ),
          ),
        ],
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
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.steelColor),
              label: const Text(AppStrings.tryAgain,
                  style: TextStyle(
                      color: AppColors.steelColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}