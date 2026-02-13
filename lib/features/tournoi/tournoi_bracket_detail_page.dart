import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/anime_controller.dart';

class TournamentBracketDetailPage extends StatelessWidget {
  final Map<String, dynamic> tournamentEntry;

  const TournamentBracketDetailPage({
    super.key,
    required this.tournamentEntry,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF17171F) : const Color(0xFFF2E8D5);
    final cardColor = isDark ? const Color(0xFF252836) : const Color(0xFFFAF6ED);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final bracketStr = tournamentEntry['bracketData'] as String? ?? '';
    final bracketData = controller.parseBracketData(bracketStr);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    "Bracket",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Winner banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.withOpacity(0.3), Colors.orange.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tournamentEntry['winnerTitle'] ?? 'Inconnu',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      tournamentEntry['winnerImage'] ?? '',
                      width: 40,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.image, size: 20, color: Colors.white54),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bracket visualization
            Expanded(
              child: bracketData.isEmpty
                  ? Center(
                      child: Text(
                        "Données du bracket non disponibles",
                        style: TextStyle(color: subtitleColor),
                      ),
                    )
                  : InteractiveViewer(
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(500), // Large margin for free movement
                      minScale: 0.01,
                      maxScale: 5.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBracketTree(bracketData, cardColor, textColor, isDark),
                      ),
                    ),
            ),

            // Date footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Tournoi du ${tournamentEntry['date'] ?? '?'}",
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketTree(
    List<List<String>> bracketData,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    // Parse participants from bracket data
    // bracketData[0] = 8 quart-finalists
    // bracketData[1] = 4 semi-finalists (winners of quarts)
    // bracketData[2] = 2 finalists
    // bracketData[3] = 1 winner

    if (bracketData.isEmpty) return const SizedBox();

    final List<Map<String, String>> quarts = bracketData.isNotEmpty ? _parseParticipants(bracketData[0]) : [];
    final List<Map<String, String>> semis = bracketData.length > 1 ? _parseParticipants(bracketData[1]) : [];
    final List<Map<String, String>> finales = bracketData.length > 2 ? _parseParticipants(bracketData[2]) : [];
    final List<Map<String, String>> winner = bracketData.length > 3 ? _parseParticipants(bracketData[3]) : [];

    final lineColor = isDark ? Colors.grey[600]! : Colors.grey[400]!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Quarts de finale (4 matchs)
        _buildRound(
          "Quarts",
          Colors.redAccent,
          _buildMatchups(quarts, semis, cardColor, textColor, lineColor),
          cardColor,
        ),
        
        _buildConnectors(4, lineColor),
        
        // Demi-finales (2 matchs)
        _buildRound(
          "Demis",
          Colors.orangeAccent,
          _buildMatchups(semis, finales, cardColor, textColor, lineColor),
          cardColor,
        ),
        
        _buildConnectors(2, lineColor),
        
        // Finale (1 match)
        _buildRound(
          "Finale",
          const Color(0xFF6A5ACD),
          _buildMatchups(finales, winner, cardColor, textColor, lineColor),
          cardColor,
        ),
        
        _buildConnectors(1, lineColor),
        
        // Gagnant
        _buildWinnerColumn(winner, cardColor, textColor),
      ],
    );
  }

  List<Map<String, String>> _parseParticipants(List<String> data) {
    return data.map((str) {
      final parts = str.split('|');
      return {
        'title': parts.isNotEmpty ? parts[0] : '?',
        'image': parts.length > 1 ? parts[1] : '',
      };
    }).toList();
  }

  Widget _buildRound(String title, Color color, Widget matchups, Color cardColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        matchups,
      ],
    );
  }

  Widget _buildMatchups(
    List<Map<String, String>> participants,
    List<Map<String, String>> winners,
    Color cardColor,
    Color textColor,
    Color lineColor,
  ) {
    final matchups = <Widget>[];
    
    for (int i = 0; i < participants.length; i += 2) {
      if (i + 1 < participants.length) {
        final p1 = participants[i];
        final p2 = participants[i + 1];
        
        // Determine winner of this matchup
        final winnerIndex = i ~/ 2;
        final matchWinner = winnerIndex < winners.length ? winners[winnerIndex] : null;
        
        matchups.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMatchup(p1, p2, matchWinner, cardColor, textColor, lineColor),
          ),
        );
      }
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: matchups,
    );
  }

  Widget _buildMatchup(
    Map<String, String> p1,
    Map<String, String> p2,
    Map<String, String>? winner,
    Color cardColor,
    Color textColor,
    Color lineColor,
  ) {
    final isP1Winner = winner != null && winner['title'] == p1['title'];
    final isP2Winner = winner != null && winner['title'] == p2['title'];

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lineColor.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player 1
          _buildParticipantRow(p1, isP1Winner, textColor, true),
          
          // VS divider
          Container(
            height: 1,
            color: lineColor.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                color: cardColor,
                child: Text(
                  "VS",
                  style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Player 2
          _buildParticipantRow(p2, isP2Winner, textColor, false),
        ],
      ),
    );
  }

  Widget _buildParticipantRow(
    Map<String, String> participant,
    bool isWinner,
    Color textColor,
    bool isTop,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green.withOpacity(0.15) : null,
        borderRadius: BorderRadius.vertical(
          top: isTop ? const Radius.circular(9) : Radius.zero,
          bottom: isTop ? Radius.zero : const Radius.circular(9),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              participant['image'] ?? '',
              width: 28,
              height: 35,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 28,
                height: 35,
                color: Colors.grey[400],
                child: const Icon(Icons.image, size: 14, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              participant['title'] ?? '?',
              style: TextStyle(
                color: textColor,
                fontSize: 8,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isWinner)
            const Icon(Icons.check_circle, color: Colors.green, size: 12),
        ],
      ),
    );
  }

  Widget _buildConnectors(int count, Color lineColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) => Padding(
          padding: EdgeInsets.only(bottom: i < count - 1 ? 60 : 0),
          child: Container(
            width: 20,
            height: 2,
            color: lineColor,
          ),
        )),
      ),
    );
  }

  Widget _buildWinnerColumn(
    List<Map<String, String>> winner,
    Color cardColor,
    Color textColor,
  ) {
    final w = winner.isNotEmpty ? winner[0] : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.amber, size: 12),
              SizedBox(width: 4),
              Text(
                "🏆",
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 70,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  w?['image'] ?? '',
                  width: 50,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50,
                    height: 65,
                    color: Colors.grey,
                    child: const Icon(Icons.emoji_events, color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                w?['title'] ?? '?',
                style: TextStyle(
                  color: textColor,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
