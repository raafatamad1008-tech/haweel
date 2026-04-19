
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class MembershipPage extends StatefulWidget {
  final String membershipType;
  const MembershipPage({super.key, required this.membershipType});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Timer _confettiTimer;
  List<ConfettiParticle> _confettiParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Animation for the membership card
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _scaleController.forward();

    // Confetti animation controller
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Generate confetti particles
    _generateConfetti();
    
    // Timer to regenerate confetti
    _confettiTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _updateConfetti();
      });
    });
  }

  void _generateConfetti() {
    _confettiParticles = List.generate(50, (index) {
      return ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.005 + _random.nextDouble() * 0.01,
        size: 5 + _random.nextDouble() * 15,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        angle: _random.nextDouble() * 2 * pi,
      );
    });
  }

  void _updateConfetti() {
    for (var particle in _confettiParticles) {
      particle.y -= particle.speed;
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = _random.nextDouble();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _confettiTimer.cancel();
    super.dispose();
  }

  Color _getMembershipColor() {
    switch (widget.membershipType) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.blueGrey;
      case 2:
        return Colors.purple;
     
      default:
        return Colors.green;
    }
  }

  // IconData _getMembershipIcon() {
  //   switch (widget.membershipType) {
  //     case 0:
  //       return  Icons.new_releases;
  //     case 1:
  //       return  Icons.bolt;
  //     case 2:
  //       return  Icons.verified;
     
  //     default:
  //       return  Icons.star;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getMembershipColor().withOpacity(0.3),
                      Colors.black,
                    ],
                    center: Alignment(
                      sin(_confettiController.value * 2 * pi) * 0.3,
                      cos(_confettiController.value * 2 * pi) * 0.3,
                    ),
                    radius: 1.5,
                  ),
                ),
              );
            },
          ),

          // Confetti particles
          CustomPaint(
            painter: ConfettiPainter(particles: _confettiParticles),
            child: Container(),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Celebration text with animation
                TweenAnimationBuilder(
                  duration: const Duration(seconds: 2),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.5 + value * 0.5,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        '🎉 مبروك! 🎉',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getMembershipColor(),
                          shadows: [
                            Shadow(
                              color: _getMembershipColor().withOpacity(0.8),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'تم ترقية عضويتك',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Membership card
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 300,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getMembershipColor(),
                          _getMembershipColor().withOpacity(0.6),
                          Colors.white,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _getMembershipColor().withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Card pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CardPatternPainter(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        
                        // Card content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    child: Center(
                                        child: Icon(
                                          Icons.verified,
                                          color: const Color.fromARGB(255, 255, 204, 0),
                                          size: 64,
                                        ),
                                      ),
                                  ),
                                  const Spacer(),
                                  // Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 12,
                                  //     vertical: 6,
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //     color: Colors.white.withOpacity(0.3),
                                  //     borderRadius: BorderRadius.circular(20),
                                  //   ),
                                  //   child: Text(
                                  //     widget.membershipType.toUpperCase(),
                                  //     style: const TextStyle(
                                  //       color: Colors.white,
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 16,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const Spacer(),
                              Center(
                                child: Text(
                                  widget.membershipType,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'عضوية مميزة',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Benefits list with animations
                // ..._buildBenefits(),

                const SizedBox(height: 50),

                // Continue button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getMembershipColor(),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'استمر',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  List<Widget> _buildBenefits() {
    List<String> benefits = [
      'مزايا حصرية',
      'خصومات خاصة',
      'دعم متميز',
      'وصول مبكر',
    ];

    return benefits.asMap().entries.map((entry) {
      int index = entry.key;
      String benefit = entry.value;
      
      return TweenAnimationBuilder(
        duration: Duration(milliseconds: 500 + index * 200),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: _getMembershipColor(),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                benefit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// Confetti particle class
class ConfettiParticle {
  double x;
  double y;
  double speed;
  double size;
  Color color;
  double angle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.angle,
  });
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(
        particle.x * size.width,
        particle.y * size.height,
      );
      canvas.rotate(particle.angle);
      
      // Draw rectangle for confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size * 0.7,
          height: particle.size,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Card pattern painter
class CardPatternPainter extends CustomPainter {
  final Color color;

  CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 20.0;
    
    for (double i = -size.width; i < size.width * 2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}