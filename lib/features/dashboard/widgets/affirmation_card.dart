import 'dart:math';
import 'package:flutter/material.dart';
import 'package:prahar/core/data/mahabharat_quotes.dart';
import 'package:prahar/core/theme/theme.dart';

class AffirmationCard extends StatelessWidget {
  const AffirmationCard({super.key});

  String _getQuoteOfTheDay() {
    // This logic ensures the quote changes once per day
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % mahabharatQuotes.length;
    return mahabharatQuotes[quoteIndex];
  }

  @override
  Widget build(BuildContext context) {
    final quote = _getQuoteOfTheDay();

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
              '"$quote"',
              style: AppTextStyles.quotation,
            ),
          ],
        ),
      ),
    );
  }
}