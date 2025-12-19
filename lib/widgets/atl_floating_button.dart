import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

class ATLFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final String label;

  const ATLFloatingButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
  }
}
