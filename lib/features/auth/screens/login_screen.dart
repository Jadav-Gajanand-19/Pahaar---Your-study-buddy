import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _stayLoggedIn = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    // Trim input values
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: kStatusPriority,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email: email,
            password: password,
          );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up first or use "ENLIST NOW" below.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again or use "LOST COMMS?" to reset.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please check and try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please check your credentials or sign up first using "ENLIST NOW".';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message ?? e.code}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: kStatusPriority,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in: ${e.toString()}'),
            backgroundColor: kStatusPriority,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await ref.read(authServiceProvider).signInWithGoogle();
      if (result == null && mounted) {
        // User canceled
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in canceled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign in with Google: ${e.toString()}'),
            backgroundColor: kStatusPriority,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Shield Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kCommandGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kCommandGold.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield, size: 50, color: Colors.white),
                      SizedBox(height: 4),
                      Icon(Icons.star, size: 16, color: Colors.white),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDot(kStatusWarning),
                    const SizedBox(width: 6),
                    _buildDot(kMilitaryGreen),
                    const SizedBox(width: 6),
                    _buildDot(kStatusPending),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // App Name
                Text(
                  'PRAHAAR',
                  style: GoogleFonts.rajdhani(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: kTextDarkPrimary,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Tagline with decorative lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, kCommandGold],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'MISSION READY',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kCommandGold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kCommandGold, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kCommandGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // IDENTIFICATION Label
                      _buildFieldLabel('IDENTIFICATION'),
                      const SizedBox(height: 8),
                      
                      // Email/ID Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'RANK.NAME@ARMY.MIL',
                          hintStyle: GoogleFonts.rajdhani(
                            color: kTextSecondary.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.badge, color: kTextSecondary),
                          filled: true,
                          fillColor: kCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          color: kTextPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // PASSCODE Label
                      _buildFieldLabel('PASSCODE'),
                      const SizedBox(height: 8),
                      
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: GoogleFonts.rajdhani(
                            color: kTextSecondary.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.vpn_key, color: kTextSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: kTextSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: kCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          color: kTextPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Stay Logged In & Lost Comms
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _stayLoggedIn,
                                  onChanged: (value) {
                                    setState(() {
                                      _stayLoggedIn = value ?? false;
                                    });
                                  },
                                  activeColor: kCommandGold,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'STAY LOGGED IN',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  color: kTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password reset coming soon')),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'LOST COMMS?',
                              style: GoogleFonts.rajdhani(
                                fontSize: 12,
                                color: kCommandGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ACCESS BASE Button
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: kCommandGold,
                              ),
                            )
                          : SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kCommandGold,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.login, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ACCESS BASE',
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // OR Divider
                Text(
                  'OR',
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ENLIST NOW
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New Recruit?  ',
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: _isLoading ? null : _signUpWithGoogle,
                      child: Text(
                        'ENLIST NOW',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          color: kCommandGold,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: kStatusWarning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kTextSecondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}