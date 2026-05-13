import 'package:atl_app/database/requests/payment_intent_request.dart';
import 'package:atl_app/database/services/payment_service.dart';
import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:atl_app/models/purchase.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../../models/checkout_session.dart';
import '../../models/enums/sport_category.dart';
import '../../models/wallet.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums/checkout_type.dart';

class CheckoutScreen extends StatefulWidget {
  final SportCategory sportCategory;
  final double sessionId;

  const CheckoutScreen({
    super.key,
    required this.sportCategory,
    required this.sessionId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutSession? _session;
  Wallet? _wallet;
  bool _isLoading = true;
  bool _isProcessing = false;

  bool _useWallet = false;
  bool _walletInfoExpanded = false;

  final TextEditingController _discountController = TextEditingController();
  double _discountAmount = 0.0;
  String? _appliedCode;
  String? _discountError;

  // Display data loaded from getCheckoutScreen
  String? _tournamentName;
  String? _fieldName;
  String? _fieldAddress;
  String? _cityName;
  String? _bookingUsername;
  DateTime? _startTime;
  DateTime? _endTime;
  int? _maxPlayers;
  int? _playersToPay;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final CheckoutResponse data = await PaymentService.getCheckoutScreen(
        widget.sessionId.toDouble(),
      );
      setState(() {
        _session = data.checkoutSession;
        _wallet = data.wallet;
        _tournamentName = data.tournamentName;
        _fieldName = data.fieldName;
        _fieldAddress = data.fieldAddress;
        _cityName = data.cityName;
        _bookingUsername = data.bookingUsername;
        _startTime = data.startTime;
        _endTime = data.finishTime;
        _maxPlayers = data.totalPlayers;
        _playersToPay = data.playersToPay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.errorLoadingCheckout(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Discount ──────────────────────────────────────────────────────────────

  void _applyDiscountCode() {
    final code = _discountController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _discountError = null;
      final base = _session?.amount ?? 0;
      // Mock: any code starting with 'ATL' gives 10 % off
      if (code.startsWith('ATL')) {
        _discountAmount = (base * 0.10 * 100).roundToDouble() / 100;
        _appliedCode = code;
      } else {
        _discountAmount = 0;
        _appliedCode = null;
        _discountError = _l10n.invalidDiscountCode;
      }
    });
  }

  void _removeDiscountCode() {
    setState(() {
      _discountController.clear();
      _discountAmount = 0;
      _appliedCode = null;
      _discountError = null;
    });
  }

  // ── Wallet calculation ────────────────────────────────────────────────────

  double _walletDeduction() {
    if (!_useWallet || _wallet == null || _session == null) return 0;
    final remaining = _session!.amount - _discountAmount;
    if (remaining <= 0) return 0;

    double available =
        _wallet!.prizeBalance +
        _wallet!.inviteBalance +
        _wallet!.personalBalance;
    return available >= remaining ? remaining : available;
  }

  double _finalPrice() {
    if (_session == null) return 0;
    final afterDiscount = _session!.amount - _discountAmount;
    final afterWallet = afterDiscount - _walletDeduction();
    return afterWallet < 0 ? 0 : afterWallet;
  }

  // ── Payment ───────────────────────────────────────────────────────────────

  Future<void> _payWithStripe() async {
    final sheetData = await PaymentService.createStripePaymentSheet(
      widget.sessionId.toDouble(),
      _useWallet,
    );

    Stripe.publishableKey = sheetData.publishableKey;
    await Stripe.instance.applySettings();

    debugPrint('[Stripe] initPaymentSheet start');
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'ATL',
        paymentIntentClientSecret: sheetData.clientSecret,
        customerId: sheetData.customerId,
        customerEphemeralKeySecret: sheetData.ephemeralKey,
      ),
    );

    debugPrint('[Stripe] presentPaymentSheet start');
    await Stripe.instance.presentPaymentSheet();
    debugPrint('[Stripe] presentPaymentSheet success');

    Purchase? purchase = await PaymentService.payCheckoutSession(
      widget.sessionId.toDouble(),
      _useWallet,
      paymentIntentRequest: PaymentIntentRequest(paymentIntentId: sheetData.paymentIntentId),
    );
    if (purchase == null) {
      throw Exception('purchase_null');
    }
  }

  Future<void> _onPay() async {
    setState(() => _isProcessing = true);
    try {
      if (_session == null) return;

      final finalPrice = _finalPrice();
      if (finalPrice == 0) {
        final purchase = await PaymentService.payCheckoutSession(
          widget.sessionId.toDouble(),
          _useWallet,
        );
        if (purchase == null) throw Exception('purchase_null');
      } else {
        await _payWithStripe();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.paymentCompletedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } on StripeException {
      debugPrint('[Stripe] payment failed (StripeException)');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.paymentFailed),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint('[Stripe] payment failed (Exception): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.paymentFailed),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  Color get _primaryColor => ATLColors.getPrimaryColor(widget.sportCategory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _l10n.checkoutTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingATL()
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOrderSummary(),
                          const SizedBox(height: 16),
                          _buildDiscountSection(),
                          const SizedBox(height: 16),
                          _buildWalletSection(),
                          const SizedBox(height: 16),
                          _buildPriceSummary(),
                        ],
                      ),
                    ),
                  ),
                  _buildPayButton(),
                ],
              ),
            ),
    );
  }

  // ── Order summary ─────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    if (_session == null) return const SizedBox();
    return _SectionCard(
      title: _l10n.purchaseSummary,
      child: switch (_session!.type) {
        CheckoutType.tournamentFee => _buildTournamentDetails(),
        CheckoutType.lobbyBookingCreate ||
        CheckoutType.lobbyBookingParticipate => _buildLobbyDetails(),
        CheckoutType.privateBooking => _buildPrivateDetails(),
        _ => const SizedBox(),
      },
    );
  }

  Widget _buildLobbyDetails() {
    return Column(
      children: [
        _buildDetailRow(
          Icons.sports_soccer,
          _l10n.lobbyBookingType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (_fieldName != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.stadium_outlined, _fieldName!),
          _buildDetailRow(
            Icons.location_on_outlined,
            '${_fieldAddress ?? ''}${_cityName != null ? ', $_cityName' : ''}',
          ),
        ],
        if (_startTime != null && _endTime != null) ...[
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.access_time,
            '${_formatTime(_startTime!)} – ${_formatTime(_endTime!)}'
            '  •  ${_formatDate(_startTime!)}',
          ),
        ],
        if (_playersToPay != null && _maxPlayers != null)
          _buildDetailRow(
            Icons.group_outlined,
            _l10n.playersDetail(_playersToPay!, _maxPlayers!),
          ),
        if (_bookingUsername != null)
          _buildDetailRow(
            Icons.person_outlined,
            _l10n.ownerDetail(_bookingUsername!),
          ),
      ],
    );
  }

  Widget _buildPrivateDetails() {
    return Column(
      children: [
        _buildDetailRow(
          Icons.lock_outlined,
          _l10n.privateBookingType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        if (_fieldName != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.stadium_outlined, _fieldName!),
          _buildDetailRow(
            Icons.location_on_outlined,
            '${_fieldAddress ?? ''}${_cityName != null ? ', $_cityName' : ''}',
          ),
        ],
        if (_startTime != null && _endTime != null) ...[
          const SizedBox(height: 4),
          _buildDetailRow(
            Icons.access_time,
            '${_formatTime(_startTime!)} – ${_formatTime(_endTime!)}'
            '  •  ${_formatDate(_startTime!)}',
          ),
        ],
      ],
    );
  }

  Widget _buildTournamentDetails() {
    return Column(
      children: [
        _buildDetailRow(
          Icons.receipt_outlined,
          _tournamentName ?? _l10n.tournamentType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 4),
        _buildDetailRow(Icons.info_outline, _l10n.feeLabel),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: ATLColors.subtext),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  style ??
                  const TextStyle(fontSize: 14, color: ATLColors.subtext),
            ),
          ),
        ],
      ),
    );
  }

  // ── Discount section ──────────────────────────────────────────────────────

  Widget _buildDiscountSection() {
    return _SectionCard(
      title: _l10n.discountCode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  decoration: InputDecoration(
                    hintText: _l10n.enterDiscountCode,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: _discountError,
                    suffixIcon: _appliedCode != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _removeDiscountCode,
                          )
                        : null,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  enabled: _appliedCode == null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _appliedCode != null ? null : _applyDiscountCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_l10n.applyButton),
              ),
            ],
          ),
          if (_appliedCode != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  _l10n.discountApplied(
                    _appliedCode!,
                    '€${_discountAmount.toStringAsFixed(2)}',
                  ),
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Wallet section ────────────────────────────────────────────────────────

  Widget _buildWalletSection() {
    return _SectionCard(
      title: _l10n.walletSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _l10n.useWalletBalance,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _useWallet,
                onChanged: _wallet != null
                    ? (val) => setState(() => _useWallet = val)
                    : null,
                activeColor: _primaryColor,
              ),
            ],
          ),

          // Info box
          GestureDetector(
            onTap: () =>
                setState(() => _walletInfoExpanded = !_walletInfoExpanded),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ATLColors.lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ATLColors.darkBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: ATLColors.darkBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _l10n.walletOrderInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ATLColors.darkBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        _walletInfoExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: ATLColors.darkBlue,
                      ),
                    ],
                  ),
                  if (_walletInfoExpanded) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    _buildBalanceRow(
                      _l10n.prizeBalanceLabel,
                      _wallet?.prizeBalance ?? 0,
                      Colors.amber.shade700,
                    ),
                    const SizedBox(height: 4),
                    _buildBalanceRow(
                      _l10n.inviteBalanceLabel,
                      _wallet?.inviteBalance ?? 0,
                      Colors.teal,
                    ),
                    const SizedBox(height: 4),
                    _buildBalanceRow(
                      _l10n.personalBalanceLabel,
                      _wallet?.personalBalance ?? 0,
                      _primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 6),
                    _buildBalanceRow(
                      _l10n.totalAvailable,
                      (_wallet?.prizeBalance ?? 0) +
                          (_wallet?.inviteBalance ?? 0) +
                          (_wallet?.personalBalance ?? 0),
                      ATLColors.darkBlue,
                      bold: true,
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_useWallet && _walletDeduction() > 0) ...[
            const SizedBox(height: 8),
            Text(
              _l10n.walletDeduction(
                '${_walletDeduction().toStringAsFixed(2)}',
              ),
              style: TextStyle(
                fontSize: 13,
                color: _primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_useWallet && _wallet != null) ...[
            if ((_wallet!.prizeBalance +
                    _wallet!.inviteBalance +
                    _wallet!.personalBalance) ==
                0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _l10n.noWalletBalance,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceRow(
    String label,
    double amount,
    Color color, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ATLColors.subtext,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        Text(
          '€${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Price summary ─────────────────────────────────────────────────────────

  Widget _buildPriceSummary() {
    final walletDed = _walletDeduction();
    final finalPrice = _finalPrice();
    final baseAmount = _session?.amount ?? 0;

    return _SectionCard(
      title: _l10n.priceSummary,
      child: Column(
        children: [
          _buildPriceRow(_l10n.subtotal, baseAmount),
          if (_discountAmount > 0)
            _buildPriceRow(
              _l10n.discount(_appliedCode!),
              -_discountAmount,
              color: Colors.green,
            ),
          if (walletDed > 0)
            _buildPriceRow(
              _l10n.walletDeductionLabel,
              -walletDed,
              color: _primaryColor,
            ),
          const Divider(height: 20),
          _buildPriceRow(
            _l10n.totalToPay,
            finalPrice,
            bold: true,
            fontSize: 17,
            color: finalPrice == 0 ? Colors.green : ATLColors.darkBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool bold = false,
    double fontSize = 14,
    Color? color,
  }) {
    final displayColor = color ?? ATLColors.subtext;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: displayColor,
            ),
          ),
          Text(
            '${amount < 0 ? '-' : ''}€${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pay button ────────────────────────────────────────────────────────────

  Widget _buildPayButton() {
    final finalPrice = _finalPrice();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (_isProcessing || _session == null) ? null : _onPay,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                finalPrice == 0
                  ? _l10n.payWithWalletOnly
                  : _l10n.payAmount('€${finalPrice.toStringAsFixed(2)}'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// ── Reusable section card ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ATLColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
