import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_type.dart';
import '../../models/user_info.dart';
import '../../utils/atl_colors.dart';
import '../shop_screen.dart';
import '../tournaments_screen.dart';
import '../team_screen.dart';
import '../profile_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  final UserInfo userInfo;

  const PlayerHomeScreen({
    super.key,
    required this.userInfo,
  });

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  SportType _currentSport = SportType.football;

  void _onNavTap(int index) {
    if (index == 4) {
      // Mostra dialog per cambiare sport
      _showSportSelector();
    } else {
      // Naviga alle rispettive pagine
      Widget screen;
      switch (index) {
        case 0:
          screen = ShopScreen(
            currentSport: _currentSport,
            userInfo: widget.userInfo,
          );
          break;
        case 1:
          screen = TournamentsScreen(
            currentSport: _currentSport,
            userInfo: widget.userInfo,
          );
          break;
        case 2:
          screen = TeamScreen(
            currentSport: _currentSport,
            userInfo: widget.userInfo,
          );
          break;
        case 3:
          screen = ProfileScreen(
            currentSport: _currentSport,
            userInfo: widget.userInfo,
          );
          break;
        default:
          return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  void _showSportSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Sport'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SportType.values.map((sport) {
            return ListTile(
              leading: Icon(
                sport.icon,
                color: sport.primaryColor,
              ),
              title: Text(sport.name),
              trailing: _currentSport == sport
                  ? Icon(Icons.check, color: sport.primaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _currentSport = sport;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: () {
            // TODO: Implementare prenotazione campo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book a field - Coming soon')),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stadium, color: Colors.white, size: 18),
                SizedBox(height: 2),
                Text(
                  'Book a field',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'HOME',
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
              // TODO: Implementare dark mode
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
      body: _buildPlayerHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildPlayerHomeContent() {
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
                  backgroundColor: _currentSport.primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: _currentSport.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userInfo.username,
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userInfo.roleDisplayName,
                        style: TextStyle(
                          color: _currentSport.primaryColor,
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
          
          // Titolo con sport corrente
          Row(
            children: [
              Icon(
                _currentSport.icon,
                color: _currentSport.primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'NEXT MATCH',
                style: TextStyle(
                  color: ATLColors.subtext,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Card per il prossimo match
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
                Icon(
                  _currentSport.icon,
                  color: _currentSport.primaryColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No matches scheduled',
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join a tournament to start playing!',
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
          
          // Sezione statistiche
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
                child: _buildStatCard('Matches', '0', Icons.sports_soccer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Wins', '0', Icons.emoji_events),
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
            color: _currentSport.primaryColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
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
