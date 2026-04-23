/// Data model for a quiz question with JSON serialization support.
/// Supports remote fetching from JSON endpoints or Firebase.
class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String? category;
  final String? difficulty;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    this.category,
    this.difficulty,
  });

  /// Creates a Question from a JSON map.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      questionText: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
    );
  }

  /// Converts this Question to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': questionText,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'category': category,
        'difficulty': difficulty,
      };

  /// Checks if the given answer index is correct.
  bool isCorrect(int answerIndex) => answerIndex == correctAnswerIndex;

  /// Returns the correct answer text.
  String get correctAnswer => options[correctAnswerIndex];
}
