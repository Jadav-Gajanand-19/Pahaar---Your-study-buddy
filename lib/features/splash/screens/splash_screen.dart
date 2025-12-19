import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prahar/core/theme/theme.dart';
import 'package:prahar/features/auth/screens/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _shieldController;
  late AnimationController _starsController;
  late AnimationController _titleController;
  late AnimationController _taglineController;
  late AnimationController _progressController;
  late AnimationController _bottomTextController;
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  late Animation<double> _shieldScale;
  late Animation<double> _shieldOpacity;
  late Animation<double> _star1Opacity;
  late Animation<double> _star2Opacity;
  late Animation<double> _star3Opacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _progressValue;
  late Animation<double> _bottomTextOpacity;
  late Animation<double> _shimmer;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _shieldController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bottomTextController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: false);
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Shield animations
    _shieldScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.elasticOut),
    );
    
    _shieldOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shieldController, curve: Curves.easeIn),
    );

    // Stars animations (sequential)
    _star1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starsController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    
    _star2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starsController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _star3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starsController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Title animations
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeIn),
    );

    // Tagline animation
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    // Progress bar animation
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Bottom text animation
    _bottomTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomTextController, curve: Curves.easeIn),
    );

    // Shimmer effect for title
    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
    
    // Glow effect for shield
    _glow = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // Shield appears first
    await Future.delayed(const Duration(milliseconds: 200));
    _shieldController.forward();
    
    // Stars appear after shield
    await Future.delayed(const Duration(milliseconds: 400));
    _starsController.forward();
    
    // Title slides up
    await Future.delayed(const Duration(milliseconds: 300));
    _titleController.forward();
    
    // Tagline fades in
    await Future.delayed(const Duration(milliseconds: 200));
    _taglineController.forward();
    
    // Progress bar starts
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    
    // Bottom text appears
    await Future.delayed(const Duration(milliseconds: 500));
    _bottomTextController.forward();
    
    // Navigate to AuthWrapper after all animations
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _shieldController.dispose();
    _starsController.dispose();
    _titleController.dispose();
    _taglineController.dispose();
    _progressController.dispose();
    _bottomTextController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kLightBackground,
              kCardElevated,
              kLightBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // Shield with stars
            AnimatedBuilder(
              animation: Listenable.merge([_shieldController, _starsController, _glowController]),
              builder: (context, child) {
                return Column(
                  children: [
                    // Shield icon
                    Opacity(
                      opacity: _shieldOpacity.value,
                      child: Transform.scale(
                        scale: _shieldScale.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: kCommandGold,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: kCommandGold.withOpacity(_glow.value),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: kCommandGold.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shield,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              // Three stars
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Opacity(
                                    opacity: _star1Opacity.value,
                                    child: const Icon(Icons.star, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  Opacity(
                                    opacity: _star2Opacity.value,
                                    child: const Icon(Icons.star, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  Opacity(
                                    opacity: _star3Opacity.value,
                                    child: const Icon(Icons.star, size: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // App name with slide and shimmer animation
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleOpacity,
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: const [
                            kTextDarkPrimary,
                            kCommandGold,
                            kTextDarkPrimary,
                          ],
                          stops: [
                            0.0,
                            _shimmer.value.clamp(0.0, 1.0),
                            1.0,
                          ],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Prahaar',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Tagline
            FadeTransition(
              opacity: _taglineOpacity,
              child: Text(
                'THE STUDY BUDDY',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextDarkSecondary,
                  letterSpacing: 2,
                ),
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Progress bar
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progressValue.value,
                      backgroundColor: Colors.grey[300],
                      color: kMilitaryGreen, // Lime green instead of blue
                      minHeight: 6,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80),
            
            // Bottom text
            FadeTransition(
              opacity: _bottomTextOpacity,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kLightBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, size: 16, color: kCommandGold),
                    const SizedBox(width: 8),
                    Text(
                      'Forging Discipline. Cracking CDS.',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kCommandGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Version text
            FadeTransition(
              opacity: _bottomTextOpacity,
              child: Text(
                'VERSION 1.0.0',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: kTextDarkSecondary,
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }
}
