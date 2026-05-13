import 'package:atl_app/database/responses/purchases_response.dart';
import 'package:atl_app/database/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/enums/sport_category.dart';
import '../../models/purchase.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/purchase_widget.dart';

class PurchasesScreen extends StatefulWidget {
  final SportCategory currentSport;

  const PurchasesScreen({super.key, required this.currentSport});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  bool _isLoading = true;
  List<Purchase> _purchases = [];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final user = userProvider.activeAccount;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final PurchasesResponse data = await ProfileService.getPurchasesScreen();
      if (mounted) {
        setState(() {
          _purchases = data.purchases;
          _purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        appBar: _buildAppBar(l10n),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: _buildAppBar(l10n),
      body: _purchases.isEmpty ? _buildEmpty(l10n) : _buildList(),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ATLColors.darkBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.purchasesTitle,
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

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: ATLColors.subtext.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.comingSoonText,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.purchasesComingSoon,
              textAlign: TextAlign.center,
              style: TextStyle(color: ATLColors.subtext, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchases.length,
      itemBuilder: (context, index) {
        final purchase = _purchases[index];
        return PurchaseWidget(purchase: purchase);
      },
    );
  }
}
