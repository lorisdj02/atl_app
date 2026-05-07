import 'package:atl_app/database/responses/wallet_response.dart';
import 'package:atl_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/enums/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../models/wallet.dart';
import '../../database/services/profile_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/transaction_card.dart';

class WalletScreen extends StatefulWidget {
  final SportCategory currentSport;

  const WalletScreen({super.key, required this.currentSport});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Wallet? _wallet;
  //TODO: implement pagination for transactions and load only a few at a time
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final user = userProvider.activeAccount;
    if (user != null) {
      final WalletResponse data = await ProfileService.getWalletScreen();
      if (mounted) {
        setState(() {
          _wallet = data.wallet;
          _transactions = data.transactions;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInfoMessage(
    BuildContext context,
    bool isPlayer,
    bool isReferee,
    bool isCoordinator,
    bool isOrganization,
  ) {
    final l10n = AppLocalizations.of(context);
    if (isPlayer) {
      return l10n.walletInfoPlayer;
    } else if (isCoordinator) {
      return l10n.walletInfoCoordinator;
    } else if (isReferee) {
      return l10n.walletInfoReferee;
    } else if (isOrganization) {
      return l10n.walletInfoOrganization;
    } else {
      return l10n.walletInfoFallback;
    }
  }

  void _showInfoDialog(
    BuildContext context, {
    bool isPlayer = false,
    bool isReferee = false,
    bool isCoordinator = false,
    bool isOrganization = false,
  }) {
    final message = _getInfoMessage(
      context,
      isPlayer,
      isReferee,
      isCoordinator,
      isOrganization,
    );
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.walletInfo),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showWithdrawMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.withdrawOptions,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            title: Text(l10n.withdrawAll),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw all
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.withdrawAllComingSoon)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: Text(l10n.withdrawPersonalBalance),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw personal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.withdrawPersonalComingSoon)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.orange),
            title: Text(l10n.withdrawPrizeBalance),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw prize
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.withdrawPrizeComingSoon)),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AccountProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isPlayer = userProvider.isPlayer;
    final isReferee = userProvider.isReferee;
    final isCoordinator = userProvider.isCoordinator;
    final isOrganization = userProvider.isOrganization;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        appBar: AppBar(
          backgroundColor: ATLColors.darkBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.walletTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final balance = _wallet?.personalBalance ?? 0.0;
    final prizeBalance = _wallet?.prizeBalance ?? 0.0;
    final netPrize = prizeBalance * 0.8;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.walletTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () => _showInfoDialog(
              context,
              isPlayer: isPlayer,
              isReferee: isReferee,
              isCoordinator: isCoordinator,
              isOrganization: isOrganization,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                if (isPlayer) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.personalBalance,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\u20AC${balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.white.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              l10n.prizeBalance,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\u20AC${prizeBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '(\u20AC${netPrize.toStringAsFixed(2)})', // TODO: check real tax retention
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    l10n.currentBalance,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u20AC${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isPlayer
                        ? () => _showWithdrawMenu(context)
                        : () {
                            // TODO: Implement withdraw for non-player
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.withdrawComingSoon)),
                            );
                          },
                    icon: const Icon(Icons.arrow_upward),
                    label: Text(l10n.withdraw),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ATLColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions Section
          Expanded(
            child: _transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: ATLColors.subtext.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noTransactionsTitle,
                          style: const TextStyle(
                            color: ATLColors.darkBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            l10n.noTransactionsSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ATLColors.subtext,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.possibleNewPaymentsTitle,
                                style: const TextStyle(
                                  color: ATLColors.darkBlue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.noTransactionsSubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ATLColors.subtext,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final transaction = _transactions[index - 1];
                      return TransactionCard(transaction: transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
