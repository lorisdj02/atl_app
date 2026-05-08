import 'package:atl_app/database/responses/has_notifications_response.dart';
import 'package:atl_app/database/services/account_service.dart';
import 'package:atl_app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';

class BottomBarItem {
  final IconData icon;
  final String label;
  final int index;

  const BottomBarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

/// Bottom navigation bar centralizzata per tutti i ruoli.
/// Gestisce autonomamente il polling delle notifiche (pallino rosso su "Me").
class ATLBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final SportCategory currentSport;
  final bool isHome;

  /// Item a sinistra del FAB (di solito 1-2 voci)
  final List<BottomBarItem> leftItems;

  /// Item a destra del FAB (di solito 1-2 voci, l'ultimo deve avere index == 3 per "Me")
  final List<BottomBarItem> rightItems;

  /// ID dell'utente loggato, usato per verificare notifiche non lette.
  /// Se null (es. utente guest) la verifica viene saltata.
  final double? accountId;

  const ATLBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.currentSport,
    required this.leftItems,
    required this.rightItems,
    this.accountId,
    this.isHome = false,
  });

  @override
  State<ATLBottomBar> createState() => _ATLBottomBarState();
}

class _ATLBottomBarState extends State<ATLBottomBar> {
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    if (widget.accountId == null) return;
    final AccountProvider accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );
    try {
      final HasNotificationsResponse result =
          await AccountService.hasNotifications();
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = result.hasUnreadNotifications;
          accountProvider.setVipStatus(result.isVip);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ATLColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra con le icone
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...widget.leftItems.map(_buildNavItem),
                const SizedBox(width: 70), // spazio per il FAB
                ...widget.rightItems.map(_buildNavItem),
              ],
            ),
          ),

          // FAB centrale
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ATLColors.darkBlue,
                boxShadow: [
                  BoxShadow(
                    color: ATLColors.darkBlue.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onTap(4),
                  customBorder: const CircleBorder(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isHome ? widget.currentSport.icon : Icons.home,
                        color: ATLColors.getPrimaryColor(widget.currentSport),
                        size: 32,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isHome
                            ? widget.currentSport.name
                            : AppLocalizations.of(context).home,
                        style: TextStyle(
                          color: ATLColors.getPrimaryColor(widget.currentSport),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BottomBarItem item) {
    final isSelected = widget.currentIndex == item.index;
    final color = isSelected ? ATLColors.darkBlue : Colors.grey;
    final showBadge = item.index == 3 && _hasUnreadNotifications;

    return GestureDetector(
      onTap: () => widget.onTap(item.index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon, color: color, size: 28),
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
