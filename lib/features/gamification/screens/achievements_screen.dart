import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/gamification/models/achievement_model.dart';
import 'package:prahar/features/gamification/data/achievement_definitions.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/gamification_providers.dart';

// Reuse GridPainter class
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!.withOpacity(0.5)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Achievements Screen - Hall of Fame / Honors & Medals
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangeProvider).value;
    final unlockedIdsAsync = ref.watch(unlockedAchievementsProvider(user?.uid ?? ''));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      body: Stack(
        children: [
            // Grid Background
           Positioned.fill(
             child: CustomPaint(
               painter: GridPainter(),
             ),
           ),
           SafeArea(
             child: Column(
               children: [
                 _buildHeader(context),
                 Expanded(
                   child: unlockedIdsAsync.when(
                     data: (unlockedIds) {
                       final allAchievements = AchievementDefinitions.getAllAchievements();
                       final achievementsWithStatus = allAchievements.map((def) {
                         final isUnlocked = unlockedIds.contains(def.id);
                         return def.copyWith(
                           isUnlocked: isUnlocked,
                           unlockedAt: isUnlocked ? DateTime.now() : null,
                         );
                       }).toList();
  
                       final unlockedCount = achievementsWithStatus.where((a) => a.isUnlocked).length;
                       final totalCount = achievementsWithStatus.length;
  
                       // Split by category for the layout
                       final studyHonors = achievementsWithStatus.where((a) => a.category == AchievementCategory.study).toList();
                       final fitnessMedals = achievementsWithStatus.where((a) => a.category == AchievementCategory.fitness).toList();
                       final otherMedals = achievementsWithStatus.where((a) => a.category != AchievementCategory.study && a.category != AchievementCategory.fitness).toList();
  
                       return SingleChildScrollView(
                         padding: const EdgeInsets.symmetric(horizontal: 16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const SizedBox(height: 16),
                             // Progress Card
                             _buildSummaryCard(unlockedCount, totalCount),
                             const SizedBox(height: 32),
  
                             // Study Honors (Grid)
                             if (studyHonors.isNotEmpty) ...[
                               _buildSectionHeader(Icons.school, 'STUDY HONORS'),
                               const SizedBox(height: 16),
                               GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.8, // Taller for label
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: studyHonors.length,
                                  itemBuilder: (context, index) {
                                     return _buildHonorCard(context, studyHonors[index]);
                                  },
                               )
                             ],
  
                             const SizedBox(height: 32),
  
                             // Fitness Medals (List)
                             if (fitnessMedals.isNotEmpty) ...[
                               _buildSectionHeader(Icons.fitness_center, 'FITNESS MEDALS'),
                               const SizedBox(height: 16),
                               ...fitnessMedals.map((achievement) => _buildMedalListTile(context, achievement)),
                             ],
  
                             const SizedBox(height: 32),
                             
                              // Other Categories (Grid or List based on preference, using Grid for compactness)
                             if (otherMedals.isNotEmpty) ...[
                               _buildSectionHeader(Icons.military_tech, 'GENERAL DECORATIONS'),
                               const SizedBox(height: 16),
                               GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.8,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: otherMedals.length,
                                  itemBuilder: (context, index) {
                                     return _buildHonorCard(context, otherMedals[index]);
                                  },
                               )
                             ],
                             const SizedBox(height: 48),
                           ],
                         ),
                       );
                     },
                     loading: () => Center(child: CircularProgressIndicator(color: kCommandGold)),
                     error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // If pushed from navigation, we might not need back button if it's a main tab, 
          // but wireframe shows arrow. Assuming it can be navigated to.
           IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
              onPressed: () {
                // Check if can pop, otherwise do nothing (or show drawer if we were using one)
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
           ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HALL OF FAME',
                style: GoogleFonts.oswald(
                  fontSize: 10,
                  color: kCommandGold,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'HONORS & MEDALS',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 20,
                  color: const Color(0xFF1E232C),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E232C)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int unlocked, int total) {
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // Dark Navy/Black
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'COLLECTION PROGRESS',
                style: GoogleFonts.oswald(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kCommandGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                 child: Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.oswald(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                 ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$unlocked ',
                  style: GoogleFonts.blackOpsOne(
                    color: kCommandGold,
                    fontSize: 36,
                  ),
                ),
                TextSpan(
                  text: '/ $total',
                  style: GoogleFonts.blackOpsOne(
                    color: Colors.grey[600],
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              color: kCommandGold,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
             'NEXT MILESTONE: ${unlocked + 1} MEDALS', // Dummy logic for milestone
             style: GoogleFonts.lato(
               color: Colors.grey[500],
               fontSize: 12,
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: kCommandGold, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.blackOpsOne(
            fontSize: 18,
            color: const Color(0xFF1E232C),
          ),
        ),
      ],
    );
  }

  IconData _getAchievementIcon(String id) {
    switch (id) {
      // Study
      case 'study_newbie': return Icons.school;
      case 'study_10h': return Icons.timer_outlined;
      case 'study_50h': return Icons.track_changes;
      case 'study_100h': return Icons.auto_stories;
      case 'early_bird': return Icons.wb_sunny;
      case 'night_owl': return Icons.nights_stay;
      
      // Fitness
      case 'first_workout': return Icons.directions_run;
      case 'fitness_10': return Icons.fitness_center;
      case 'ssb_ready': return Icons.military_tech;
      
      // Challenges
      case 'first_challenge': return Icons.flag;
      case 'challenge_7day': return Icons.local_fire_department;
      case 'challenge_30day': return Icons.workspace_premium;
      
      // Streaks
      case 'streak_3': return Icons.electric_bolt;
      case 'streak_7': return Icons.calendar_view_week;
      case 'streak_30': return Icons.calendar_month;
      case 'streak_100': return Icons.verified;
      
      // Levels
      case 'level_5': return Icons.star_outline;
      case 'level_10': return Icons.star_half;
      case 'level_25': return Icons.star;
      case 'level_50': return Icons.stars;
      
      // Habits
      case 'habit_streak_7': return Icons.repeat;
      case 'habit_streak_30': return Icons.loop;
      
      // Special
      case 'perfect_week': return Icons.check_circle_outline;
      
      default: return Icons.emoji_events;
    }
  }

  // Grid style card (Study Honors)
  Widget _buildHonorCard(BuildContext context, Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final iconData = _getAchievementIcon(achievement.id);
    
    return GestureDetector(
      onTap: () => _showAchievementDetails(context, achievement),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? Colors.transparent : kCommandGold.withOpacity(0.3),
            width: isLocked ? 0 : 2
          ),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset:const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50, 
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLocked 
                    ? LinearGradient(colors: [Colors.grey[200]!, Colors.grey[300]!])
                    : AppGradients.goldAccent, // Use gold gradient if unlocked
              ),
              child: Center(
                child: Icon(
                  iconData, // Use mapped icon
                  color: isLocked ? Colors.grey[400] : const Color(0xFF5D4037), // Dark brown/gold icon
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                achievement.name, // Show name even if locked
                 textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                   fontWeight: FontWeight.bold,
                   fontSize: 12,
                   color: isLocked ? Colors.grey[400] : const Color(0xFF1E232C),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
             const SizedBox(height: 4),
             Text(
               isLocked ? 'LOCKED' : achievement.getRarityName().toUpperCase(),
                style: GoogleFonts.oswald(
                  fontSize: 10,
                  color: isLocked ? Colors.grey[400] : kCommandGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
             )
          ],
        ),
      ),
    );
  }

  // List style card (Fitness Medals)
  Widget _buildMedalListTile(BuildContext context, Achievement achievement) {
    final isLocked = !achievement.isUnlocked;
    final iconData = _getAchievementIcon(achievement.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset:const Offset(0, 2)),
         ],
         // Side border accent for unlocked
         border: Border(
           left: isLocked ? BorderSide.none : BorderSide(color: kCommandGold, width: 4),
         )
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: isLocked ? Colors.grey[100] : const Color(0xFFFFF8E1),
               shape: BoxShape.circle,
             ),
             child: Icon(
               iconData,
               color: isLocked ? Colors.grey[400] : kCommandGold,
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Expanded(
                       child: Text(
                         achievement.name,
                         style: GoogleFonts.lato(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: isLocked ? Colors.grey[500] : const Color(0xFF1E232C),
                         ),
                       ),
                     ),
                     if (!isLocked)
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: Colors.grey[100],
                           borderRadius: BorderRadius.circular(4),
                           border: Border.all(color: Colors.grey[300]!),
                         ),
                         child: Text(
                           achievement.tag,
                           style: GoogleFonts.oswald(
                             fontSize: 8,
                             fontWeight: FontWeight.bold,
                             color: Colors.grey[600],
                           ),
                         ),
                       ),
                   ],
                 ),
                 const SizedBox(height: 4),
                 if (!isLocked) ...[
                    Text(
                     achievement.description,
                     style: GoogleFonts.lato(
                       fontSize: 12,
                       color: Colors.grey[600],
                     ),
                   ),
                 ] else 
                  Text(
                   'Unlock: ${achievement.criteria}',
                   style: GoogleFonts.lato(
                     fontSize: 12,
                     color: Colors.grey[400],
                     fontStyle: FontStyle.italic,
                   ),
                 )
               ],
             ),
           ),
           if (!isLocked) ...[
             const SizedBox(width: 8),
             Icon(Icons.check_circle, color: kMilitaryGreen, size: 16),
           ]
        ],
      ),
    );
  }
  
  void _showAchievementDetails(BuildContext context, Achievement achievement) {
     final isLocked = !achievement.isUnlocked;
     final iconData = _getAchievementIcon(achievement.id);
     
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Colors.white,
         title: Row(
           children: [
             Icon(iconData, color: isLocked ? Colors.grey : kCommandGold),
             const SizedBox(width: 12),
             Expanded(child: Text(achievement.name, style: GoogleFonts.blackOpsOne(fontSize: 18, color: const Color(0xFF1E232C)))),
           ],
         ),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(achievement.description, style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[800])),
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.grey[50],
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey[200]!),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('MISSION CRITERIA', style: GoogleFonts.oswald(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   Text(achievement.criteria, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E232C))),
                 ],
               ),
             ),
             const SizedBox(height: 16),
             Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(color: kCommandGold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                     child: Text('+${achievement.xpReward} XP', style: GoogleFonts.oswald(color: kCommandGold, fontWeight: FontWeight.bold)),
                   ),
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                     child: Text(achievement.getRarityName(), style: GoogleFonts.oswald(color: Colors.blue, fontWeight: FontWeight.bold)),
                   ),
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                     child: Text(achievement.tag, style: GoogleFonts.oswald(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                   ),
                ],
             )
           ],
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: Text('CLOSE', style: TextStyle(color: kCommandGold)))
         ],
       )
     );
  }
}

// Extension to map strings or category to icons safely
extension AchievementIconX on Achievement {
  IconData getIconData() {
    // Basic mapping, could be more extensive
    if (icon.length == 1) {
       // If it's an emoji, we can't easily turn it into IconData without a parser or just rendering text.
       // But the new UI uses Icon widgets. 
       // Current assumption: The 'icon' field in Achievement is a String emoji. 
       // The Code above uses Icon(achievement.icon) which is wrong if it's a string emoji.
       // Let's fallback to category icon.
       return _getCategoryIcon(category);
    }
    return _getCategoryIcon(category);
  }
  
  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.study: return Icons.school;
      case AchievementCategory.fitness: return Icons.directions_run;
      case AchievementCategory.challenges: return Icons.emoji_events;
      case AchievementCategory.streaks: return Icons.local_fire_department;
      case AchievementCategory.mastery: return Icons.psychology;
      case AchievementCategory.general: return Icons.military_tech;
    }
  }
}

