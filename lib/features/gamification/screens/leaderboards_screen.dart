import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/gamification/models/leaderboard_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/gamification_providers.dart';

/// Leaderboards Screen - Rankings across multiple categories
class LeaderboardsScreen extends ConsumerStatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  ConsumerState<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends ConsumerState<LeaderboardsScreen> {
  LeaderboardCategory _selectedCategory = LeaderboardCategory.xp;
  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangeProvider).value;
    
    final leaderboardAsync = ref.watch(leaderboardProvider({
      'category': _selectedCategory,
      'period': _selectedPeriod,
    }));

    return Scaffold(
      backgroundColor: kBackgroundBlack,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LEADERBOARDS',
              style: AppTextStyles.cardTitle.copyWith(
                color: kCommandGold,
                fontSize: 11,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              _selectedCategory.militaryName,
              style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Tabs
          _buildCategoryTabs(),
          
          // Period Selector
          _buildPeriodSelector(),

          // Content
          Expanded(
            child: leaderboardAsync.when(
              data: (leaderboardData) {
                 if (leaderboardData.isEmpty) {
                   return _buildEmptyState();
                 }
                 
                 final currentUserRankEntry = leaderboardData.firstWhere(
                    (e) => e.userId == user?.uid,
                    orElse: () => LeaderboardEntry(userId: '', displayName: '', rank: 0, score: 0),
                 );

                 return Column(
                    children: [
                      // User's Rank Card (if ranked)
                      if (currentUserRankEntry.rank > 0)
                        _buildCurrentUserRankCard(currentUserRankEntry),
                        
                      // Leaderboard List
                      Expanded(
                        child: _buildLeaderboardList(leaderboardData, user?.uid),
                      ),
                    ],
                 );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: kCommandGold)),
              error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: LeaderboardCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.goldAccent : null,
                  color: isSelected ? null : kCardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kCommandGold : kBorderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? Colors.black : kTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () => setState(() => _selectedPeriod = period),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected ? kCommandGold.withOpacity(0.2) : null,
                  side: BorderSide(
                    color: isSelected ? kCommandGold : kBorderSubtle,
                  ),
                ),
                child: Text(
                  period.displayName,
                  style: TextStyle(
                    color: isSelected ? kCommandGold : kTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentUserRankCard(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCommandGold, width: 2),
      ),
      child: Row(
        children: [
          _buildRankBadge(entry.rank, isCurrentUser: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR RANK',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: kCommandGold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  entry.displayName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: AppTextStyles.countdown.copyWith(fontSize: 24),
              ),
              Text(
                _selectedCategory.unit,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries, String? currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrentUser = entry.userId == currentUserId;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isCurrentUser ? AppGradients.darkCard : null,
              color: isCurrentUser ? null : kCardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentUser ? kCommandGold : kBorderSubtle,
                width: isCurrentUser ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildRankBadge(entry.rank, isCurrentUser: isCurrentUser),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.displayName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? kCommandGold : kTextPrimary,
                        ),
                      ),
                      if (entry.level != null)
                        Text(
                          'Level ${entry.level}',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.score}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? kCommandGold : kTextPrimary,
                      ),
                    ),
                    Text(
                      _selectedCategory.unit,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank, {bool isCurrentUser = false}) {
    Color badgeColor;
    String badgeText = '#$rank';

    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      badgeText = '🥇';
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      badgeText = '🥈';
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
      badgeText = '🥉';
    } else if (isCurrentUser) {
      badgeColor = kCommandGold;
    } else {
      badgeColor = kCardElevated;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(rank <= 3 ? 0.2 : 1),
        shape: BoxShape.circle,
        border: Border.all(
          color: rank <= 3 ? badgeColor : kBorderSubtle,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          badgeText,
          style: TextStyle(
            fontSize: rank <= 3 ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: rank <= 3 ? badgeColor : (isCurrentUser ? kCommandGold : kTextPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: kTextDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No Rankings Yet',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete challenges and workouts\nto appear on the leaderboard',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
