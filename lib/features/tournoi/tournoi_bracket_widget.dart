import 'package:flutter/material.dart';
import '../../models/anime.dart';

class TournamentBracketWidget extends StatelessWidget {
  final List<Anime> initialParticipants;
  final List<List<Anime>> allRounds;
  final List<List<Anime?>> roundWinners;
  final bool isDark;

  const TournamentBracketWidget({
    super.key,
    required this.initialParticipants,
    required this.allRounds,
    required this.roundWinners,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    // Build bracket structure: 8 -> 4 -> 2 -> 1
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Text(
              "ARBRE DU TOURNOI",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tapez n'importe où pour fermer",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            
            // Bracket visualization
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Quarter finals (8 participants -> 4 matches)
                  _buildRoundColumn(
                    "Quarts",
                    _getMatchups(0),
                    cardColor,
                    textColor,
                    Colors.redAccent,
                  ),
                  _buildConnector(isDark),
                  
                  // Semi finals (4 participants -> 2 matches)
                  _buildRoundColumn(
                    "Demis",
                    _getMatchups(1),
                    cardColor,
                    textColor,
                    Colors.orangeAccent,
                  ),
                  _buildConnector(isDark),
                  
                  // Final (2 participants -> 1 match)
                  _buildRoundColumn(
                    "Finale",
                    _getMatchups(2),
                    cardColor,
                    textColor,
                    const Color(0xFF6A5ACD),
                  ),
                  _buildConnector(isDark),
                  
                  // Winner
                  _buildWinnerColumn(cardColor, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<List<Anime?>> _getMatchups(int roundIndex) {
    if (roundIndex >= allRounds.length) {
      // Round hasn't happened yet - show empty slots
      final expectedMatches = 4 >> roundIndex; // 4, 2, 1
      return List.generate(expectedMatches, (_) => [null, null]);
    }
    
    final round = allRounds[roundIndex];
    final matchups = <List<Anime?>>[];
    for (int i = 0; i < round.length; i += 2) {
      if (i + 1 < round.length) {
        matchups.add([round[i], round[i + 1]]);
      }
    }
    return matchups;
  }

  Widget _buildRoundColumn(
    String title,
    List<List<Anime?>> matchups,
    Color cardColor,
    Color textColor,
    Color accentColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Round title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Matchups
        ...matchups.map((matchup) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMatchup(matchup, cardColor, textColor, accentColor),
        )),
      ],
    );
  }

  Widget _buildMatchup(
    List<Anime?> matchup,
    Color cardColor,
    Color textColor,
    Color accentColor,
  ) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildParticipantTile(matchup[0], cardColor, textColor, true),
          Container(
            height: 1,
            color: accentColor.withOpacity(0.3),
          ),
          _buildParticipantTile(matchup[1], cardColor, textColor, false),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(Anime? anime, Color cardColor, Color textColor, bool isTop) {
    final borderRadius = isTop
        ? const BorderRadius.vertical(top: Radius.circular(11))
        : const BorderRadius.vertical(bottom: Radius.circular(11));
    
    if (anime == null) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.5),
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(
            "?",
            style: TextStyle(
              color: textColor.withOpacity(0.3),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: isTop ? const Radius.circular(11) : Radius.zero,
              bottomLeft: isTop ? Radius.zero : const Radius.circular(11),
            ),
            child: Image.asset(
              anime.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: const Icon(Icons.image, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isDark) {
    final lineColor = isDark ? Colors.grey[700] : Colors.grey[400];
    return Container(
      width: 24,
      height: 2,
      color: lineColor,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildWinnerColumn(Color cardColor, Color textColor) {
    // Check if we have a final winner
    Anime? winner;
    if (roundWinners.length >= 3 && roundWinners[2].isNotEmpty && roundWinners[2][0] != null) {
      winner = roundWinners[2][0];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                "Gagnant",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 120,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
          ),
          child: winner != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        winner.image,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Text(
                            winner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.emoji_events_outlined,
                    color: textColor.withOpacity(0.2),
                    size: 40,
                  ),
                ),
        ),
      ],
    );
  }
}
