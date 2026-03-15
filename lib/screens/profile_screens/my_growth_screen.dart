import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/sport_category.dart';
import '../../models/growth_step.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await DBRead.getMyGrowthScreen(user.id);
      if (mounted) {
        setState(() {
          _currentLevel = (data[ApiJsonKeys.level] as num).toInt();
          final steps = data[ApiJsonKeys.growthSteps] as List<GrowthStep>;
          steps.sort((a, b) => a.level.compareTo(b.level));
          _growthSteps = steps;
          _isReferee = userProvider.isReferee;
          _isCoordinator = userProvider.isCoordinator;
          if (_isReferee) {
            _minPay = data[ApiJsonKeys.minRefereePayPerCategoryPerLevel]
                as Map<int, Map<SportCategory, double>>;
            _maxPay = data[ApiJsonKeys.maxRefereePayPerCategoryPerLevel]
                as Map<int, Map<SportCategory, double>>;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color get _catColor => ATLColors.getPrimaryColor(widget.currentSport);
  Color get _catColorLight => ATLColors.getSecondaryColor(widget.currentSport);

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
        title: const Text(
          'MY GROWTH',
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
              ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: ATLColors.subtext),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 28),
                      _buildSectionLabel('GROWTH PATH'),
                      const SizedBox(height: 16),
                      _buildTimeline(),
                      if (_isReferee) ...[
                        const SizedBox(height: 12),
                        _buildPayNote(),
                      ],
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeroCard() {
    final step = _currentStep;
    if (step == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ATLColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _catColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'LVL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${step.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isReferee ? 'Referee' : 'Coordinator',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            widget.currentSport.icon,
            color: _catColor.withOpacity(0.45),
            size: 38,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: ATLColors.darkBlue,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_growthSteps.length, (i) {
        final step = _growthSteps[i];
        final isLast = i == _growthSteps.length - 1;
        return _buildTimelineRow(step, isLast);
      }),
    );
  }

  Widget _buildTimelineRow(GrowthStep step, bool isLast) {
    final isCurrent = step.level == _currentLevel;
    final isCompleted = step.level < _currentLevel;
    final isFuture = step.level > _currentLevel;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildNode(isCurrent, isCompleted, isFuture, step.level),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: isCompleted
                            ? ATLColors.darkBlue.withOpacity(0.25)
                            : ATLColors.subtext.withOpacity(0.12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _buildStepCard(step, isCurrent, isCompleted, isFuture),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(
      bool isCurrent, bool isCompleted, bool isFuture, int level) {
    Color bg;
    if (isCurrent) {
      bg = _catColor;
    } else if (isCompleted) {
      bg = ATLColors.darkBlue;
    } else {
      bg = ATLColors.subtext.withOpacity(0.18);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border:
            isCurrent ? Border.all(color: _catColorLight, width: 2) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$level',
                style: TextStyle(
                  color: isFuture
                      ? ATLColors.subtext.withOpacity(0.4)
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepCard(
      GrowthStep step, bool isCurrent, bool isCompleted, bool isFuture) {
    final cardBg = isCurrent ? _catColor.withOpacity(0.07) : Colors.white;
    final borderColor = isCurrent ? _catColor : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? _catColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: isCurrent ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    color: isFuture
                        ? ATLColors.subtext.withOpacity(0.45)
                        : ATLColors.darkBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _catColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRequirements(step, isFuture),
          const SizedBox(height: 10),
          _buildPayInfo(step, isFuture),
        ],
      ),
    );
  }

  Widget _buildRequirements(GrowthStep step, bool isFuture) {
    final color =
        isFuture ? ATLColors.subtext.withOpacity(0.4) : ATLColors.subtext;

    if (step.level == 1) {
      return _reqRow(Icons.flag_outlined, 'Starting level — no requirements',
          color);
    }

    if (_isReferee) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reqRow(
            Icons.sports_score_outlined,
            'Min. ${step.minRefereedGames} games refereed',
            color,
          ),
          const SizedBox(height: 4),
          _reqRow(
            Icons.star_outline,
            'Avg. rating ≥ ${step.minRatingOverLastXGames!.toStringAsFixed(1)} over last ${step.x} games',
            color,
          ),
        ],
      );
    }

    if (_isCoordinator) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reqRow(
            Icons.emoji_events_outlined,
            'Min. ${step.minCoordinatedTournaments} tournaments coordinated',
            color,
          ),
          const SizedBox(height: 4),
          _reqRow(
            Icons.star_outline,
            'Avg. rating ≥ ${step.minRatingOverLastXTournaments!.toStringAsFixed(1)} over last ${step.x} tournaments',
            color,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _reqRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: TextStyle(color: color, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildPayInfo(GrowthStep step, bool isFuture) {
    if (_isReferee) {
      final chips = SportCategory.values.map((cat) {
        final min = _minPay[step.level]?[cat];
        final max = _maxPay[step.level]?[cat];
        if (min == null || max == null) return null;
        return _categoryPayChip(cat, min, max, isFuture);
      }).whereType<Widget>().toList();

      if (chips.isEmpty) return const SizedBox.shrink();
      return Wrap(spacing: 8, runSpacing: 6, children: chips);
    }

    if (_isCoordinator && step.coordinatorPayPerGame != null) {
      final color = ATLColors.darkBlue.withOpacity(isFuture ? 0.35 : 1.0);
      return _infoChip(
        icon: Icons.payments_outlined,
        text: '€${step.coordinatorPayPerGame!.toStringAsFixed(2)} / game',
        bg: ATLColors.darkBlue.withOpacity(isFuture ? 0.05 : 0.08),
        color: color,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _categoryPayChip(
      SportCategory cat, double min, double max, bool isFuture) {
    final base = ATLColors.getPrimaryColor(cat);
    final textColor = base.withOpacity(isFuture ? 0.35 : 1.0);
    final payText = (min == max)
        ? '€${min.toStringAsFixed(2)} / game'
        : '€${min.toStringAsFixed(2)} – €${max.toStringAsFixed(2)} / game';

    return _infoChip(
      icon: cat.icon,
      text: '${cat.name}  •  $payText',
      bg: base.withOpacity(isFuture ? 0.05 : 0.1),
      color: textColor,
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ATLColors.lightBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline, color: ATLColors.darkBlue, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pay may vary by role within the same sport category. '
              'Figures shown are the min–max range across all roles for that level.',
              style: TextStyle(color: ATLColors.darkBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
