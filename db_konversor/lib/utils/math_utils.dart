import 'dart:math';

class MathUtils {
  static double log10num(double value) {
    return log(value) / ln10;
  }

  static double pow10(double exponent) {
    return pow(10, exponent).toDouble();
  }

  static String formatResult(double value) {
    if (value == 0) return '0';

    final abs = value.abs();

    if (abs >= 1000 || abs < 0.001) {
      return value.toStringAsExponential(4);
    }

    if (abs >= 100) return value.toStringAsFixed(2);
    if (abs >= 10) return value.toStringAsFixed(3);
    if (abs >= 1) return value.toStringAsFixed(4);

    return value.toStringAsFixed(6);
  }
}