import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

/// Widget per mostrare l'avanzamento degli step con palle/cerchi
class ATLStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;

  const ATLStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = ATLColors.darkBlue,
    this.inactiveColor = ATLColors.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: inactiveColor,
                width: 3,
              ),
            ),
          ),
        );
      }),
    );
  }
}
