import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/high_score.dart';
import '../services/high_score_service.dart';
import '../utils/theme_helper.dart';
import '../utils/constants.dart';
import '../widgets/app_card.dart';
import '../widgets/custom_button.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Toutes';
  String _selectedDifficulty = 'Toutes';

  final List<String> _categories = [
    'Toutes',
    'General Knowledge',
    'Science & Nature',
    'Sports',
    'History',
    'Geography',
    'Entertainment',
  ];

  final List<String> _difficulties = [
    'Toutes',
    'easy',
    'medium',
    'hard',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meilleurs Scores'),
        backgroundColor: ThemeHelper.getPrimaryColor(context),
        foregroundColor: ThemeHelper.getOnPrimaryColor(context),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeHelper.getOnPrimaryColor(context),
          unselectedLabelColor: ThemeHelper.getOnPrimaryColor(context).withValues(alpha: 0.7),
          indicatorColor: ThemeHelper.getOnPrimaryColor(context),
          tabs: const [
            Tab(text: 'Tous', icon: Icon(Icons.list)),
            Tab(text: 'Par Catégorie', icon: Icon(Icons.category)),
            Tab(text: 'Par Difficulté', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
            tooltip: 'Réinitialiser les scores',
          ),
        ],
      ),
      body: Consumer<HighScoreService>(
        builder: (context, highScoreService, child) {
          if (!highScoreService.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllScoresTab(highScoreService),
              _buildCategoryTab(highScoreService),
              _buildDifficultyTab(highScoreService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllScoresTab(HighScoreService service) {
    final List<HighScore> allScores = service.getAllHighScores();

    if (allScores.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildStatsCard(service),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: allScores.length,
            itemBuilder: (context, index) {
              final score = allScores[index];
              return _buildScoreCard(score, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(HighScoreService service) {
    return Column(
      children: [
        _buildCategoryFilter(),
        Expanded(
          child: _buildFilteredScores(service, byCategory: true),
        ),
      ],
    );
  }

  Widget _buildDifficultyTab(HighScoreService service) {
    return Column(
      children: [
        _buildDifficultyFilter(),
        Expanded(
          child: _buildFilteredScores(service, byCategory: false),
        ),
      ],
    );
  }

  Widget _buildStatsCard(HighScoreService service) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: AppCard(
        child: Column(
          children: [
            Text(
              'Statistiques',
              style: ThemeHelper.getHeadlineStyle(context),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Records',
                  service.totalRecords.toString(),
                  Icons.emoji_events,
                ),
                _buildStatItem(
                  'Moyenne',
                  '${service.averageScore.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeHelper.getPrimaryColor(context),
          size: AppSizes.iconSize,
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          value,
          style: ThemeHelper.getHeadlineStyle(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: ThemeHelper.getBodyStyle(context).copyWith(
            color: ThemeHelper.getSecondaryColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Filtrer par catégorie',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        items: _categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
      ),
    );
  }

  Widget _buildDifficultyFilter() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: DropdownButtonFormField<String>(
        value: _selectedDifficulty,
        decoration: InputDecoration(
          labelText: 'Filtrer par difficulté',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        items: _difficulties.map((difficulty) {
          return DropdownMenuItem(
            value: difficulty,
            child: Text(_getDifficultyDisplayName(difficulty)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDifficulty = value!;
          });
        },
      ),
    );
  }

  Widget _buildFilteredScores(HighScoreService service, {required bool byCategory}) {
    List<HighScore> scores;
    
    if (byCategory) {
      if (_selectedCategory == 'Toutes') {
        scores = service.getAllHighScores();
      } else {
        scores = service.getHighScoresForCategory(_selectedCategory);
      }
    } else {
      if (_selectedDifficulty == 'Toutes') {
        scores = service.getAllHighScores();
      } else {
        scores = service.getHighScoresForDifficulty(_selectedDifficulty);
      }
    }

    if (scores.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        return _buildScoreCard(score, index + 1);
      },
    );
  }

  Widget _buildScoreCard(HighScore score, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: AppCard(
        child: ListTile(
          leading: _buildRankBadge(rank),
          title: Text(
            score.categoryName,
            style: ThemeHelper.getBodyStyle(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Difficulté: ${_getDifficultyDisplayName(score.difficulty)}'),
              Text('Date: ${_formatDate(score.date)}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.description,
                style: ThemeHelper.getBodyStyle(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score.percentage),
                ),
              ),
              Icon(
                _getScoreIcon(score.percentage),
                color: _getScoreColor(score.percentage),
                size: AppSizes.iconSizeSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData icon;

    if (rank == 1) {
      badgeColor = Colors.amber;
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      badgeColor = Colors.grey[400]!;
      icon = Icons.emoji_events;
    } else if (rank == 3) {
      badgeColor = Colors.brown[400]!;
      icon = Icons.emoji_events;
    } else {
      badgeColor = ThemeHelper.getPrimaryColor(context);
      icon = Icons.star;
    }

    return CircleAvatar(
      backgroundColor: badgeColor,
      radius: 20,
      child: rank <= 3
          ? Icon(icon, color: Colors.white, size: 20)
          : Text(
              rank.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: ThemeHelper.getSecondaryColor(context),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Aucun score enregistré',
            style: ThemeHelper.getHeadlineStyle(context),
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          Text(
            'Jouez à des quiz pour établir vos premiers records !',
            style: ThemeHelper.getBodyStyle(context).copyWith(
              color: ThemeHelper.getSecondaryColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Moyen';
      case 'hard':
        return 'Difficile';
      default:
        return difficulty;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double percentage) {
    if (percentage >= 80) return Icons.star;
    if (percentage >= 60) return Icons.star_half;
    return Icons.star_border;
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les scores'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous les meilleurs scores ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          CustomButton(
            text: 'Réinitialiser',
            onPressed: () {
              context.read<HighScoreService>().resetAllHighScores();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tous les scores ont été réinitialisés'),
                ),
              );
            },
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
