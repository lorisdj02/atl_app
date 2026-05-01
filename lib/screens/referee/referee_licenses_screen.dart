import 'package:atl_app/database/services/account_service.dart';
import 'package:atl_app/database/responses/referee_licenses_response.dart';
import 'package:atl_app/database/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/referee_license.dart';
import '../../models/sport.dart';
import '../../models/enums/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/referee_license_widget.dart';
import '../../widgets/add_referee_license_dialog.dart';
import '../../widgets/atl_floating_button.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums/license_status.dart';

class RefereeLicensesScreen extends StatefulWidget {
  final SportCategory currentSport;

  const RefereeLicensesScreen({super.key, required this.currentSport});

  @override
  State<RefereeLicensesScreen> createState() => _RefereeLicensesScreenState();
}

class _RefereeLicensesScreenState extends State<RefereeLicensesScreen> {
  bool _isLoading = true;
  List<RefereeLicense> _licenses = [];
  List<Sport> _sports = [];
  SportCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final RefereeLicensesResponse data =
          await ProfileService.getRefereeLicensesScreen();

      if (mounted) {
        setState(() {
          _licenses = data.refereeLicenses;
          _sports = data.sports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorText(e.toString())),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  List<RefereeLicense> get _filteredLicenses {
    if (_selectedCategory == null) return _licenses;
    final sportIds = _sports
        .where((s) => s.sportCategory == _selectedCategory)
        .map((s) => s.id)
        .toSet();
    return _licenses.where((l) => sportIds.contains(l.sportId)).toList();
  }

  Sport? _sportById(double id) {
    try {
      return _sports.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleDelete(RefereeLicense license) async {
    final l10n = AppLocalizations.of(context);
    if (license.status != LicenseStatus.notVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteLicenseNotVerifiedStatus)),
      );
      return;
    }

    final sport = _sportById(license.sportId);
    final licenseName = sport?.name ?? l10n.licenseGenericName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.deleteLicenseTitle,
          style: const TextStyle(
            color: ATLColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.confirmDeleteLicense(licenseName, license.licenseId),
          style: const TextStyle(color: ATLColors.subtext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: ATLColors.subtext),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.deleteText),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AccountService.Write.deleteRefereeLicense(
        license.sportId.toDouble(),
      );
      if (mounted) {
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.licenseDeletedSuccessfully)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedToDeleteLicense)));
    }
  }

  Future<void> _openAddDialog() async {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final refereeId = userProvider.activeRoleId!;

    // Sports the referee does NOT yet have a license for
    final existingSportIds = _licenses.map((l) => l.sportId).toSet();
    final availableSports = _sports
        .where((s) => !existingSportIds.contains(s.id))
        .toList();

    if (availableSports.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.alreadyHasLicenseAllSports)));
      return;
    }

    final added = await showDialog<RefereeLicense>(
      context: context,
      builder: (ctx) => AddRefereeLicenseDialog(
        availableSports: availableSports,
        refereeId: refereeId,
        onSubmit: (license) =>
            AccountService.Write.insertRefereeLicense(license),
      ),
    );

    if (added != null && mounted) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Build category filter tabs from available sport categories in _sports
    final categories = _sports.map((s) => s.sportCategory).toSet().toList();

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
          l10n.licenses.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: ATLFloatingButton(
        onPressed: _isLoading ? () {} : _openAddDialog,
        backgroundColor: ATLColors.darkBlue,
        icon: Icons.add,
        label: l10n.addLicenseTitle,
      ),
      body: _isLoading
          ? const Center(child: LoadingATL())
          : Column(
              children: [
                // Category filter chips
                if (categories.length > 1) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip(null, l10n.allFilter),
                          ...categories.map(
                            (cat) => _filterChip(cat, cat.name),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                // Licenses list
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _filterChip(SportCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    final color = category != null
        ? ATLColors.getPrimaryColor(category)
        : ATLColors.darkBlue;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? color : ATLColors.subtext,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? color : ATLColors.subtext.withOpacity(0.3),
        ),
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildList() {
    final l10n = AppLocalizations.of(context);
    final licenses = _filteredLicenses;

    if (licenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 80,
                color: ATLColors.subtext.withOpacity(0.4),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noLicensesTitle,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.noLicensesSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ATLColors.subtext, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: licenses.length,
      itemBuilder: (context, index) {
        final license = licenses[index];
        return RefereeLicenseWidget(
          license: license,
          sport: _sportById(license.sportId),
          onLongPress: () => _handleDelete(license),
        );
      },
    );
  }
}
