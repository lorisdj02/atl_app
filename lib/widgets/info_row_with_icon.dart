import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

class InfoRowWithIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Map<String, String>? multipleValues;
  final Color color;

  const InfoRowWithIcon({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.multipleValues,
    required this.color,
  }) : assert(value != null || multipleValues != null,
            'Either value or multipleValues must be provided');

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                )
              else if (multipleValues != null)
                ...multipleValues!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.value, // Role
                            style: const TextStyle(
                              fontSize: 14,
                              color: ATLColors.darkBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key, // Name + Surname
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ATLColors.darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
