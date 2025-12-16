import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../course_management/screens/dashboard_screen.dart';
import '../models/onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Course Management",
      description:
          "Organize and manage your courses efficiently with our intuitive tools.",
      icon: Icons.school_rounded,
      color: const Color(0xFF6C63FF),
    ),
    OnboardingContent(
      title: "Video Lessons",
      description:
          "Upload and stream high-quality educational videos for your students.",
      icon: Icons.play_circle_fill_rounded,
      color: const Color(0xFFFF6584),
    ),
    OnboardingContent(
      title: "Track Progress",
      description: "Monitor student performance and engagement in real-time.",
      icon: Icons.insights_rounded,
      color: const Color(0xFF00BFA6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/logo.png', height: 60)
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(
                  begin: -0.5,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(content: _contents[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? _contents[_currentIndex].color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next/Done Button
                  ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _contents[_currentIndex].color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _currentIndex == _contents.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      .animate(
                        target: _currentIndex == _contents.length - 1 ? 1 : 0,
                      )
                      .shake(duration: 300.ms, hz: 2, curve: Curves.easeInOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const _OnboardingPage({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: content.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(content.icon, size: 100, color: content.color),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 60),
          Text(
                content.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .moveY(begin: 20, end: 0),
          const SizedBox(height: 20),
          Text(
                content.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .moveY(begin: 20, end: 0),
        ],
      ),
    );
  }
}
