import 'package:atl_app/database/responses/my_growth_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/sport_category.dart';
import '../../models/growth_step.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/growth_hero_card.dart';
import '../../widgets/growth_timeline_item.dart';
import '../../widgets/growth_pay_note.dart';
import '../../database/db_read.dart';
import '../../l10n/app_localizations.dart';

class MyGrowthScreen extends StatefulWidget {
  final SportCategory currentSport;

  const MyGrowthScreen({super.key, required this.currentSport});

  @override
  State<MyGrowthScreen> createState() => _MyGrowthScreenState();
}

class _MyGrowthScreenState extends State<MyGrowthScreen> {
  bool _isLoading = true;
  int _currentLevel = 1;
  List<GrowthStep> _growthSteps = [];
  Map<int, Map<SportCategory, double>> _minPay = {};
  Map<int, Map<SportCategory, double>> _maxPay = {};
  bool _isReferee = false;
  bool _isCoordinator = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final user = userProvider.activeAccount;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final MyGrowthResponse data = await DBRead.getMyGrowthScreen(user.id);
      if (mounted) {
        setState(() {
          _currentLevel = data.level;
          final steps = data.growthSteps;
          steps.sort((a, b) => a.level.compareTo(b.level));
          _growthSteps = steps;
          _isReferee = userProvider.isReferee;
          _isCoordinator = userProvider.isCoordinator;
          if (_isReferee) {
            _minPay = data.minRefereePayPerCategoryPerLevel;
            _maxPay = data.maxRefereePayPerCategoryPerLevel;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorLoadingData(e.toString()),
            style: const TextStyle(color: Colors.white),
          ),          backgroundColor: Colors.red,
        ),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  GrowthStep? get _currentStep {
    try {
      return _growthSteps.firstWhere((s) => s.level == _currentLevel);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context).myGrowth.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingATL())
          : _growthSteps.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).noDataAvailable,
                    style: const TextStyle(color: ATLColors.subtext),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep != null)
                        GrowthHeroCard(
                          step: _currentStep!,
                          catColor: ATLColors.getPrimaryColor(widget.currentSport),
                          currentSport: widget.currentSport,
                          isReferee: _isReferee,
                        ),
                      const SizedBox(height: 28),
                      Text(
                        AppLocalizations.of(context).growthPath.toUpperCase(),
                        style: TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(_growthSteps.length, (i) {
                          return GrowthTimelineItem(
                            step: _growthSteps[i],
                            isLast: i == _growthSteps.length - 1,
                            currentLevel: _currentLevel,
                            catColor: ATLColors.getPrimaryColor(widget.currentSport),
                            catColorLight: ATLColors.getSecondaryColor(widget.currentSport),
                            isReferee: _isReferee,
                            isCoordinator: _isCoordinator,
                            minPay: _minPay,
                            maxPay: _maxPay,
                          );
                        }),
                      ),
                      if (_isReferee) ...[
                        const SizedBox(height: 12),
                        const GrowthPayNote(),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }
}
