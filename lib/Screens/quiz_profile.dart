import 'package:flutter/material.dart';
import 'package:quiz/utils/app_widget.dart';
import 'package:quiz/utils/quiz_colors.dart';
import 'package:quiz/utils/quiz_constant.dart';
import 'package:quiz/utils/quiz_strings.dart';

class QuizProfile extends StatefulWidget {
  const QuizProfile({super.key});

  @override
  State<QuizProfile> createState() => _QuizProfileState();
}

class _QuizProfileState extends State<QuizProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: quizappbackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: quizcolorPrimary.withOpacity(0.1),
                ),
                child: const Icon(Icons.person, size: 50, color: quizcolorPrimary),
              ),
              const SizedBox(height: 16),
              text('Security+ Student', fontFamily: fontBold, fontSize: textSizeLargeMedium),
              const SizedBox(height: 4),
              text('student@example.com', textColor: quiztextColorSecondary),
              const SizedBox(height: 32),
              _profileTile(Icons.star, 'My Scores', 'View your quiz results'),
              _profileTile(Icons.bookmark, 'Saved Quizzes', 'Resume where you left off'),
              _profileTile(Icons.settings, 'Settings', 'App preferences'),
              _profileTile(Icons.info_outline, 'About', 'Version 1.0.1'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: boxDecoration(radius: 12, showShadow: true, bgColor: quizwhite),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: quizcolorPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: quizcolorPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(title, fontFamily: fontMedium, fontSize: textSizeMedium),
                const SizedBox(height: 2),
                text(subtitle, textColor: quiztextColorSecondary, fontSize: textSizeSMedium),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: quiztextColorSecondary),
        ],
      ),
    );
  }
}
