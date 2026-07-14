import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _drawAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize SplashController here so it triggers the background work
    Get.put(SplashController());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Path drawing animation (starts at 0.0, ends at 0.6)
    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOutCubic),
      ),
    );

    // 2. Pulse / Scale scale transition (starts at 0.6, ends at 0.85)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // 3. Text and Subtitle Fade-in & slide-up (starts at 0.65, ends at 0.95)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.65, 0.95, curve: Curves.easeOut),
      ),
    );

    // 4. Glow animation breathing effect (starts at 0.5, ends at 1.0)
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
      ),
    );

    // Start the splash screen animation sequence
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define background gradient based on theme
    final backgroundGradient = isDarkMode
        ? const LinearGradient(
            colors: [Color(0xFF0F0C1B), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFF3EFFF), Color(0xFFF9F9FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final primaryColor = theme.primaryColor;
    final accentColor = isDarkMode ? Colors.deepPurpleAccent : Colors.deepPurple.shade300;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content centered
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Logo & Glow Stack
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial Halo Glow behind 'M'
                              Opacity(
                                opacity: _glowAnimation.value * 0.15,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor,
                                        blurRadius: 40,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Custom Painted M
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(
                                  painter: LogoPainter(
                                    progress: _drawAnimation.value,
                                    color: primaryColor,
                                    glowColor: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // App Title & Subtitle Fade In
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1.0 - _fadeAnimation.value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'MEvent',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 38,
                              letterSpacing: 1.5,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Event Management',
                            style: theme.textTheme.titleMedium?.copyWith(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Premium subtle check progress indicator
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value * 0.7,
                          child: child,
                        );
                      },
                      child: const Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Checking security...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  LogoPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define the 5 points of the 'M' layout
    final p1 = Offset(width * 0.15, height * 0.82);
    final p2 = Offset(width * 0.15, height * 0.18);
    final p3 = Offset(width * 0.5, height * 0.58);
    final p4 = Offset(width * 0.85, height * 0.18);
    final p5 = Offset(width * 0.85, height * 0.82);

    // Build the path representing the 'M'
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy);

    // Compute path metrics to animate drawing path
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    final totalLength = pathMetrics.fold<double>(0, (sum, m) => sum + m.length);
    final currentTargetLength = totalLength * progress;

    double currentLength = 0;
    final animatedPath = Path();

    for (var metric in pathMetrics) {
      if (currentLength >= currentTargetLength) break;
      final remainingLength = currentTargetLength - currentLength;

      if (remainingLength >= metric.length) {
        animatedPath.addPath(
          metric.extractPath(0, metric.length),
          Offset.zero,
        );
        currentLength += metric.length;
      } else {
        animatedPath.addPath(
          metric.extractPath(0, remainingLength),
          Offset.zero,
        );
        currentLength += remainingLength;
      }
    }

    // 1. Paint glow shadow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = glowColor.withOpacity(0.35 * progress)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0);

    canvas.drawPath(animatedPath, glowPaint);

    // 2. Paint the main gradient path
    final mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gradient = LinearGradient(
      colors: [color, glowColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    mainPaint.shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(animatedPath, mainPaint);
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.glowColor != glowColor;
  }
}
