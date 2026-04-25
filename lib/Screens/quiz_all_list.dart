import 'package:flutter/material.dart';
import 'package:quiz/Screens/quiz_details.dart';
import 'package:quiz/model/quiz_models.dart';
import 'package:quiz/utils/app_widget.dart';
import 'package:quiz/utils/quiz_colors.dart';
import 'package:quiz/utils/quiz_data_generator.dart';
import 'package:quiz/utils/quiz_strings.dart';
import 'package:quiz/utils/quiz_widget.dart';

class QuizAllList extends StatefulWidget {
  const QuizAllList({super.key});

  @override
  State<QuizAllList> createState() => _QuizAllListState();
}

class _QuizAllListState extends State<QuizAllList> {
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
        title: text(quizlblnewquiz, fontFamily: fontBold, fontSize: textSizeLargeMedium),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
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
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: boxDecoration(radius: 16, showShadow: true, bgColor: quizwhite),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(item.quizImage, width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60, height: 60, color: quizcolorPrimary.withOpacity(0.1),
                        child: const Icon(Icons.quiz, color: quizcolorPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(item.quizName, fontFamily: fontMedium, fontSize: textSizeMedium),
                        const SizedBox(height: 4),
                        text(item.totalQuiz, textColor: quiztextColorSecondary),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: quiztextColorSecondary),
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
