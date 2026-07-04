import 'package:flutter/material.dart';

import '../../utils/math_utils.dart';

class ResultCard extends StatelessWidget {
  final bool isSuccess;
  final double? value;
  final String unitLabel;
  final String message;

  const ResultCard({
    super.key,
    required this.isSuccess,
    required this.value,
    required this.unitLabel,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue =
        value == null ? '--' : MathUtils.formatResult(value!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFF09153D) : const Color(0xFF5B1220),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESULTADO',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2.4,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isSuccess && unitLabel.isNotEmpty) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unitLabel,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}