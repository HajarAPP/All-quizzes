import 'package:flutter/material.dart';
import 'package:quiz/Screens/quiz_details.dart';
import 'package:quiz/model/quiz_models.dart';
import 'package:quiz/utils/app_widget.dart';
import 'package:quiz/utils/quiz_colors.dart';
import 'package:quiz/utils/quiz_constant.dart';
import 'package:quiz/utils/quiz_data_generator.dart';
import 'package:quiz/utils/quiz_strings.dart';
import 'package:quiz/utils/quiz_widget.dart';

class QuizListing extends StatefulWidget {
  const QuizListing({super.key});

  @override
  State<QuizListing> createState() => _QuizListingState();
}

class _QuizListingState extends State<QuizListing> {
  late List<NewQuizModel> mList;

  @override
  void initState() {
    super.initState();
    mList = getQuizData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: quizappbackground,
      appBar: AppBar(
        backgroundColor: quizappbackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: quizcolorPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: text('New Quizzes', fontFamily: fontBold, fontSize: textSizeLargeMedium),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: mList.length,
        itemBuilder: (context, index) {
          final item = mList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizDetails(category: _getCategoryFromName(item.quizName)),
                ),
              );
            },
            child: Container(
              decoration: boxDecoration(radius: 16, showShadow: true, bgColor: quizwhite),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      item.quizImage,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: quizcolorPrimary.withOpacity(0.1),
                        child: const Center(child: Icon(Icons.quiz, color: quizcolorPrimary, size: 40)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(item.quizName, fontFamily: fontMedium, fontSize: textSizeSMedium, isLongText: true),
                        const SizedBox(height: 4),
                        text(item.totalQuiz, textColor: quiztextColorSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryFromName(String quizName) {
    final lower = quizName.toLowerCase();
    if (lower.contains('biology') || lower.contains('scientific')) return 'Biology';
    if (lower.contains('geography')) return 'Geography';
    if (lower.contains('java')) return 'Java';
    if (lower.contains('art') || lower.contains('painting')) return 'Art';
    return 'Biology';
  }
}
