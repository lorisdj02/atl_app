import 'package:atl_app/database/db_write.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/shop/checkout_screen.dart';
import '../models/tournament.dart';
import '../models/tournament_participation.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';

class ParticipationCard extends StatefulWidget {
  final TournamentParticipation participation;
  final Tournament? tournament;
  final int playerId;
  final SportCategory sportCategory;
  final VoidCallback onPaymentCompleted;
  final bool isCalledUp;

  const ParticipationCard({
    super.key,
    required this.participation,
    required this.tournament,
    required this.playerId,
    required this.sportCategory,
    required this.onPaymentCompleted,
    required this.isCalledUp,
  });

  @override
  State<ParticipationCard> createState() => _ParticipationCardState();
}

class _ParticipationCardState extends State<ParticipationCard> {
  bool _isCheckingCallup = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double toPay = widget.participation.toPay ?? 0;
    final double totalCost = widget.tournament?.fee ?? toPay;
    final double paid = totalCost - toPay;
    final double progress = totalCost > 0 ? paid / totalCost : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.tournament?.name ??
                        'Tournament #${widget.participation.tournamentId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ATLColors.darkBlue,
                    ),
                  ),
                ),
                if (_isCheckingCallup)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (widget.isCalledUp == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Called up',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (widget.isCalledUp == false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Not called up',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '€${paid.toStringAsFixed(0)} out of €${totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ATLColors.darkBlue,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.subtext,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  ATLColors.getPrimaryColor(widget.sportCategory),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPaymentDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ATLColors.getPrimaryColor(
                        widget.sportCategory,
                      ),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.payment),
                    label: const Text(
                      'Pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  void _showPaymentDialog() {
    final toPay = widget.participation.toPay ?? 0;
    final tournamentName = widget.tournament?.name ??
        'Tournament #${widget.participation.tournamentId}';
    final amountController = TextEditingController();

    showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'How much do you want to pay?',
          style: TextStyle(
            color: ATLColors.getPrimaryColor(widget.sportCategory),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournamentName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount due: €${toPay.toStringAsFixed(2)}',
              style: const TextStyle(color: ATLColors.subtext, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                _MaxValueInputFormatter(maxValue: toPay),
              ],
              decoration: InputDecoration(
                labelText: 'Amount to pay',
                prefixText: '€',
                hintText: '0.00 – ${toPay.toStringAsFixed(2)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    ).then((chosenAmount) {
      if (chosenAmount == null || !mounted) return;

      Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            sportCategory: widget.sportCategory,
            totalPrice: chosenAmount,
            genericPurchase: {
              'name': tournamentName,
              'description': 'Fee',
            },
            onPayPressed: () => DBWrite.updatePayment(
              widget.participation.tournamentId,
              widget.participation.teamId,
              chosenAmount,
            ),
          ),
        ),
      ).then((result) {
        if (result == true && mounted) {
          // TODO: handle post-payment transition
          widget.onPaymentCompleted();
        }
      });
    });
  }
}

class _MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;

  _MaxValueInputFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = double.tryParse(newValue.text);
    if (value == null) return oldValue;
    if (value > maxValue) return oldValue;
    return newValue;
  }
}
