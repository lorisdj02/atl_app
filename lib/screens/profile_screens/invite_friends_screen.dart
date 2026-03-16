import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';
import '../../l10n/app_localizations.dart';

class InviteFriendsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const InviteFriendsScreen({super.key, required this.currentSport});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  bool _isLoading = true;
  String? _referralCode;
  double _inviteBalance = 0.0;
  int _numInvites = 0;
  int _numRedeemed = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await DBRead.getInviteFriendsScreen(user.id);
      if (mounted) {
        setState(() {
          _referralCode = data[ApiJsonKeys.referralCode] as String?;
          _inviteBalance =
              (data[ApiJsonKeys.inviteBalance] as num).toDouble();
          _numInvites = (data[ApiJsonKeys.numInvites] as num).toInt();
          _numRedeemed = (data[ApiJsonKeys.numRedeemed] as num).toInt();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyCode() {
    if (_referralCode == null) return;
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: _referralCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.codeCopied),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: ATLColors.darkBlue, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: ATLColors.subtext),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Invite balance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: ATLColors.darkBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.inviteBalance,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\u20AC${_inviteBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.earnMoreByInviting,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Referral code card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourReferralCode,
                    style: const TextStyle(color: ATLColors.subtext, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: ATLColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ATLColors.darkBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _referralCode ?? '\u2014',
                            style: const TextStyle(
                              color: ATLColors.darkBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copyCode,
                          icon: const Icon(Icons.copy, color: ATLColors.darkBlue),
                          tooltip: l10n.copyCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _copyCode,
                      icon: const Icon(Icons.share),
                      label: Text(l10n.copyAndShare),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ATLColors.darkBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.group_outlined,
                      label: l10n.friendsJoined,
                      value: '$_numInvites',
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.redeem_outlined,
                      label: l10n.redeems,
                      value: '$_numRedeemed',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Info hint
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ATLColors.lightBlue.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ATLColors.darkBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.shareCodeInfo,
                      style: const TextStyle(
                        color: ATLColors.darkBlue,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: ATLColors.darkBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.inviteAFriendTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      centerTitle: true,
    );
  }
}
