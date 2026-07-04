import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'progress_controller.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressController _controller = ProgressController();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                  icon: Icons.fitness_center,
                  iconColor: const Color(0xFFFF5B22),
                  iconBg: const Color(0xFFFFE3D7),
                  title: 'Workout Progress',
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<int>>(
                  stream: _controller.workoutTrendStream(_uid),
                  initialData: const [0, 0, 0, 0, 0, 0, 0],
                  builder: (context, snapshot) {
                    final values = snapshot.data ?? const [0, 0, 0, 0, 0, 0, 0];
                    return _TrendCard(values: values);
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.restaurant,
                  iconColor: const Color(0xFFE89316),
                  iconBg: const Color(0xFFFFE8BB),
                  title: 'Nutrition Progress',
                ),
                const SizedBox(height: 12),
                StreamBuilder<int>(
                  stream: _controller.avgDailyCaloriesStream(_uid),
                  initialData: 0,
                  builder: (context, avgSnapshot) {
                    final avgCalories = avgSnapshot.data ?? 0;
                    return _NutritionCard(avgCalories: avgCalories);
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.local_drink,
                  iconColor: const Color(0xFF2384F5),
                  iconBg: const Color(0xFFDCEBFF),
                  title: 'Hydration Progress',
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<int>>(
                  stream: _controller.hydrationTrendStream(_uid),
                  initialData: const [0, 0, 0, 0, 0, 0, 0],
                  builder: (context, snapshot) {
                    final values = snapshot.data ?? const [0, 0, 0, 0, 0, 0, 0];
                    return _HydrationCard(values: values);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<int> values;

  const _TrendCard({
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1 : values.reduce(max);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Trends',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            width: double.infinity,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: max(maxValue.toDouble(), 5) * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: max(1, maxValue ~/ 4).toDouble(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE7EAF0),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE7EAF0)),
                    left: BorderSide(color: Color(0xFFE7EAF0)),
                    right: BorderSide(color: Colors.transparent),
                    top: BorderSide(color: Colors.transparent),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      values.length,
                      (index) => FlSpot(index.toDouble(), values[index].toDouble()),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFFFF5B22),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFFE0CF).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final int avgCalories;

  const _NutritionCard({required this.avgCalories});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Daily Intake',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${avgCalories} kcal',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final List<int> values;

  const _HydrationCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Performance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: max(values.reduce(max).toDouble(), 1) * 1.2,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            labels[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                ),
                barGroups: List.generate(values.length, (index) {
                  final value = values[index].toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 18,
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF2384F5),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

