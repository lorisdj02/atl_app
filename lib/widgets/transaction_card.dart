import 'package:atl_app/models/enums/transaction_type.dart';
import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  String _formatEnumLabel(String raw) {
    if (raw.isEmpty) return raw;

    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i > 0 && isUpper) {
        buffer.write(' ');
      }
      buffer.write(char);
    }
    final formatted = buffer.toString().replaceAll('_', ' ').toLowerCase();
    return formatted.isEmpty
        ? formatted
        : formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _formatCurrency(String currency) {
    if (currency.toUpperCase() == 'EUR') return '€';
    if (currency.toUpperCase() == 'USD') return '\$';
    if (currency.toUpperCase() == 'GBP') return '£';
    return currency;
  }

  bool _isExpense(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.payment:
      case TransactionType.withdraw:
        return true;
      case TransactionType.deposit:
      case TransactionType.prize:
      case TransactionType.refund:
      case TransactionType.fee:
      case TransactionType.invite:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _isExpense(transaction);
    final typeLabel = _formatEnumLabel(transaction.type.toString().split('.').last);
    final statusLabel = transaction.status.displayName(context);
    final sourceLabel = _formatEnumLabel(transaction.source.toString().split('.').last);
    final currency = _formatCurrency(transaction.currency);

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
          typeLabel,
          style: const TextStyle(
            color: ATLColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$statusLabel • $sourceLabel',
          style: const TextStyle(color: ATLColors.subtext, fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}$currency${transaction.amount.abs().toStringAsFixed(2)}',
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
