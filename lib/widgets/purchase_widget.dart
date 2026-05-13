import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/enums/checkout_type.dart';
import '../models/enums/purchase_status.dart';
import '../models/purchase.dart';
import '../utils/atl_colors.dart';

class PurchaseWidget extends StatelessWidget {
  final Purchase purchase;

  const PurchaseWidget({
    super.key,
    required this.purchase,
  });

  bool _isBookingType(CheckoutType type) {
    switch (type) {
      case CheckoutType.lobbyBookingCreate:
      case CheckoutType.lobbyBookingParticipate:
      case CheckoutType.privateBooking:
        return true;
      case CheckoutType.tournamentFee:
      case CheckoutType.shop:
        return false;
    }
  }

  String _formatDescription(
    BuildContext context,
    CheckoutType type,
    String description,
  ) {
    if (description.isEmpty || !_isBookingType(type)) {
      return description;
    }

    final formatted = _formatBookingDescription(context, description);
    return formatted ?? description;
  }

  String? _formatBookingDescription(
    BuildContext context,
    String description,
  ) {
    // allow the start/end parts to contain newlines (some descriptions come with line breaks)
    final match = RegExp(r'^\s*([\s\S]+?)\s*-\s*([\s\S]+?)\s*$', dotAll: false).firstMatch(description);
    if (match == null) return null;

    final start = _parseUtcDate(match.group(1) ?? '');
    final end = _parseUtcDate(match.group(2) ?? '');
    if (start == null || end == null) return null;

    final startLocal = start.toLocal();
    final endLocal = end.toLocal();
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('dd MMMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm', locale);
    final sameDay = startLocal.year == endLocal.year &&
        startLocal.month == endLocal.month &&
        startLocal.day == endLocal.day;

    if (sameDay) {
      return '(${dateFormat.format(startLocal)}) ${timeFormat.format(startLocal)} - ${timeFormat.format(endLocal)}';
    }

    return '(${dateFormat.format(startLocal)}) ${timeFormat.format(startLocal)} - (${dateFormat.format(endLocal)}) ${timeFormat.format(endLocal)}';
  }

  DateTime? _parseUtcDate(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final parsed = DateTime.parse(trimmed);
      if (_hasTimezone(trimmed)) {
        return parsed.toUtc();
      }
      return DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    } catch (_) {
      return null;
    }
  }

  bool _hasTimezone(String raw) {
    return RegExp(r'(Z|z|[+-]\d{2}:?\d{2})$').hasMatch(raw.trim());
  }

  bool _isRefundStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.refunded:
      case PurchaseStatus.partialRefund:
      case PurchaseStatus.canceled:
        return true;
      case PurchaseStatus.confirmed:
      case PurchaseStatus.redeemed:
        return false;
    }
  }

  Color _statusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.confirmed:
        return Colors.green;
      case PurchaseStatus.redeemed:
        return Colors.green.shade700;
      case PurchaseStatus.partialRefund:
        return Colors.orange;
      case PurchaseStatus.refunded:
        return Colors.red;
      case PurchaseStatus.canceled:
        return Colors.red.shade400;
    }
  }

  IconData _typeIcon(CheckoutType type) {
    switch (type) {
      case CheckoutType.tournamentFee:
        return Icons.emoji_events_outlined;
      case CheckoutType.lobbyBookingCreate:
        return Icons.group_add_outlined;
      case CheckoutType.lobbyBookingParticipate:
        return Icons.groups_outlined;
      case CheckoutType.shop:
        return Icons.shopping_bag_outlined;
      case CheckoutType.privateBooking:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = purchase.type.displayName(context);
    final statusLabel = purchase.status.displayName(context);
    final statusColor = _statusColor(purchase.status);
    final createdDate = DateFormat('dd MMM yyyy').format(purchase.createdAt);
    final createdTime = DateFormat('HH:mm').format(purchase.createdAt);
    final isRefund = _isRefundStatus(purchase.status);
    final amountLabel =
        '${isRefund ? '-' : ''}\u20AC${purchase.amount.abs().toStringAsFixed(2)}';
    final description = _formatDescription(
      context,
      purchase.type,
      purchase.detail.description.trim(),
    );
    final title = purchase.detail.title.trim().isEmpty
        ? typeLabel
        : purchase.detail.title.trim();

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.12),
              child: Icon(
                _typeIcon(purchase.type),
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: ATLColors.darkBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: ATLColors.subtext,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '$typeLabel - $createdDate $createdTime',
                    style: const TextStyle(
                      color: ATLColors.subtext,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountLabel,
                  style: TextStyle(
                    color: isRefund ? Colors.red : ATLColors.darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
