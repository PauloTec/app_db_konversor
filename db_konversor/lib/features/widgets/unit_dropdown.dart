import 'package:flutter/material.dart';
import '../../core/power_unit.dart';

class UnitDropdown extends StatelessWidget {
  final String label;
  final PowerUnit value;
  final List<PowerUnit> items;
  final ValueChanged<PowerUnit?> onChanged;

  const UnitDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PowerUnit>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            items: items
                .map(
                  (unit) => DropdownMenuItem<PowerUnit>(
                    value: unit,
                    child: Text(unit.label),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}