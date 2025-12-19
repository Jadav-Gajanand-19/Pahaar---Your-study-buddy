// Revision Date Display Updates for prep_screen.dart
// Due to whitespace matching issues, here are the exact changes needed:

// ==================================================================
// CHANGE 1: Update Last Revised Section (around line 515-532)
// ==================================================================
// FIND this section:
/*
                            // Last Revised Date
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Last Revised: ${DateFormat('MMM d, yyyy').format(lastRevised)}',
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
*/

// REPLACE WITH:
/*
                            // Last Revised Date and Next Due Date
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                                      const SizedBox(width: 6),
                                      Text(
                                       'Last Revised: ${DateFormat('MMM d, yyyy').format(lastRevised)}',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        (isOverdue || isDueToday) ? Icons.alarm : Icons.lock_clock,
                                        size: 14,
                                        color: (isOverdue || isDueToday) ? Colors.orange[600] : Colors.grey[400],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (isOverdue || isDueToday) 
                                          ? 'Ready to revise today!'
                                          : 'Unlocks on: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          color: (isOverdue || isDueToday) ? Colors.orange[700] : Colors.grey[500],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
*/

// ==================================================================
// CHANGE 2: Update Success Message (around line 583-594)
// ==================================================================
// FIND:
/*
                                            // Show success message with next revision date
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '✅ Revised! Next revision: ${DateFormat('MMM d, yyyy').format(newDueDate)}',
                                                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                  ),
                                                  backgroundColor: const Color(0xFF2E7D32),
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
*/

// REPLACE WITH:
/*
                                            // Show success message with today's date and next revision date
                                            if (context.mounted) {
                                              final todayFormatted = DateFormat('MMM d, yyyy').format(DateTime.now());
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '✅ Revised today ($todayFormatted)! Next revision: ${DateFormat('MMM d, yyyy').format(newDueDate)}',
                                                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                                  ),
                                                  backgroundColor: const Color(0xFF2E7D32),
                                                  duration: const Duration(seconds: 3),
                                                ),
                                              );
*/

// ==================================================================
// CHANGE 3: Update Button Text (around line 628-636)
// ==================================================================
// FIND:
/*
                                             Text(
                                               (isOverdue || isDueToday) ? 'REVISED TODAY' : 'LOCKED',
                                               style: GoogleFonts.blackOpsOne(
                                                 fontSize: 12,
                                                 fontWeight: FontWeight.bold,
                                                 color: (isOverdue || isDueToday) ? Colors.white : Colors.grey[600],
                                                 letterSpacing: 0.5,
                                               ),
                                             ),
*/

// REPLACE WITH:
/*
                                             Text(
                                               (isOverdue || isDueToday) 
                                                 ? 'REVISE TODAY (${DateFormat('MMM d').format(DateTime.now())})' 
                                                 : 'LOCKED',
                                               style: GoogleFonts.blackOpsOne(
                                                 fontSize: 11,
                                                 fontWeight: FontWeight.bold,
                                                 color: (isOverdue || isDueToday) ? Colors.white : Colors.grey[600],
                                                 letterSpacing: 0.5,
                                               ),
                                             ),
*/

// ==================================================================
// Summary of Changes:
// ==================================================================
// 1. Changed Last Revised section from Row to Column to show both:
//    - Last revised date
//    - Next unlock date (or "Ready to revise today!" if due)
// 
// 2. Updated success SnackBar message to include today's date:
//    "✅ Revised today (Dec 17, 2025)! Next revision: Jan 14, 2026"
//
// 3. Updated button text from "REVISED TODAY" to "REVISE TODAY (Dec 17)"
//    to show the current date when revision is available
