import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/models/conversion_result.dart';
import '../../core/power_unit.dart';
import '../../utils/validators.dart';
import 'power_converter_service.dart';

class ConverterController extends ChangeNotifier {
  ConverterController();

  final PowerConverterService _service = PowerConverterService();

  final TextEditingController valueController =
      TextEditingController(text: '10.0');

  final TextEditingController impedanceController =
      TextEditingController(text: '50');

  PowerUnit fromUnit = PowerUnit.dbm;
  PowerUnit toUnit = PowerUnit.watt;

  ConversionResult? result;
  String? inputError;

  List<PowerUnit> get availableUnits => PowerUnit.values;

  bool get shouldShowImpedance {
    return _service.requiresImpedance(from: fromUnit, to: toUnit);
  }

  String get inputUnitLabel => fromUnit.label;
  String get outputUnitLabel => toUnit.label;

  void setFromUnit(PowerUnit value) {
    fromUnit = value;
    _clearTransientError();
    convert();
  }

  void setToUnit(PowerUnit value) {
    toUnit = value;
    _clearTransientError();
    convert();
  }

  void invertUnits() {
    final oldFrom = fromUnit;
    fromUnit = toUnit;
    toUnit = oldFrom;
    _clearTransientError();
    convert();
  }

  void convert() {
    inputError = Validators.validateNumericInput(valueController.text);

    if (inputError != null) {
      result = ConversionResult.failure(
        message: inputError!,
        note: 'Revê o valor de entrada e tenta novamente.',
      );
      notifyListeners();
      return;
    }

    final inputValue =
        double.parse(valueController.text.trim().replaceAll(',', '.'));

    double? impedance;
    if (shouldShowImpedance) {
      final impedanceText = impedanceController.text.trim().replaceAll(',', '.');
      impedance = double.tryParse(impedanceText);
    }

    result = _service.convert(
      inputValue: inputValue,
      from: fromUnit,
      to: toUnit,
      impedance: impedance,
    );

    notifyListeners();
  }

  String buildConversionTypeLabel() {
    if (fromUnit.isPowerUnit && toUnit.isPowerUnit) {
      return 'Relação de potência';
    }

    if (fromUnit.isVoltageLogUnit && toUnit.isVoltageLogUnit) {
      return 'Nível logarítmico de tensão';
    }

    if ((fromUnit.isVoltageLogUnit && toUnit.isPowerUnit) ||
        (fromUnit.isPowerUnit && toUnit.isVoltageLogUnit)) {
      return 'Potência e tensão com impedância';
    }

    if (fromUnit.isRatioUnit || toUnit.isRatioUnit) {
      return 'Razão logarítmica';
    }

    return 'Conversão técnica';
  }

  String buildTechnicalDescription() {
    if (fromUnit.isRatioUnit || toUnit.isRatioUnit) {
      return AppStrings.dbUnsupportedMessage;
    }

    if (shouldShowImpedance) {
      return 'Esta conversão relaciona tensão e potência. Informe a impedância correta do sistema para obter um resultado válido.';
    }

    return toUnit.description;
  }

  void _clearTransientError() {
    inputError = null;
  }

  @override
  void dispose() {
    valueController.dispose();
    impedanceController.dispose();
    super.dispose();
  }
}