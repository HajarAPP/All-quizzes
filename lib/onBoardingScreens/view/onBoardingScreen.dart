import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quiz/Screens/quiz_sign_in.dart';
import 'package:quiz/utils/quiz_colors.dart';

class onBoardingScreenHome extends StatefulWidget {
  const onBoardingScreenHome({super.key});

  @override
  State<onBoardingScreenHome> createState() => _OnBoardingScreenHomeState();
}

class _OnBoardingScreenHomeState extends State<onBoardingScreenHome> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Welcome to Security+ Quiz',
      description: 'Master CompTIA Security+ SY0-701 with practice questions.',
      icon: Icons.shield,
    ),
    _OnboardingPage(
      title: 'Learn by Category',
      description: 'Study Threats, Architecture, Operations, and more.',
      icon: Icons.category,
    ),
    _OnboardingPage(
      title: 'Track Your Progress',
      description: 'See your scores and improve over time.',
      icon: Icons.trending_up,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: quizappbackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? quizcolorPrimary : quizShadowColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quizcolorPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                    } else {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_complete', true);
                      if (mounted) {
                        push(const QuizSignIn(), isNewTask: true);
                      }
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 100, color: quizcolorPrimary),
          const SizedBox(height: 32),
          Text(page.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(page.description, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardingPage({required this.title, required this.description, required this.icon});
}
