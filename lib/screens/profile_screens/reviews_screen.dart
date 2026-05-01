import 'package:atl_app/database/responses/reviews_response.dart';
import 'package:atl_app/database/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/enums/sport_category.dart';
import '../../models/review.dart';
import '../../models/account.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/review_widget.dart';
import '../../l10n/app_localizations.dart';

class ReviewsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const ReviewsScreen({super.key, required this.currentSport});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  List<Review> _reviews = [];
  Map<double, Account> _accountPerReview = {};
  Map<double, String> _matchTeamsStringPerReview = {};

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final user = userProvider.activeAccount;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final ReviewsResponse data = await ProfileService.getReviewsScreen();
      if (mounted) {
        setState(() {
          _reviews = data.reviews;
          _accountPerReview = data.accountPerReview;
          _matchTeamsStringPerReview = data.matchTeamsStringPerReview;
          _isLoading = false;
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToLoadReviews(e.toString()))),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onReviewCommitted(double reviewId) {
    setState(() {
      _reviews.removeWhere((r) => r.id == reviewId);
      if (_currentPage >= _reviews.length && _currentPage > 0) {
        _currentPage = _reviews.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        appBar: _buildAppBar(0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: _buildAppBar(_reviews.length),
      body: _reviews.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                _buildInfoBox(),
                _buildPageIndicator(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _reviews.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return ReviewWidget(
                        review: review,
                        reviewed: _accountPerReview[review.id],
                        matchTeamsString:
                            _matchTeamsStringPerReview[review.id],
                        onCommitted: () => _onReviewCommitted(review.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  AppBar _buildAppBar(int count) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: ATLColors.darkBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            l10n.reviewsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            l10n.pendingCount(count),
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildInfoBox() {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.reviewInfoText,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _reviews.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _currentPage ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentPage
                  ? ATLColors.darkBlue
                  : ATLColors.darkBlue.withOpacity(0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: ATLColors.subtext.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.allCaughtUp,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noPendingReviews,
            style: TextStyle(color: ATLColors.subtext, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
