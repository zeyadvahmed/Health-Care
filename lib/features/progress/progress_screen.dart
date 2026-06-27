import 'package:firebase_auth/firebase_auth.dart';
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
  late Future<ProgressData> _progressFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _progressFuture = _controller.loadProgressData(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<ProgressData>(
          future: _progressFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? ProgressData.empty();

            return RefreshIndicator(
              onRefresh: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                setState(() {
                  _progressFuture = _controller.loadProgressData(uid);
                });
                await _progressFuture;
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
                    _TrendCard(
                      values: data.workoutTrend,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.restaurant,
                      iconColor: const Color(0xFFE89316),
                      iconBg: const Color(0xFFFFE8BB),
                      title: 'Nutrition Progress',
                    ),
                    const SizedBox(height: 12),
                    _NutritionCard(
                      avgCalories: data.avgDailyCalories,
                      adherence: data.nutritionAdherence,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      icon: Icons.local_drink,
                      iconColor: const Color(0xFF2384F5),
                      iconBg: const Color(0xFFDCEBFF),
                      title: 'Hydration Progress',
                    ),
                    const SizedBox(height: 12),
                    _HydrationCard(values: data.hydrationTrend),
                  ],
                ),
              ),
            );
          },
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Activity Trends',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(values),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final int avgCalories;
  final int adherence;

  const _NutritionCard({
    required this.avgCalories,
    required this.adherence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _InlineMetric(
              label: 'Avg Daily Intake',
              value: '${_formatNumber(avgCalories)} kcal',
            ),
          ),
          _InlineMetric(
            label: 'Adherence',
            value: '$adherence%',
            valueColor: AppColors.success,
            alignEnd: true,
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
            height: 120,
            child: _BarChart(values: values),
          ),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  const _InlineMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: _mutedStyle()),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> values;

  const _BarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = _maxInt(1, values.fold<int>(0, _maxInt));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final height = 22 + (values[index] / maxValue) * 70;
        final active = values[index] == maxValue && maxValue > 1;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: height,
                width: 22,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF2384F5)
                      : const Color(0xFFD7E6FF),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 8),
              Text(labels[index], style: _mutedStyle(fontSize: 10)),
            ],
          ),
        );
      }),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<int> values;

  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE7EAF0)
      ..strokeWidth = 1;
    final fillPaint = Paint()
      ..color = const Color(0xFFFFE0CF)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFFFF5B22)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = _maxInt(1, values.fold<int>(0, _maxInt));
    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : size.width * i / (values.length - 1);
      final y = size.height - ((values[i] / maxValue) * (size.height - 18)) - 6;
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];
      final midX = (prev.dx + current.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, current.dy, current.dx, current.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
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

TextStyle _mutedStyle({double fontSize = 12}) {
  return TextStyle(
    color: AppColors.textSecondary,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
  );
}

String _formatNumber(int value) {
  final text = value.toString();
  if (text.length <= 3) return text;
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}

int _maxInt(int a, int b) => a > b ? a : b;
