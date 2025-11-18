import 'package:flutter/material.dart';
import '../../utils/atl_colors.dart';
import 'package:atl_app/models/sport_category.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

class RefereeHomeScreen extends StatefulWidget {
  final SportCategory currentSport;

  const RefereeHomeScreen({
    super.key,
    required this.currentSport,
  });

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  late final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  late final User user = userProvider.activeUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'REFEREE HOME',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode - Coming soon')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.dark_mode,
                color: ATLColors.darkBlue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: _buildRefereeHomeContent(),
    );
  }

  Widget _buildRefereeHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card info utente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ATLColors.darkBlue.withOpacity(0.2),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: ATLColors.darkBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.roleDisplayName,
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Upcoming assignments
          Text(
            'UPCOMING ASSIGNMENTS',
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.event_note,
                  color: ATLColors.darkBlue,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No assignments yet',
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You will be notified when assigned to a match',
                  style: TextStyle(
                    color: ATLColors.title,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats
          Text(
            'YOUR STATS',
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Matches', '0', Icons.sports_score),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Rating', '-', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: ATLColors.darkBlue,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
