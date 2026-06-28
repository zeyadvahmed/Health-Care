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

  // User display data passed from parent (profile)
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
  // Tracks the previous level to detect level-up events
  int _previousLevel = -1;

  @override
  void initState() {
    super.initState();
    context.read<ActivityCubit>().loadActivity(widget.userId);
  }

  String _levelTitle(int level) {
    if (level < 3) return 'Beginner';
    if (level < 6) return 'Explorer';
    if (level < 10) return 'Athlete';
    if (level < 15) return 'Champion';
    return 'Legend';
  }

  void _showLevelUpDialog() {
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
              // Gold star circle
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
              const Text(
                AppStrings.levelUpSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
        // Detect level-up and show congratulations dialog
        if (state is ActivityLoaded) {
          final newLevel = state.activity.currentLevel;
          if (_previousLevel != -1 && newLevel > _previousLevel) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _showLevelUpDialog(),
            );
          }
          _previousLevel = newLevel;
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
          builder: (context, state) {
            if (state is ActivityLoading) {
              return const LoadingWidget(message: 'Loading activity...');
            }

            if (state is ActivityError) {
              return _ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<ActivityCubit>()
                    .loadActivity(widget.userId),
              );
            }

            if (state is ActivityLoaded) {
              return _ActivityBody(
                activity: state.activity,
                userName: widget.userName,
                avatarUrl: widget.avatarUrl,
                levelTitle: _levelTitle(state.activity.currentLevel),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ActivityBody extends StatelessWidget {
  final ActivityModel activity;
  final String userName;
  final String? avatarUrl;
  final String levelTitle;

  const _ActivityBody({
    required this.activity,
    required this.userName,
    required this.avatarUrl,
    required this.levelTitle,
  });

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = activity.currentLevel * 500;
    final xpForNextLevel = (activity.currentLevel + 1) * 500;
    final xpProgress = xpForNextLevel == xpForCurrentLevel
        ? 0.0
        : ((activity.totalXp - xpForCurrentLevel) /
                (xpForNextLevel - xpForCurrentLevel))
            .clamp(0.0, 1.0);

    return RefreshIndicator(
      color: AppColors.steelColor,
      onRefresh: () async =>
          context.read<ActivityCubit>().loadActivity(activity.userId),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Section 1: Profile header ─────────────────
          _ProfileHeader(
            userName: userName,
            avatarUrl: avatarUrl,
            levelTitle: levelTitle,
            totalXp: activity.totalXp,
            currentLevel: activity.currentLevel,
          ),
          const SizedBox(height: 20),

          // ── Section 2: Progress card ──────────────────
          _ProgressCard(
            activity: activity,
            xpForNextLevel: xpForNextLevel,
            xpProgress: xpProgress,
          ),
          const SizedBox(height: 24),

          // ── Section 3: Daily Challenges ───────────────
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

          // Daily challenge cards — mock data matching Figma
          const ActivityCard(
            title: 'Log all meals',
            subtitle: '2/3 meals logged',
            xpReward: '+50 XP',
            progress: 0.66,
            icon: Icons.restaurant_rounded,
            iconColor: Color(0xFFFFA726),
            iconBgColor: Color(0xFFFFECC6),
          ),
          const ActivityCard(
            title: 'Meditate for 10 mins',
            subtitle: 'Not started yet',
            xpReward: '+100 XP',
            progress: 0.0,
            icon: Icons.self_improvement_rounded,
            iconColor: Color(0xFF7E57C2),
            iconBgColor: Color(0xFFEDDAFF),
          ),
          const ActivityCard(
            title: 'Drink 4 glasses of water',
            subtitle: '2/4 glasses logged',
            xpReward: '+30 XP',
            progress: 0.5,
            icon: Icons.water_drop_rounded,
            iconColor: AppColors.steelColor,
            iconBgColor: Color(0xFFDAEAF9),
          ),
          const SizedBox(height: 8),

          // ── Section 4: Friends Leaderboard ────────────
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
            currentUserXp: activity.totalXp,
            userName: userName,
            avatarUrl: avatarUrl,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final String levelTitle;
  final int totalXp;
  final int currentLevel;

  const _ProfileHeader({
    required this.userName,
    required this.avatarUrl,
    required this.levelTitle,
    required this.totalXp,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with level badge overlay
        Stack(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.steelColor.withOpacity(0.15),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 36,
                      color: AppColors.steelColor,
                    )
                  : null,
            ),
            // Level badge
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.steelColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'LVL $currentLevel',
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

        // Name + XP total
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
              '${_formatNumber(totalXp)} XP Total',
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

  String _formatNumber(int n) =>
      n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

class _ProgressCard extends StatelessWidget {
  final ActivityModel activity;
  final int xpForNextLevel;
  final double xpProgress;

  const _ProgressCard({
    required this.activity,
    required this.xpForNextLevel,
    required this.xpProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.steelColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.steelColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level ${activity.currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              Text(
                '${activity.totalXp} / $xpForNextLevel XP',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // XP progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 10,
              backgroundColor: const Color(0xFFDDE8F5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.steelColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Hint text
          Text(
            'Earn ${activity.xpToNextLevel} more XP to unlock next level',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
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
    // Mock leaderboard entries — replace with real data when available
    final entries = [
      _LeaderEntry(rank: 1, name: 'Basmala Hisham', xp: 3120, isUser: false),
      _LeaderEntry(rank: 2, name: 'Omar Mohamed', xp: 2820, isUser: false),
      _LeaderEntry(rank: 4, name: 'You', xp: currentUserXp, isUser: true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.steelColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.steelColor.withOpacity(0.20),
        ),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          final isLast = index == entries.length - 1;

          return Column(
            children: [
              _LeaderboardRow(
                entry: entry,
                avatarUrl: entry.isUser ? avatarUrl : null,
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
  const _LeaderEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isUser,
  });
}

class _LeaderboardRow extends StatelessWidget {
  final _LeaderEntry entry;
  final String? avatarUrl;

  const _LeaderboardRow({required this.entry, this.avatarUrl});

  String _formatXp(int xp) =>
      xp.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank number
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

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.steelColor.withOpacity(0.15),
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: entry.isUser
                        ? AppColors.steelColor
                        : const Color(0xFF888888),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name
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

          // XP
          Text(
            '${_formatXp(entry.xp)} XP',
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF555555)),
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