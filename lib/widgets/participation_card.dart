import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/db_controller.dart';
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

  const ParticipationCard({
    super.key,
    required this.participation,
    required this.tournament,
    required this.playerId,
    required this.sportCategory,
    required this.onPaymentCompleted,
  });

  @override
  State<ParticipationCard> createState() => _ParticipationCardState();
}

class _ParticipationCardState extends State<ParticipationCard> {
  bool? _isCalledUp;
  bool _isCheckingCallup = true;

  @override
  void initState() {
    super.initState();
    _checkCallupStatus();
  }

  Future<void> _checkCallupStatus() async {
    try {
      final isCalledUp = await DB.CallUps.isPlayerInCallup(
        widget.playerId,
        widget.participation.tournamentId,
      );
      if (mounted) {
        setState(() {
          _isCalledUp = isCalledUp;
          _isCheckingCallup = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCalledUp = null;
          _isCheckingCallup = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double toPay = widget.participation.toPay ?? 0;
    final double totalCost = widget.tournament?.fee ?? toPay;
    final double paid = totalCost - toPay;
    final double progress = totalCost > 0 ? paid / totalCost : 0.0;
    print("ParticipationCard: toPay=$toPay, totalCost=$totalCost, paid=$paid, progress=$progress, isCalledUp=$_isCalledUp");

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
                else if (_isCalledUp == true)
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
                else if (_isCalledUp == false)
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
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tournament?.name ?? 'Tournament #${widget.participation.tournamentId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount due: €${toPay.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                _MaxValueInputFormatter(maxValue: toPay),
              ],
              decoration: InputDecoration(
                labelText: 'Amount to pay',
                prefixText: '€',
                hintText: '0.00 - ${toPay.toStringAsFixed(2)}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'TODO: Payment integration',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
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
            onPressed: () async {
              final amountText = amountController.text.trim();
              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an amount')),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }

              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Amount must be greater than 0'),
                  ),
                );
                return;
              }

              if (amount > toPay) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Amount cannot exceed €${toPay.toStringAsFixed(2)}',
                    ),
                  ),
                );
                return;
              }

              // TODO: Payment integration
              if (await DB().updatePayment(
                    widget.participation.tournamentId,
                    widget.participation.teamId,
                    amount,
                  ) ==
                  false) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error processing payment')),
                  );
                }
                return;
              }

              if (context.mounted) {
                Navigator.of(context).pop();
                widget.onPaymentCompleted();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment of €${amount.toStringAsFixed(2)} processed',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay'),
          ),
        ],
      ),
    );
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
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double? value = double.tryParse(newValue.text);

    if (value == null) {
      return oldValue;
    }

    if (value > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}
