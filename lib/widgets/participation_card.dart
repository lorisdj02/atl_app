import 'package:atl_app/database/services/payment_service.dart';
import 'package:atl_app/models/checkout_payload.dart';
import 'package:atl_app/providers/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/shop/checkout_screen.dart';
import '../models/tournament.dart';
import '../models/tournament_participation.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';
import '../models/checkout_session.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/checkout_type.dart';

class ParticipationCard extends StatefulWidget {
  final TournamentParticipation participation;
  final Tournament? tournament;
  final double playerId;
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
    final l10n = AppLocalizations.of(context);
    final double toPay = widget.participation.toPay;
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
                        '${l10n.tournamentLabel} #${widget.participation.tournamentId}',
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          l10n.calledUpLabel,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          l10n.notCalledUpLabel,
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
                  l10n.payOutOf(
                    paid.toStringAsFixed(0),
                    totalCost.toStringAsFixed(0),
                  ),
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
                    label: Text(
                      l10n.payButton,
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

  void _showPaymentDialog() async {
    final l10n = AppLocalizations.of(context);
    final toPay = widget.participation.toPay;
    final tournamentName =
        widget.tournament?.name ??
        '${l10n.tournamentLabel} #${widget.participation.tournamentId}';
    final amountController = TextEditingController();

    showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.howMuchToPayTitle,
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
              l10n.amountDueLabel(toPay),
              style: const TextStyle(color: ATLColors.subtext, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                _MaxValueInputFormatter(maxValue: toPay),
              ],
              decoration: InputDecoration(
                labelText: l10n.amountToPayLabel,
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
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.enterValidAmount),
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
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    ).then((chosenAmount) async {
      if (chosenAmount == null || !mounted) return;

      AccountProvider userProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );

      if (userProvider.activeAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.userNotLoggedIn),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      CheckoutPayload payload = CheckoutPayload(
        tournamentId: widget.participation.tournamentId,
        amount: chosenAmount,
        checkoutType: CheckoutType.tournamentFee,
        sportCategory: widget.sportCategory,
      );

      final CheckoutSession checkoutSession =
          await PaymentService.createCheckoutSession(payload);

      if (mounted) {
        Navigator.of(context)
            .push<bool>(
              MaterialPageRoute(
                builder: (context) => CheckoutScreen(
                  sportCategory: widget.sportCategory,
                  sessionId: checkoutSession.id,
                ),
              ),
            )
            .then((result) {
              if (result == true && mounted) {
                // TODO: handle post-payment transition
                widget.onPaymentCompleted();
              }
            });
      }
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
