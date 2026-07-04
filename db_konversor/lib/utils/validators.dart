class Validators {
  static String? validateNumericInput(String text) {
    final sanitized = text.trim().replaceAll(',', '.');

    if (sanitized.isEmpty) {
      return 'Informe um valor de entrada.';
    }

    final value = double.tryParse(sanitized);
    if (value == null) {
      return 'Informe um número válido.';
    }

    return null;
  }

  static String? validatePositiveForLogInput(double value, String unitLabel) {
    if (value <= 0) {
      return 'O valor em $unitLabel deve ser maior que zero para esta conversão.';
    }
    return null;
  }

  static String? validateImpedance(double? impedance) {
    if (impedance == null) {
      return 'Informe a impedância para esta conversão.';
    }
    if (impedance <= 0) {
      return 'A impedância deve ser maior que zero.';
    }
    return null;
  }
}