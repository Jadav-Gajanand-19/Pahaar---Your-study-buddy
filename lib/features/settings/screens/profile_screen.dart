import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/auth_providers.dart';
import 'package:prahar/providers/settings_providers.dart';
import 'package:prahar/providers/firestore_providers.dart';

/// Profile Screen - Edit user profile information
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(userSettingsProvider);
    final user = ref.watch(authStateChangeProvider).value;

    return Scaffold(
      backgroundColor: kLightBackground,
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: AppTextStyles.commandTitle.copyWith(fontSize: 18),
        ),
        backgroundColor: kCommandGold,
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (_displayNameController.text.isEmpty && settings != null) {
            _displayNameController.text = settings.displayName;
          }
          return _buildProfileForm(context, settings, user?.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, dynamic settings, String? userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: kCommandGold,
                    child: Text(
                      settings?.displayName?.substring(0, 1).toUpperCase() ?? 'C',
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kCommandGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {
                          // TODO: Implement photo upload
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Photo upload coming soon!')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Display Name Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DISPLAY NAME',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person, color: kCommandGold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kCommandGold, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Email (Read-only)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMAIL',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: settings?.email ?? '',
                    enabled: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: kTextSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderSubtle),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: kBorderSubtle),
                      ),
                      filled: true,
                      fillColor: kLightBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email cannot be changed',
                    style: AppTextStyles.bodySmall.copyWith(color: kTextSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveProfile(userId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kCommandGold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'SAVE CHANGES',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile(String? userId) async {
    if (userId == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(firestoreServiceProvider).updateUserSettings(
        userId,
        {'displayName': _displayNameController.text.trim()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: kStatusActive,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: kStatusPriority,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
