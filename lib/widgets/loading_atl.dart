import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

/// Widget di caricamento con spinner blu ATL
class LoadingATL extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const LoadingATL({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: ATLColors.darkBlue,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
