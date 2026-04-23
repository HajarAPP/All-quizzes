import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/question.dart';

/// Service responsible for fetching quiz questions.
///
/// Uses a 3-tier fallback strategy:
///   1. Remote JSON endpoint (primary)
///   2. Local cache (SharedPreferences)
///   3. Bundled asset file (assets/questions.json)
///
/// To update questions without republishing the app, simply update
/// the remote JSON file. The app will fetch and cache it automatically.
class QuestionService {
  /// Remote endpoint for questions JSON.
  /// Replace this with your actual URL:
  ///   - Firebase Hosting: https://your-project.web.app/questions.json
  ///   - GitHub Pages: https://username.github.io/quiz-data/questions.json
  ///   - Your own API: https://api.yourdomain.com/questions
  static const String _remoteUrl =
      'https://your-domain.com/api/questions.json';

  static const String _cacheKey = 'cached_questions_json';
  static const String _cacheVersionKey = 'cached_questions_version';

  /// Fetches questions with the 3-tier fallback strategy.
  /// Optionally filter by [category].
  static Future<List<Question>> fetchQuestions({String? category}) async {
    // ── Tier 1: Try remote endpoint ──
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Questions loaded from remote');
        final data = json.decode(response.body);

        // Cache the response for offline use
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, response.body);
          if (data['version'] != null) {
            await prefs.setString(
                _cacheVersionKey, data['version'].toString());
          }
        } catch (cacheError) {
          debugPrint('⚠️ Failed to cache questions: $cacheError');
        }

        return _parseQuestions(data, category);
      }
    } catch (e) {
      debugPrint('⚠️ Remote fetch failed: $e');
    }

    // ── Tier 2: Try local cache ──
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint('✅ Questions loaded from cache');
        final data = json.decode(cached);
        return _parseQuestions(data, category);
      }
    } catch (e) {
      debugPrint('⚠️ Cache read failed: $e');
    }

    // ── Tier 3: Fallback to bundled asset ──
    debugPrint('✅ Questions loaded from bundled asset');
    final assetData = await rootBundle.loadString('assets/questions.json');
    final data = json.decode(assetData);
    return _parseQuestions(data, category);
  }

  /// Parses the JSON data into a list of Question objects.
  /// Optionally filters by [category] and shuffles the result.
  static List<Question> _parseQuestions(
      dynamic data, String? category) {
    final List<dynamic> questions = data['questions'] as List<dynamic>;
    var parsed = questions
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    // Filter by category if specified
    if (category != null && category.isNotEmpty) {
      parsed = parsed
          .where((q) =>
              q.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }

    // Shuffle for variety
    parsed.shuffle();
    return parsed;
  }

  /// Returns all available categories from the question bank.
  static Future<List<String>> fetchCategories() async {
    final questions = await fetchQuestions();
    final categories = questions
        .where((q) => q.category != null)
        .map((q) => q.category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
