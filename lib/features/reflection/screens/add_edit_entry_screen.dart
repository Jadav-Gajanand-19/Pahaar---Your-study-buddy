import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prahar/data/models/journal_entry_model.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

class AddEditEntryScreen extends ConsumerStatefulWidget {
  const AddEditEntryScreen({super.key, required this.date});
  final DateTime date;

  @override
  ConsumerState<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends ConsumerState<AddEditEntryScreen> {
  final _gratitudeController = TextEditingController();
  final _lessonController = TextEditingController();
  final _reflectionController = TextEditingController(); // Not in UI but let's keep it if model demands it, or map 'Intel' to gratitude/lesson
  // UI shows "INTEL: GRATEFUL FOR" -> gratitude
  // "TACTICAL ANALYSIS: KEY LESSON" -> keyLesson
  // Model has 'reflection' too. Maybe we can hide it or add it as a third field.
  // Given the image, I'll stick to Gratitude and Lesson as primary.

  String _selectedMood = 'Okay';
  double _energyLevel = 3.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    final entries = await ref.read(journalEntriesStreamProvider.future);
    final normalizedDate = DateFormat('yyyy-MM-dd').format(widget.date);
    
    try {
      final entryForDate = entries.firstWhere((entry) => DateFormat('yyyy-MM-dd').format(entry.date.toDate()) == normalizedDate);
      _gratitudeController.text = entryForDate.gratitude;
      _reflectionController.text = entryForDate.reflection;
      _lessonController.text = entryForDate.keyLesson ?? '';
      _selectedMood = entryForDate.mood;
      _energyLevel = entryForDate.energyLevel;
    } catch (e) {
      // No entry found.
    }
    setState(() => _isLoading = false);
  }
  
  void _saveEntry() {
    final user = ref.read(authStateChangeProvider).value;
    if (user == null) return;
    
    final newEntry = JournalEntry(
      date: Timestamp.fromDate(widget.date),
      mood: _selectedMood,
      energyLevel: _energyLevel,
      gratitude: _gratitudeController.text.trim(),
      reflection: _reflectionController.text.trim(), // Optional if not in UI
      keyLesson: _lessonController.text.trim(),
    );

    ref.read(firestoreServiceProvider).upsertJournalEntry(user.uid, newEntry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                   child: _isLoading
                       ? const Center(child: CircularProgressIndicator())
                       :  SingleChildScrollView(
                           padding: const EdgeInsets.symmetric(horizontal: 16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const SizedBox(height: 24),
                               _buildDateHeader(),
                               const SizedBox(height: 24),
                               _buildOperationalStatus(),
                               const SizedBox(height: 24),
                               _buildBatteryLevel(),
                               const SizedBox(height: 24),
                               _buildTextFieldSection(
                                 icon: Icons.favorite,
                                 label: 'INTEL: GRATEFUL FOR',
                                 hint: 'Identify positive assets encountered today...',
                                 controller: _gratitudeController,
                               ),
                               const SizedBox(height: 24),
                               _buildTextFieldSection(
                                 icon: Icons.lightbulb,
                                 label: 'TACTICAL ANALYSIS: KEY LESSON',
                                 hint: 'One actionable insight or learning...',
                                 controller: _lessonController,
                               ),
                               const SizedBox(height: 48),
                             ],
                           ),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E232C)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW ENTRY',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 20,
                  color: const Color(0xFF1E232C),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'LOG #${DateFormat('yyyy-MM-dd').format(widget.date)} // EDIT MODE',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37), // kCommandGold
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _saveEntry,
              icon: const Icon(Icons.save, size: 20),
              color: Colors.black,
              tooltip: 'Save Entry',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE OF ENTRY',
          style: GoogleFonts.blackOpsOne(
             fontSize: 12, 
             fontWeight: FontWeight.bold, 
             color: const Color(0xFFAFB42B), // Olive Gold
             letterSpacing: 1.5,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('d MMM').format(widget.date).toUpperCase(),
              style: GoogleFonts.blackOpsOne(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E232C),
                height: 1.0,
              ),
            ),
            Text(
              DateFormat('EEEE').format(widget.date),
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], thickness: 1),
      ],
    );
  }

  Widget _buildOperationalStatus() {
    final moods = [
      {'label': 'BAD', 'value': 'Bad', 'icon': Icons.sentiment_dissatisfied},
      {'label': 'OKAY', 'value': 'Okay', 'icon': Icons.sentiment_neutral},
      {'label': 'GOOD', 'value': 'Good', 'icon': Icons.sentiment_satisfied_alt},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, size: 16, color: Color(0xFF556B2F)),
              const SizedBox(width: 8),
              Text(
                'OPERATIONAL STATUS',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((m) {
              final isSelected = _selectedMood == m['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = m['value'] as String),
                child: Container(
                  width: 80, height: 80, // Square cards
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFAFB42B) : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                     children: [
                        if (isSelected)
                          Positioned(
                            top: 4, right: 4,
                            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFAFB42B), shape: BoxShape.circle)),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(m['icon'] as IconData, size: 32, color: isSelected ? const Color(0xFFAFB42B) : Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                m['label'] as String,
                                style: GoogleFonts.blackOpsOne(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? const Color(0xFFAFB42B) : Colors.grey[400],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                     ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryLevel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, size: 16, color: Color(0xFF556B2F)),
                  const SizedBox(width: 8),
                  Text(
                    'BATTERY LEVEL',
                    style: GoogleFonts.blackOpsOne(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Text(
                '${(_energyLevel / 5 * 100).toInt()}%',
                style: GoogleFonts.blackOpsOne(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFAFB42B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.grey[300],
              inactiveTrackColor: Colors.grey[200],
              thumbColor: const Color(0xFFAFB42B),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _energyLevel,
              min: 1, max: 5, divisions: 4,
              onChanged: (val) => setState(() => _energyLevel = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DEPLETED', style: GoogleFonts.blackOpsOne(fontSize: 10, color: Colors.grey[400])),
                Text('COMBAT READY', style: GoogleFonts.blackOpsOne(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection({
    required IconData icon, 
    required String label, 
    required String hint, 
    required TextEditingController controller
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF556B2F)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.blackOpsOne(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
               controller: controller,
               maxLines: 4,
               style: GoogleFonts.lato(color: Colors.grey[800]),
               decoration: InputDecoration(
                 border: InputBorder.none,
                 hintText: hint,
                 hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
               ),
            ),
          ),
      ],
    );
  }
}

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
