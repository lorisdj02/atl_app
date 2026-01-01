import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/db_controller.dart';
import '../../models/tournament.dart';
import '../../models/tournament_partecipation.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';

class PayParticipationScreen extends StatefulWidget {
  final int teamId;
  final SportCategory sportCategory;

  const PayParticipationScreen({
    super.key,
    required this.teamId,
    required this.sportCategory,
  });

  @override
  State<PayParticipationScreen> createState() => _PayParticipationScreenState();
}

class _PayParticipationScreenState extends State<PayParticipationScreen> {
  List<TournamentPartecipation>? _participations;
  final Map<int, Tournament?> _tournamentCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipations();
  }

  Future<void> _loadParticipations() async {
    try {
      final participations = await DB.TournamentPartecipations.getByTeamId(widget.teamId);
      final pendingPayments = participations.where((p) => (p.toPay ?? 0) > 0).toList();

      for (var participation in pendingPayments) {
        final tournament = await DB.Tournaments.getById(participation.tournamentId);
        _tournamentCache[participation.tournamentId] = tournament;
      }

      if (mounted) {
        setState(() {
          _participations = pendingPayments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading participations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pending Payments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingATL()
          : _participations == null || _participations!.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 80, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'No pending payments',
                        style: TextStyle(fontSize: 18, color: ATLColors.subtext),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _participations!.length,
                  itemBuilder: (context, index) {
                    final participation = _participations![index];
                    final tournament = _tournamentCache[participation.tournamentId];
                    return _buildParticipationCard(participation, tournament);
                  },
                ),
    );
  }

  Widget _buildParticipationCard(TournamentPartecipation participation, Tournament? tournament) {
    final double toPay = participation.toPay ?? 0;
    final double totalCost = tournament?.fee ?? toPay;
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
            Text(
              tournament?.name ?? 'Tournament #${participation.tournamentId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ATLColors.darkBlue,
              ),
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
                valueColor: AlwaysStoppedAnimation<Color>(ATLColors.getPrimaryColor(widget.sportCategory)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPaymentDialog(participation, tournament),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
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

  void _showPaymentDialog(TournamentPartecipation participation, Tournament? tournament) {
    final toPay = participation.toPay ?? 0;
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
              tournament?.name ?? 'Tournament #${participation.tournamentId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Amount due: €${toPay.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  const SnackBar(content: Text('Amount must be greater than 0')),
                );
                return;
              }

              if (amount > toPay) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Amount cannot exceed €${toPay.toStringAsFixed(2)}')),
                );
                return;
              }

              // TODO: Payment integration
              final newToPay = toPay - amount;
              if(await DB().updatePayment(participation.tournamentId, participation.teamId, newToPay) == false){
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error processing payment')),
                  );
                }
                return;
              }

              if (context.mounted) {
                Navigator.of(context).pop();
                _loadParticipations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment of €${amount.toStringAsFixed(2)} processed')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
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
