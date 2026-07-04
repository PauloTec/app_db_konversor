import 'package:flutter/material.dart';

class FormulaCard extends StatelessWidget {
  final String title;
  final String content;
  final bool highlight;

  const FormulaCard({
    super.key,
    required this.title,
    required this.content,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        highlight ? const Color(0xFFE8EEFF) : Colors.white;
    final borderColor =
        highlight ? const Color(0xFFD2DEFF) : const Color(0xFFD8DDE6);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: highlight ? const Color(0xFF294ACF) : const Color(0xFF13203A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              fontFamily: highlight ? null : 'monospace',
              color: highlight ? const Color(0xFF294ACF) : const Color(0xFF13203A),
            ),
          ),
        ],
      ),
    );
  }
}