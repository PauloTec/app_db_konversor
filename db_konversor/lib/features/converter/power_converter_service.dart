import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/conversion_result.dart';
import '../../core/power_unit.dart';
import '../../utils/math_utils.dart';
import '../../utils/validators.dart';

class PowerConverterService {
  ConversionResult convert({
    required double inputValue,
    required PowerUnit from,
    required PowerUnit to,
    double? impedance,
  }) {
    if (from == to) {
      return ConversionResult.success(
        value: inputValue,
        outputUnitLabel: to.label,
        formula: '${to.label} = ${from.label}',
        note: 'Nenhuma conversão foi necessária.',
      );
    }

    if (from.isRatioUnit || to.isRatioUnit) {
      return ConversionResult.failure(
        message: AppStrings.dbUnsupportedMessage,
        note:
            'dB representa razão logarítmica. Neste MVP ele não é tratado como potência absoluta.',
      );
    }

    if (_requiresImpedance(from: from, to: to)) {
      final impedanceError = Validators.validateImpedance(impedance);
      if (impedanceError != null) {
        return ConversionResult.failure(
          message: impedanceError,
          note: 'A impedância é necessária para relacionar tensão e potência.',
        );
      }
    }

    if (from.isPowerUnit && to.isPowerUnit) {
      return _convertPowerToPower(
        inputValue: inputValue,
        from: from,
        to: to,
      );
    }

    if (from.isVoltageLogUnit && to.isVoltageLogUnit) {
      return _convertVoltageLogToVoltageLog(
        inputValue: inputValue,
        from: from,
        to: to,
      );
    }

    if (from.isVoltageLogUnit && to.isPowerUnit) {
      return _convertVoltageLogToPower(
        inputValue: inputValue,
        from: from,
        to: to,
        impedance: impedance!,
      );
    }

    if (from.isPowerUnit && to.isVoltageLogUnit) {
      return _convertPowerToVoltageLog(
        inputValue: inputValue,
        from: from,
        to: to,
        impedance: impedance!,
      );
    }

    return ConversionResult.failure(
      message: 'Conversão ainda não suportada.',
      note: 'Revê as unidades selecionadas.',
    );
  }

  bool requiresImpedance({
    required PowerUnit from,
    required PowerUnit to,
  }) {
    return _requiresImpedance(from: from, to: to);
  }

  bool _requiresImpedance({
    required PowerUnit from,
    required PowerUnit to,
  }) {
    final involvesVoltage = from.isVoltageLogUnit || to.isVoltageLogUnit;
    final involvesPower = from.isPowerUnit || to.isPowerUnit;
    return involvesVoltage && involvesPower;
  }

  ConversionResult _convertPowerToPower({
    required double inputValue,
    required PowerUnit from,
    required PowerUnit to,
  }) {
    final mwResult = _toMilliwatt(inputValue, from);
    if (!mwResult.isSuccess) return mwResult;

    final milliwatt = mwResult.value!;
    final outputResult = _fromMilliwatt(milliwatt, to);
    if (!outputResult.isSuccess) return outputResult;

    return ConversionResult.success(
      value: outputResult.value!,
      outputUnitLabel: to.label,
      formula: outputResult.formula,
      note: 'Conversão concluída entre unidades absolutas de potência.',
    );
  }

  ConversionResult _convertVoltageLogToVoltageLog({
    required double inputValue,
    required PowerUnit from,
    required PowerUnit to,
  }) {
    final voltsResult = _toVoltage(inputValue, from);
    if (!voltsResult.isSuccess) return voltsResult;

    final volts = voltsResult.value!;
    final outputResult = _fromVoltage(volts, to);
    if (!outputResult.isSuccess) return outputResult;

    return ConversionResult.success(
      value: outputResult.value!,
      outputUnitLabel: to.label,
      formula: outputResult.formula,
      note: 'Conversão concluída entre níveis logarítmicos de tensão.',
    );
  }

  ConversionResult _convertVoltageLogToPower({
    required double inputValue,
    required PowerUnit from,
    required PowerUnit to,
    required double impedance,
  }) {
    final voltsResult = _toVoltage(inputValue, from);
    if (!voltsResult.isSuccess) return voltsResult;

    final volts = voltsResult.value!;
    final watts = (volts * volts) / impedance;
    final milliwatt = watts * 1000.0;

    final outputResult = _fromMilliwatt(milliwatt, to);
    if (!outputResult.isSuccess) return outputResult;

    return ConversionResult.success(
      value: outputResult.value!,
      outputUnitLabel: to.label,
      formula: '${voltsResult.formula}  |  P = V² / R  |  ${outputResult.formula}',
      note:
          'A conversão exigiu impedância para relacionar tensão e potência.',
    );
  }

  ConversionResult _convertPowerToVoltageLog({
    required double inputValue,
    required PowerUnit from,
    required PowerUnit to,
    required double impedance,
  }) {
    final mwResult = _toMilliwatt(inputValue, from);
    if (!mwResult.isSuccess) return mwResult;

    final milliwatt = mwResult.value!;
    final watts = milliwatt / 1000.0;
    final volts = _sqrt(watts * impedance);

    final outputResult = _fromVoltage(volts, to);
    if (!outputResult.isSuccess) return outputResult;

    return ConversionResult.success(
      value: outputResult.value!,
      outputUnitLabel: to.label,
      formula: '${mwResult.formula}  |  V = √(P × R)  |  ${outputResult.formula}',
      note:
          'A conversão exigiu impedância para relacionar potência e tensão.',
    );
  }

  ConversionResult _toMilliwatt(double inputValue, PowerUnit from) {
    switch (from) {
      case PowerUnit.watt:
        if (inputValue < 0) {
          return ConversionResult.failure(
            message: 'O valor em ${from.label} não pode ser negativo.',
          );
        }
        return ConversionResult.success(
          value: inputValue * 1000.0,
          outputUnitLabel: 'mW',
          formula: 'mW = W × 1000',
          note: '',
        );

      case PowerUnit.milliwatt:
        if (inputValue < 0) {
          return ConversionResult.failure(
            message: 'O valor em ${from.label} não pode ser negativo.',
          );
        }
        return ConversionResult.success(
          value: inputValue,
          outputUnitLabel: 'mW',
          formula: 'mW = mW',
          note: '',
        );

      case PowerUnit.dbm:
        return ConversionResult.success(
          value: MathUtils.pow10(inputValue / 10),
          outputUnitLabel: 'mW',
          formula: 'mW = 10^(dBm / 10)',
          note: '',
        );

      default:
        return ConversionResult.failure(
          message:
              'A unidade ${from.label} não é uma unidade de potência neste contexto.',
        );
    }
  }

  ConversionResult _fromMilliwatt(double milliwatt, PowerUnit to) {
    switch (to) {
      case PowerUnit.watt:
        return ConversionResult.success(
          value: milliwatt / 1000.0,
          outputUnitLabel: 'W',
          formula: 'W = mW / 1000',
          note: '',
        );

      case PowerUnit.milliwatt:
        return ConversionResult.success(
          value: milliwatt,
          outputUnitLabel: 'mW',
          formula: 'mW = mW',
          note: '',
        );

      case PowerUnit.dbm:
        final validation =
            Validators.validatePositiveForLogInput(milliwatt, 'mW');
        if (validation != null) {
          return ConversionResult.failure(message: validation);
        }
        return ConversionResult.success(
          value: 10 * MathUtils.log10num(milliwatt),
          outputUnitLabel: 'dBm',
          formula: 'dBm = 10 × log10(mW)',
          note: '',
        );

      default:
        return ConversionResult.failure(
          message:
              'A unidade ${to.label} não é uma unidade de potência neste contexto.',
        );
    }
  }

  ConversionResult _toVoltage(double inputValue, PowerUnit from) {
    switch (from) {
      case PowerUnit.dbv:
        return ConversionResult.success(
          value: MathUtils.pow10(inputValue / 20),
          outputUnitLabel: 'V',
          formula: 'V = 10^(dBV / 20)',
          note: '',
        );

      case PowerUnit.dbu:
        return ConversionResult.success(
          value: 0.775 * MathUtils.pow10(inputValue / 20),
          outputUnitLabel: 'V',
          formula: 'V = 0.775 × 10^(dBu / 20)',
          note: '',
        );

      default:
        return ConversionResult.failure(
          message:
              'A unidade ${from.label} não é uma unidade de tensão neste contexto.',
        );
    }
  }

  ConversionResult _fromVoltage(double voltage, PowerUnit to) {
    switch (to) {
      case PowerUnit.dbv:
        final validation = Validators.validatePositiveForLogInput(voltage, 'V');
        if (validation != null) {
          return ConversionResult.failure(message: validation);
        }
        return ConversionResult.success(
          value: 20 * MathUtils.log10num(voltage),
          outputUnitLabel: 'dBV',
          formula: 'dBV = 20 × log10(V)',
          note: '',
        );

      case PowerUnit.dbu:
        final validation = Validators.validatePositiveForLogInput(voltage, 'V');
        if (validation != null) {
          return ConversionResult.failure(message: validation);
        }
        return ConversionResult.success(
          value: 20 * MathUtils.log10num(voltage / 0.775),
          outputUnitLabel: 'dBu',
          formula: 'dBu = 20 × log10(V / 0.775)',
          note: '',
        );

      default:
        return ConversionResult.failure(
          message:
              'A unidade ${to.label} não é uma unidade de tensão neste contexto.',
        );
    }
  }

  double _sqrt(double value) {
    if (value < 0) return double.nan;
    if (value == 0) return 0;

    double guess = value / 2;
    for (int i = 0; i < 20; i++) {
      guess = 0.5 * (guess + value / guess);
    }
    return guess;
  }
}