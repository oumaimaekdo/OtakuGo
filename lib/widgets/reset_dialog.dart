import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/anime_controller.dart';

/// Dialogue stylé pour confirmer et exécuter le reset avec animations
class ResetDialog extends StatefulWidget {
  final ResetType resetType;

  const ResetDialog({
    super.key,
    this.resetType = ResetType.all,
  });

  @override
  State<ResetDialog> createState() => _ResetDialogState();
}

class _ResetDialogState extends State<ResetDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AnimeController>();
    final isDark = controller.isDarkMode;
    final bgColor = isDark ? const Color(0xFF252836) : const Color(0xFFF2E8D5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final shadowColor = isDark ? Colors.black45 : Colors.black12;

    // Get statistics for context
    final stats = _getStats(controller);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Header with Icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    color: _getThemeColor().withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Icon(
                          _getIcon(),
                          size: 48,
                          color: _getThemeColor(),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    _getTitleText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    _getContentText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),

                // Statistics section
                if (stats.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getThemeColor().withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getThemeColor().withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sera supprimé :',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...stats.map((stat) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: _getThemeColor(),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      stat,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          switch (widget.resetType) {
                            case ResetType.all:
                              await controller.resetAllData();
                              break;
                            case ResetType.favorites:
                              await controller.resetFavorites();
                              break;
                            case ResetType.tierlist:
                              await controller.resetTierList();
                              break;
                            case ResetType.tournament:
                              await controller.clearTournamentHistory();
                              break;
                            case ResetType.genres:
                              await controller.resetGenres();
                              break;
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(_getSnackBarText())),
                                  ],
                                ),
                                backgroundColor: Colors.green[600],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 3),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getThemeColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirmer la réinitialisation',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getStats(AnimeController controller) {
    switch (widget.resetType) {
      case ResetType.all:
        return [
          '${controller.favorites.length} favoris',
          '${controller.tierList.values.fold(0, (sum, list) => sum + list.length)} animes classés',
          '${controller.tournamentHistory.length} tournois',
        ];
      case ResetType.favorites:
        return ['${controller.favorites.length} animes'];
      case ResetType.tierlist:
        return ['${controller.tierList.values.fold(0, (sum, list) => sum + list.length)} animes'];
      case ResetType.tournament:
        return ['${controller.tournamentHistory.length} tournois'];
      case ResetType.genres:
        return ['${controller.shownCount} animes vus'];
    }
  }

  Color _getThemeColor() {
    return switch (widget.resetType) {
      ResetType.all => const Color(0xFFEF4444),
      ResetType.favorites => const Color(0xFFF59E0B),
      ResetType.tierlist => const Color(0xFF3B82F6),
      ResetType.tournament => const Color(0xFF8B5CF6),
      ResetType.genres => const Color(0xFF10B981),
    };
  }

  IconData _getIcon() {
    return switch (widget.resetType) {
      ResetType.all => Icons.refresh_rounded,
      ResetType.favorites => Icons.favorite_border_rounded,
      ResetType.tierlist => Icons.list_alt_rounded,
      ResetType.tournament => Icons.emoji_events_rounded,
      ResetType.genres => Icons.category_rounded,
    };
  }

  String _getTitleText() {
    return switch (widget.resetType) {
      ResetType.all => 'Tout réinitialiser',
      ResetType.favorites => 'Vider les favoris',
      ResetType.tierlist => 'Vider la Tier List',
      ResetType.tournament => 'Effacer l\'historique',
      ResetType.genres => 'Réinitialiser les genres',
    };
  }

  String _getContentText() {
    return switch (widget.resetType) {
      ResetType.all =>
        'Voulez-vous supprimer toutes vos données ? Cela inclut les favoris, la tier list et votre historique.',
      ResetType.favorites =>
        'Voulez-vous supprimer tous les animes de vos favoris ? Cette action est irréversible.',
      ResetType.tierlist =>
        'Voulez-vous vider complètement votre tier list ? Vos animes retourneront dans la liste non classée.',
      ResetType.tournament =>
        'Voulez-vous effacer tout l\'historique des tournois ? Les résultats passés seront définitivement perdus.',
      ResetType.genres =>
        'Voulez-vous remettre à zéro vos préférences de genres ? L\'algorithme de recommandation repartira de zéro sans toucher à vos favoris.',
    };
  }

  String _getSnackBarText() {
    return switch (widget.resetType) {
      ResetType.all => 'L\'application a été remise à zéro',
      ResetType.favorites => 'Tes favoris ont été supprimés',
      ResetType.tierlist => 'Ta tier list a été réinitialisée',
      ResetType.tournament => 'L\'historique des tournois a été effacé',
      ResetType.genres => 'Tes préférences de genres ont été réinitialisées',
    };
  }
}

enum ResetType { all, favorites, tierlist, tournament, genres }
