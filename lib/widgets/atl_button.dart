import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

enum ATLButtonSize {
  small,
  medium,
  large,
}

class ATLButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final Color color;
  final Color? textColor;
  final ATLButtonSize size;

  const ATLButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
    this.color = ATLColors.darkBlue,
    this.textColor,
    this.size = ATLButtonSize.large,
  });

  double get _buttonWidth {
    switch (size) {
      case ATLButtonSize.small:
        return 180;
      case ATLButtonSize.medium:
        return 220;
      case ATLButtonSize.large:
        return 260;
    }
  }

  double get _buttonHeight {
    switch (size) {
      case ATLButtonSize.small:
        return 48;
      case ATLButtonSize.medium:
        return 52;
      case ATLButtonSize.large:
        return 56;
    }
  }

  double get _fontSize {
    switch (size) {
      case ATLButtonSize.small:
        return 14;
      case ATLButtonSize.medium:
        return 16;
      case ATLButtonSize.large:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determina il colore del testo
    final Color effectiveTextColor = textColor ?? 
        (isFilled ? Colors.white : color);
    
    return SizedBox(
      width: _buttonWidth,
      height: _buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? color : Colors.transparent,
          foregroundColor: effectiveTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isFilled
                ? BorderSide.none
                : BorderSide(color: color, width: 2),
          ),
          elevation: 0,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: effectiveTextColor,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
