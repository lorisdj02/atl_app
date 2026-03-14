import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../models/wallet.dart';
import '../../config/api_json_keys.dart';
import '../../database/db_read.dart';

class WalletScreen extends StatefulWidget {
  final SportCategory currentSport;

  const WalletScreen({super.key, required this.currentSport});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Wallet? _wallet;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;
    if (user != null) {
      final data = await DBRead.getWalletScreen(user.id);
      if (mounted) {
        setState(() {
          _wallet = data[ApiJsonKeys.wallet];
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
    bool isPlayer,
    bool isReferee,
    bool isCoordinator,
    bool isOrganization,
  ) {
    if (isPlayer) {
      return 'Personal balance contains refund money, withdrawable once a week with no commission removed. Prize balance contains winnings money and is gross. The net is written in parentheses below the prize balance. It can be withdrawn once a month.';
    } else if (isCoordinator) {
      return 'The balance contains refund money and earnings for each tournament. If there is any taxation, it has already been taxed.';
    } else if (isReferee) {
      return 'The balance contains refund money and earnings for each match you refereed. If there is any taxation, it has already been taxed.';
    } else if (isOrganization) {
      return 'The balance contains refund money and earnings for each booking you made. If there is any taxation, it has already been taxed.';
    } else {
      return 'No wallet information available.';
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
      isPlayer,
      isReferee,
      isCoordinator,
      isOrganization,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallet Info'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Withdraw Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            title: const Text('Withdraw ALL'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw all
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdraw ALL coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Withdraw Personal Balance Only'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw personal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdraw Personal Balance coming soon'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.orange),
            title: const Text('Withdraw Prize Balance Only'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement withdraw prize
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdraw Prize Balance coming soon'),
                ),
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
    final userProvider = Provider.of<UserProvider>(context);
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
          title: const Text(
            'WALLET',
            style: TextStyle(
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
    final netPrize = prizeBalance * 0.8; // TODO: check real tax retention

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'WALLET',
          style: TextStyle(
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
              isPlayer : isPlayer,
              isReferee : isReferee,
              isCoordinator : isCoordinator,
              isOrganization : isOrganization,
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
                            const Text(
                              'Personal Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '€${balance.toStringAsFixed(2)}',
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
                            const Text(
                              'Prize Balance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '€${prizeBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '(€${netPrize.toStringAsFixed(2)})', // TODO: check real tax retention
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
                  const Text(
                    'Current Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '€${balance.toStringAsFixed(2)}',
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
                              const SnackBar(
                                content: Text('Withdraw coming soon'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Withdraw'),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: ATLColors.subtext.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Transaction history will be available soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ATLColors.subtext, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
