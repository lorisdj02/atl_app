import 'package:flutter/material.dart';

enum ATLButtonSize { small, medium, large }

class ATLButton extends StatelessWidget {
  final String text;
  final ATLButtonSize size;
  final bool isFilled;
  final Color color;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final bool fullWidth;
  final Color? outlineColor;

  const ATLButton({
    super.key,
    required this.text,
    required this.size,
    required this.isFilled,
    required this.color,
    this.backgroundColor,
    this.textColor,
    required this.onPressed,
    this.fullWidth = false,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isFilled
        ? (backgroundColor ?? color)
        : (backgroundColor ?? Colors.transparent);

    final fgColor = textColor ?? (isFilled ? Colors.white : color);

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        side: outlineColor != null
            ? BorderSide(color: outlineColor!, width: 2)
            : (isFilled ? null : BorderSide(color: color, width: 2)),
        padding: EdgeInsets.symmetric(
          vertical: _getVerticalPadding,
          horizontal: _getHorizontalPadding,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: isFilled ? 2 : 0,
        minimumSize: Size(
          _getMinWidth,
          0,
        ), // Larghezza minima in base alla size
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _getFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );

    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : Align(alignment: Alignment.center, child: button);
  }

  double get _getVerticalPadding {
    switch (size) {
      case ATLButtonSize.small:
        return 10;
      case ATLButtonSize.medium:
        return 14;
      case ATLButtonSize.large:
        return 18;
    }
  }

  double get _getHorizontalPadding {
    switch (size) {
      case ATLButtonSize.small:
        return 24;
      case ATLButtonSize.medium:
        return 32;
      case ATLButtonSize.large:
        return 40;
    }
  }

  double get _getFontSize {
    switch (size) {
      case ATLButtonSize.small:
        return 12;
      case ATLButtonSize.medium:
        return 14;
      case ATLButtonSize.large:
        return 16;
    }
  }

  /// Larghezza minima del bottone in base alla size
  double get _getMinWidth {
    if (fullWidth) return double.infinity;

    switch (size) {
      case ATLButtonSize.small:
        return 120; // Bottone piccolo
      case ATLButtonSize.medium:
        return 160; // Bottone medio
      case ATLButtonSize.large:
        return 200; // Bottone grande
    }
  }
}
