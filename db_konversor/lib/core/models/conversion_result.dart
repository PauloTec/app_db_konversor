class ConversionResult {
  final bool isSuccess;
  final double? value;
  final String outputUnitLabel;
  final String formula;
  final String note;
  final String? errorMessage;

  const ConversionResult({
    required this.isSuccess,
    required this.value,
    required this.outputUnitLabel,
    required this.formula,
    required this.note,
    this.errorMessage,
  });

  factory ConversionResult.success({
    required double value,
    required String outputUnitLabel,
    required String formula,
    required String note,
  }) {
    return ConversionResult(
      isSuccess: true,
      value: value,
      outputUnitLabel: outputUnitLabel,
      formula: formula,
      note: note,
    );
  }

  factory ConversionResult.failure({
    required String message,
    String formula = '-',
    String note = '',
  }) {
    return ConversionResult(
      isSuccess: false,
      value: null,
      outputUnitLabel: '',
      formula: formula,
      note: note,
      errorMessage: message,
    );
  }
}