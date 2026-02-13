import '../../models/anime.dart';

class TournamentController {
  TournamentController(List<Anime> initial)
      : _currentRound = List.of(initial);

  List<Anime> _currentRound;
  final List<Anime> _winners = [];
  int _index = 0;

  Anime get left => _currentRound[_index];
  Anime get right => _currentRound[_index + 1];

  int get roundSize => _currentRound.length;

  void selectWinner(Anime winner) {
    _winners.add(winner);
    _index += 2;
  }

  /// Retourne true si tournoi terminé
  bool advanceRoundIfNeeded() {
    final roundFinished = _index >= _currentRound.length;
    if (!roundFinished) return false;

    // tournoi fini si on a 1 gagnant final
    if (_winners.length == 1) return true;

    // round suivant
    _currentRound = List.of(_winners);
    _winners.clear();
    _index = 0;
    return false;
  }

  Anime get finalWinner => _currentRound.first;
}
