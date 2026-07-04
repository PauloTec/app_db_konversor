import 'package:flutter/material.dart';

class ImpedanceField extends StatelessWidget {
  final TextEditingController controller;
  final bool visible;

  const ImpedanceField({
    super.key,
    required this.controller,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('impedance-field'),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2E4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF0CF61)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Impedância',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB46200),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Este campo só aparece quando a conversão exigir contexto adicional.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: Color(0xFFB46200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        suffixText: 'Ω',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}