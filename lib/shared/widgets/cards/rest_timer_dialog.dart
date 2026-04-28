// ============================================================
// rest_timer_dialog.dart
// lib/shared/widgets/misc/rest_timer_dialog.dart
//
// PURPOSE:
//   Countdown dialog shown after the user completes a set.
//   Counts down from restSeconds to 0 then auto-dismisses.
//
// WHY STATEFULWIDGET:
//   Timer.periodic fires every second and updates _remaining.
//   This triggers setState which rebuilds the countdown display.
//   Without StatefulWidget, the number would never update.
//
// CRITICAL MEMORY LEAK WARNING:
//   Timer.periodic creates a background timer that keeps firing
//   even after the widget is gone. ALWAYS cancel it in dispose().
//   If you forget: the timer fires after the dialog is closed,
//   tries to call setState on a dead widget, and crashes.
//
// USAGE:
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) => RestTimerDialog(
//       seconds: 60,
//       onSkip: () => Navigator.pop(context),
//       onReset: () {}, // handled inside dialog
//     ),
//   );
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sparksteel/core/constants/app_colors.dart';


class RestTimerDialog extends StatefulWidget {
  // Starting countdown value (from WorkoutExerciseModel.restSeconds)
  final int seconds;

  // Called when Skip is tapped OR when countdown reaches 0
  final VoidCallback onSkip;

  // Called when Reset is tapped — restarts the countdown
  final VoidCallback onReset;

  const RestTimerDialog({
    super.key,
    required this.seconds,
    required this.onSkip,
    required this.onReset,
  });

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  // Current remaining seconds — starts at widget.seconds
  late int _remaining;

  // The periodic timer — MUST be cancelled in dispose()
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTimer();
  }

  @override
  void dispose() {
    // CRITICAL: cancel timer when dialog is closed
    // Without this, timer fires after dialog is gone → crash
    _timer?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // _startTimer()
  // Creates a Timer.periodic that fires every 1 second.
  // Decrements _remaining each tick.
  // When _remaining reaches 0: auto-dismisses the dialog.
  // ----------------------------------------------------------
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return; // guard: don't setState if widget gone

      if (_remaining <= 1) {
        // Time is up — cancel timer and dismiss dialog
        _timer?.cancel();
        Navigator.of(context).pop(); // close dialog
        widget.onSkip(); // notify parent that rest is over
      } else {
        // Decrement and rebuild the countdown display
        setState(() => _remaining--);
      }
    });
  }

  // ----------------------------------------------------------
  // _resetTimer()
  // Cancels current timer and restarts from original seconds.
  // Called when user taps the Reset button.
  // ----------------------------------------------------------
  void _resetTimer() {
    _timer?.cancel();
    setState(() => _remaining = widget.seconds);
    _startTimer();
    widget.onReset();
  }

  // Progress for the circular ring: 0.0 (full) to 1.0 (empty)
  // As time passes, value increases toward 1.0
  double get _progress =>
      1 - (_remaining / widget.seconds);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog title
            Text(
              'Rest Time',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // ── Circular countdown ring ─────────────────────
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background track ring (grey)
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    color: AppColors.cardBackground,
                    backgroundColor: Colors.white12,
                  ),
                  // Foreground depleting ring (blue)
                  CircularProgressIndicator(
                    value: 1 - _progress, // depletes as time passes
                    strokeWidth: 8,
                    color: AppColors.steelColor,
                    backgroundColor: Colors.transparent,
                  ),
                  // Countdown number in center
                  Center(
                    child: Text(
                      '$_remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'seconds remaining',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 28),

            // ── Action buttons ──────────────────────────────
            Row(
              children: [
                // Reset button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetTimer,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.steelColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: AppColors.steelColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Skip button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                      widget.onSkip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.steelColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}