import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';

class TransactionCard extends StatelessWidget {
  final String description;
  final DateTime date;
  final double amount;
  final bool isExpense;

  const TransactionCard({
    super.key,
    required this.description,
    required this.date,
    required this.amount,
    required this.isExpense,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense
              ? Colors.red.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          child: Icon(
            isExpense ? Icons.arrow_downward : Icons.arrow_upward,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          description,
          style: const TextStyle(
            color: ATLColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _formatDate(date),
          style: const TextStyle(color: ATLColors.subtext, fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}€${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
