import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/sport_category.dart';
import '../../models/review.dart';
import '../../models/user.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';
import '../../widgets/review_widget.dart';

class ReviewsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const ReviewsScreen({super.key, required this.currentSport});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  List<Review> _reviews = [];
  Map<int, User> _userPerReview = {};
  Map<int, String> _matchTeamsStringPerReview = {};

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.activeUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await DBRead.getReviewsScreen(user.id);
      if (mounted) {
        setState(() {
          _reviews = data[ApiJsonKeys.reviews] as List<Review>;
          _userPerReview =
              Map<int, User>.from(data[ApiJsonKeys.userPerReview]);
          _matchTeamsStringPerReview = Map<int, String>.from(
              data[ApiJsonKeys.matchTeamsStringPerReview]);
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews data: $e')),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onReviewCommitted(int reviewId) {
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
                        reviewee: _userPerReview[review.id],
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
    return AppBar(
      backgroundColor: ATLColors.darkBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            'REVIEWS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            '$count pending',
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
              'By reviewing, you improve the experience for everyone! Choose wisely!\n'
              'Also, to redeem prizes or compensation, you must not have any pending reviews.',
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
          const Text(
            'All caught up!',
            style: TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No pending reviews.',
            style: TextStyle(color: ATLColors.subtext, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
