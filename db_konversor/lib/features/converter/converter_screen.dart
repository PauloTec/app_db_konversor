import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/models/conversion_result.dart';
import '../../core/power_unit.dart';
import 'converter_controller.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with TickerProviderStateMixin {
  late final ConverterController controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final AnimationController _swapGlowController;
  late final AnimationController _resultPulseController;
  late final AnimationController _unitsSwitchController;

  PowerUnit? _previousFromUnit;
  PowerUnit? _previousToUnit;
  String _lastOutputText = '';

  @override
  void initState() {
    super.initState();

    controller = ConverterController()..convert();

    _previousFromUnit = controller.fromUnit;
    _previousToUnit = controller.toUnit;

    _swapGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _resultPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _unitsSwitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _swapGlowController.dispose();
    _resultPulseController.dispose();
    _unitsSwitchController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final ConversionResult currentResult =
            controller.result ??
            ConversionResult.failure(
              message: 'Informe os dados para calcular.',
              note: 'Aguardando conversão.',
            );

        final String outputText =
            currentResult.isSuccess && currentResult.value != null
            ? _formatValue(currentResult.value!)
            : '';

        _handleAnimatedState(outputText);

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFF020817),
          drawer: _UnitsDrawer(
            units: controller.availableUnits,
            fromUnit: controller.fromUnit,
            toUnit: controller.toUnit,
            onSelectFrom: (unit) {
              controller.setFromUnit(unit);
              controller.convert();
              Navigator.of(context).pop();
            },
            onSelectTo: (unit) {
              controller.setToUnit(unit);
              controller.convert();
              Navigator.of(context).pop();
            },
          ),
          floatingActionButton: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF081C3F),
            foregroundColor: const Color(0xFF22C7FF),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF123E83)),
            ),
            onPressed: () {
              _showHistorySheet(context, currentResult);
            },
            child: const Icon(Icons.history_rounded),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(
                        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                        onHelpTap: () {
                          _showHelpDialog(context);
                        },
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF04142D),
                              Color(0xFF071C3C),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: const Color(0xFF123E83)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x220B58F4),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionTitle(
                              icon: Icons.arrow_circle_up_outlined,
                              text: 'VALOR DE ENTRADA',
                            ),
                            const SizedBox(height: 10),
                            _InputBox(
                              child: TextField(
                                controller: controller.valueController,
                                onChanged: (_) => controller.convert(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Digite o valor',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6F86B5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            FadeTransition(
                              opacity: Tween<double>(
                                begin: 0.88,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: _unitsSwitchController,
                                  curve: Curves.easeOut,
                                ),
                              ),
                              child: SlideTransition(
                                position:
                                    Tween<Offset>(
                                      begin: const Offset(0.02, 0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: _unitsSwitchController,
                                        curve: Curves.easeOutCubic,
                                      ),
                                    ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: _UnitSelectionCard(
                                        title: 'UNIDADE DE ENTRADA',
                                        value: controller.fromUnit,
                                        items: controller.availableUnits,
                                        onChanged: (unit) {
                                          if (unit != null) {
                                            controller.setFromUnit(unit);
                                            controller.convert();
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _SwapButton(
                                      controller: _swapGlowController,
                                      onTap: () {
                                        controller.invertUnits();
                                        controller.convert();
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _UnitSelectionCard(
                                        title: 'UNIDADE DE SAÍDA',
                                        value: controller.toUnit,
                                        items: controller.availableUnits,
                                        onChanged: (unit) {
                                          if (unit != null) {
                                            controller.setToUnit(unit);
                                            controller.convert();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.shouldShowImpedance) ...[
                              const SizedBox(height: 18),
                              const _SectionTitle(
                                icon: Icons.tune_rounded,
                                text: 'IMPEDÂNCIA',
                              ),
                              const SizedBox(height: 10),
                              _InputBox(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controller.impedanceController,
                                        onChanged: (_) => controller.convert(),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: false,
                                            ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: 'Ex.: 50',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF6F86B5),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ω',
                                      style: TextStyle(
                                        color: Color(0xFF22C7FF),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            const _SectionTitle(
                              icon: Icons.arrow_circle_down_outlined,
                              text: 'VALOR DE SAÍDA',
                            ),
                            const SizedBox(height: 10),
                            _InputBox(
                              child: AnimatedBuilder(
                                animation: _resultPulseController,
                                builder: (context, child) {
                                  final t = Curves.easeOut.transform(
                                    _resultPulseController.value,
                                  );
                                  final scale = 1 + (0.045 * (1 - t));
                                  final glow = 14 * (1 - t);

                                  return Transform.scale(
                                    scale: scale,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: outputText.isEmpty
                                            ? const []
                                            : [
                                                BoxShadow(
                                                  color: const Color(
                                                    0x3322C7FF,
                                                  ).withValues(alpha: 0.20),
                                                  blurRadius: glow,
                                                  spreadRadius: 0.5,
                                                ),
                                              ],
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 260,
                                        ),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.10),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          outputText.isEmpty ? '--' : outputText,
                                          key: ValueKey(outputText),
                                          style: TextStyle(
                                            color: outputText.isEmpty
                                                ? const Color(0xFF6F86B5)
                                                : const Color(0xFF22C7FF),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!currentResult.isSuccess &&
                                (currentResult.errorMessage?.isNotEmpty ?? false))
                              Padding(
                                padding: const EdgeInsets.only(left: 2, top: 4),
                                child: Text(
                                  currentResult.errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B7A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 150,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _showFormulaDialog(
                                      context,
                                      title: 'Fórmula',
                                      content: currentResult.formula.isNotEmpty
                                          ? currentResult.formula
                                          : 'A fórmula aparecerá aqui após a conversão.',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: const Color(0xFF020B1D),
                                    foregroundColor: const Color(0xFF22C7FF),
                                    side: const BorderSide(
                                      color: Color(0xFF123E83),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'FÓRMULA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleAnimatedState(String outputText) {
    final bool unitsChanged =
        _previousFromUnit != controller.fromUnit ||
        _previousToUnit != controller.toUnit;

    if (unitsChanged) {
      _previousFromUnit = controller.fromUnit;
      _previousToUnit = controller.toUnit;
      _unitsSwitchController.forward(from: 0);
    }

    if (outputText != _lastOutputText && outputText.isNotEmpty) {
      _lastOutputText = outputText;
      _resultPulseController.forward(from: 0);
    } else if (outputText.isEmpty && _lastOutputText.isNotEmpty) {
      _lastOutputText = '';
    }
  }

  void _showFormulaDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF071326),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF123E83)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020B1D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF173A74)),
                  ),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Color(0xFFB6C6E3),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(
                        color: Color(0xFF22C7FF),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: const Color(0xFF071326),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF123E83)),
        ),
        title: const Text(
          'Ajuda',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Informe o valor de entrada, escolha a unidade de entrada e a unidade de saída. '
          'Se necessário, informe também a impedância. Depois veja o resultado no campo de saída.\n\n'
          'Feito pela: KUNDIAMA\n'
          'Contacto: 945560400 / 952142799\n'
          'Email: diassilua.simao@gmail.com',
          style: TextStyle(
            color: Color(0xFFB6C6E3),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendi',
              style: TextStyle(
                color: Color(0xFF22C7FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  void _showHistorySheet(
    BuildContext context,
    ConversionResult currentResult,
  ) {
    final List<_HistoryItemData> items = [
      _HistoryItemData(
        text:
            '${controller.valueController.text.isEmpty ? "--" : controller.valueController.text} ${controller.fromUnit.label} → '
            '${currentResult.isSuccess && currentResult.value != null ? _formatValue(currentResult.value!) : "--"} ${controller.toUnit.label}',
        time: 'Agora',
      ),
      const _HistoryItemData(
        text: '20.0 dBm → 100.00 mW',
        time: '21/04/2026 • 15:48',
      ),
      const _HistoryItemData(
        text: '0.775 dBu → 0.614 dBV',
        time: '21/04/2026 • 15:30',
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF071326),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: Color(0x330B58F4),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF173A74),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: Color(0xFF22C7FF),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Histórico recente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...items.map(
                (item) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF020B1D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF173A74)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: Color(0xFFB6C6E3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(double value) {
    final absValue = value.abs();

    if (absValue == 0) return '0';

    String formatted;

    if (absValue >= 1000) {
      formatted = value.toStringAsFixed(2);
    } else if (absValue >= 1) {
      formatted = value.toStringAsFixed(3);
    } else if (absValue >= 0.001) {
      formatted = value.toStringAsFixed(4);
    } else {
      formatted = value.toStringAsExponential(4);
    }

    // Remove zeros desnecessários
    formatted = formatted.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');

    return formatted;
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onHelpTap;

  const _TopBar({
    required this.onMenuTap,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF04142D),
            Color(0xFF071C3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF123E83)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B58F4),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(
              Icons.menu_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'dB ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: 'Konversor',
                      style: TextStyle(
                        color: Color(0xFF22C7FF),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onHelpTap,
            icon: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionTitle({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF0B58F4),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF22C7FF),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InputBox extends StatelessWidget {
  final Widget child;

  const _InputBox({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF020B1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF173A74)),
      ),
      child: child,
    );
  }
}

class _UnitSelectionCard extends StatelessWidget {
  final String title;
  final PowerUnit value;
  final List<PowerUnit> items;
  final ValueChanged<PowerUnit?> onChanged;

  const _UnitSelectionCard({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF020B1D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF173A74)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120B58F4),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF22C7FF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<PowerUnit>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              dropdownColor: const Color(0xFF071326),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onTap;

  const _SwapButton({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final glowValue = 0.5 + (0.5 * math.sin(controller.value * 2 * math.pi));
        final blur = 10 + (18 * glowValue);
        final spread = 0.5 + (1.2 * glowValue);

        return InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF081C3F),
              border: Border.all(color: const Color(0xFF0B58F4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x330B58F4).withValues(alpha: 0.18 + (0.20 * glowValue)),
                  blurRadius: blur,
                  spreadRadius: spread,
                ),
                BoxShadow(
                  color: const Color(0x2222C7FF).withValues(alpha: 0.10 + (0.12 * glowValue)),
                  blurRadius: blur * 0.7,
                  spreadRadius: spread * 0.4,
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Color(0xFF22C7FF),
              size: 30,
            ),
          ),
        );
      },
    );
  }
}

class _HistoryItemData {
  final String text;
  final String time;

  const _HistoryItemData({
    required this.text,
    required this.time,
  });
}

class _UnitsDrawer extends StatelessWidget {
  final List<PowerUnit> units;
  final PowerUnit fromUnit;
  final PowerUnit toUnit;
  final ValueChanged<PowerUnit> onSelectFrom;
  final ValueChanged<PowerUnit> onSelectTo;

  const _UnitsDrawer({
    required this.units,
    required this.fromUnit,
    required this.toUnit,
    required this.onSelectFrom,
    required this.onSelectTo,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF06142A),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UNIDADES DISPONÍVEIS',
                style: TextStyle(
                  color: Color(0xFF22C7FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: units.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF081C3F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF123E83)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0B58F4),
                          child: Text(
                            unit.label.length <= 2
                                ? unit.label
                                : unit.label.substring(0, 2),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          unit.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          unit.description,
                          style: const TextStyle(
                            color: Color(0xFFB6C6E3),
                            fontSize: 12,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          color: const Color(0xFF071326),
                          iconColor: const Color(0xFF22C7FF),
                          onSelected: (value) {
                            if (value == 'from') {
                              onSelectFrom(unit);
                            } else {
                              onSelectTo(unit);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'from',
                              child: Text('Usar como entrada'),
                            ),
                            PopupMenuItem(
                              value: 'to',
                              child: Text('Usar como saída'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: Color(0xFF173A74)),
              const SizedBox(height: 8),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  'Sobre o dB Konversor',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Conversões de potência e níveis logarítmicos usados em telecomunicações.',
                  style: TextStyle(color: Color(0xFFB6C6E3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}