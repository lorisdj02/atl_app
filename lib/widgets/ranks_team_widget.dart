import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import 'abstract_team_widget.dart';

/// Widget per visualizzare un team nella pagina dei ranks
class RanksTeamWidget extends AbstractTeamWidget {
  final Color color;
  final int? rankPts;
  final String? captainName;
  final int rank;

  const RanksTeamWidget({
    super.key,
    required super.team,
    this.color = Colors.white,
    super.imageUrl,
    this.rankPts,
    this.captainName,
    required super.sportCategory,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTop3 = rank <= 3;
    final accent = color; // il colore passato dallo screen (primary/secondary/tertiary)

    // Calcola un colore di testo più scuro e leggibile partendo dall'accent
    final accentHsl = HSLColor.fromColor(accent);
    final double darkLightness = (accentHsl.lightness * 0.25).clamp(0.0, 1.0) as double;
    final Color rankTextColor = isTop3 ? accentHsl.withLightness(darkLightness).toColor() : Colors.grey.shade700;

    return GestureDetector(
      onTap: () => handleTeamTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            // sottile striscia colorata per i top3 (altrimenti spazio vuoto)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isTop3 ? 6 : 6,
              height: 64,
              decoration: BoxDecoration(
                color: isTop3 ? accent : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // card principale bianca (semplice, leggibile)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // rank piccolo e discreto
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isTop3 ? accent.withOpacity(0.14) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: rankTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // logo / avatar compatto (usa abstract widget)
                    buildTeamLogo(size: 44),

                    const SizedBox(width: 10),

                    // info testuali
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Captain: ${captainName ?? '—'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // badge punti compatto
                    if (rankPts != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${rankPts} pts', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
