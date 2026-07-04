enum UnitCategory {
  powerLinear,
  powerLogAbsolute,
  voltageLog,
  ratioLog,
}

enum PowerUnit {
  watt,
  milliwatt,
  db,
  dbm,
  dbu,
  dbv,
}

extension PowerUnitX on PowerUnit {
  String get label {
    switch (this) {
      case PowerUnit.watt:
        return 'W';
      case PowerUnit.milliwatt:
        return 'mW';
      case PowerUnit.db:
        return 'dB';
      case PowerUnit.dbm:
        return 'dBm';
      case PowerUnit.dbu:
        return 'dBu';
      case PowerUnit.dbv:
        return 'dBV';
    }
  }

  String get description {
    switch (this) {
      case PowerUnit.watt:
        return 'Potência linear em watts.';
      case PowerUnit.milliwatt:
        return 'Potência linear em miliwatts.';
      case PowerUnit.db:
        return 'Relação logarítmica. Não representa potência absoluta neste MVP.';
      case PowerUnit.dbm:
        return 'Potência absoluta referenciada a 1 mW.';
      case PowerUnit.dbu:
        return 'Nível de tensão referenciado a 0.775 V.';
      case PowerUnit.dbv:
        return 'Nível de tensão referenciado a 1 V.';
    }
  }

  UnitCategory get category {
    switch (this) {
      case PowerUnit.watt:
      case PowerUnit.milliwatt:
        return UnitCategory.powerLinear;
      case PowerUnit.dbm:
        return UnitCategory.powerLogAbsolute;
      case PowerUnit.dbu:
      case PowerUnit.dbv:
        return UnitCategory.voltageLog;
      case PowerUnit.db:
        return UnitCategory.ratioLog;
    }
  }

  bool get isPowerUnit =>
      this == PowerUnit.watt ||
      this == PowerUnit.milliwatt ||
      this == PowerUnit.dbm;

  bool get isVoltageLogUnit =>
      this == PowerUnit.dbu || this == PowerUnit.dbv;

  bool get isRatioUnit => this == PowerUnit.db;
}