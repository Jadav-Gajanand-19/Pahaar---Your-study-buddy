import 'package:flutter/material.dart';
import 'package:prahar/core/theme/theme.dart';
import 'dart:math';

/// Premium Daily Intel Card with rotating military quotes
/// Features gold border accent and italic quotation styling
class DailyIntelCard extends StatelessWidget {
  const DailyIntelCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Tactical quotes for CDS aspirants
    final List<String> intelQuotes = [
      "The wise warrior avoids the battle.",
      "Victorious warriors win first and then go to war.",
      "Discipline is the bridge between goals and accomplishment.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      "The harder the battle, the sweeter the victory.",
      "Fortune favors the bold.",
      "It is not the size of the dog in the fight, but the size of the fight in the dog.",
      "Courage is not the absence of fear, but the triumph over it.",
    ];

    final randomQuote = intelQuotes[Random().nextInt(intelQuotes.length)];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kCommandGold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: kCommandGold.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kCommandGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'DAILY INTEL',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: kCommandGold,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"$randomQuote"',
              style: AppTextStyles.quotation,
            ),
          ],
        ),
      ),
    );
  }
}
