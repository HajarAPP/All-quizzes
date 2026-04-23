import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/Screens/result_screen.dart';
import 'package:quiz/main.dart';
import 'package:quiz/model/question.dart';
import 'package:quiz/services/ad_manager.dart';
import 'package:quiz/utils/theme_provider.dart';

// ── Remote URL — replace with your Hostinger path ────────────────────────────
const String _remoteUrl =
    'https://yourdomain.com/quiz-data/security_plus.json';

const int _questionsPerSession = 20; // chunk size per quiz session
const String _cacheKey = 'cached_questions_json';

// ── Fallback sample (3 questions — used only when remote+cache both fail) ────
const List<Map<String, dynamic>> _fallback = [
  {
    'id': 'f1', 'question': 'Which port does HTTPS use by default?',
    'options': ['80', '443', '8080', '21'], 'correctAnswerIndex': 1,
    'category': 'Security+', 'difficulty': 'easy',
  },
  {
    'id': 'f2', 'question': 'Which attack uses precomputed hashes?',
    'options': ['Brute force', 'Rainbow table', 'Phishing', 'SQLi'],
    'correctAnswerIndex': 1, 'category': 'Security+', 'difficulty': 'medium',
  },
  {
    'id': 'f3', 'question': 'What is the STRONGEST enterprise Wi-Fi auth?',
    'options': ['WEP', 'WPA2-PSK', 'WPA3-Enterprise 802.1X', 'MAC filter'],
    'correctAnswerIndex': 2, 'category': 'Security+', 'difficulty': 'hard',
  },
];

// ─────────────────────────────────────────────────────────────────────────────
class QuizCards extends StatefulWidget {
  static String tag = '/QuizCards';
  final String? category;
  const QuizCards({super.key, this.category});

  @override
  State<QuizCards> createState() => _QuizCardsState();
}

class _QuizCardsState extends State<QuizCards>
    with SingleTickerProviderStateMixin {
  // ── Data ────────────────────────────────────────────────────────────────
  List<Question> _sessionQuestions = [];
  bool _isLoading = true;
  int _totalBank = 0; // total questions in the remote bank

  // ── Session state ──────────────────────────────────────────────────────
  int _idx = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  final List<Map<String, dynamic>> _wrongAnswers = [];
  int? _selected;
  bool _answered = false;

  // ── Animation ──────────────────────────────────────────────────────────
  late AnimationController _fbCtrl;
  late Animation<double> _fbScale;

  @override
  void initState() {
    super.initState();
    _fbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fbScale = CurvedAnimation(parent: _fbCtrl, curve: Curves.easeOutBack);
    _loadQuestions();
  }

  @override
  void dispose() {
    _fbCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────
  // QUESTION LOADING — handles 500+ questions efficiently
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    List<Question>? all;

    // Tier 1: Remote
    all = await _fetchRemote();

    // Tier 2: Cached
    all ??= await _fetchCached();

    // Tier 3: Fallback
    all ??= _fallback.map((q) => Question.fromJson(q)).toList();

    // Filter by category
    if (widget.category != null && widget.category!.isNotEmpty) {
      all = all
          .where((q) =>
              q.category?.toLowerCase() == widget.category!.toLowerCase())
          .toList();
    }

    _totalBank = all.length;

    // Shuffle & pick a session-sized chunk
    all.shuffle(Random.secure());
    final session = all.take(_questionsPerSession).toList();

    if (mounted) {
      setState(() {
        _sessionQuestions = session;
        _isLoading = false;
      });
    }
  }

  Future<List<Question>?> _fetchRemote() async {
    try {
      final res = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        // Cache for offline use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, res.body);

        return _parseJson(res.body);
      }
    } catch (e) {
      debugPrint('⚠️ Remote: $e');
    }
    return null;
  }

  Future<List<Question>?> _fetchCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) return _parseJson(raw);
    } catch (_) {}
    return null;
  }

  List<Question> _parseJson(String body) {
    final data = json.decode(body) as Map<String, dynamic>;
    final raw = data['questions'] as List;
    return raw
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  // ────────────────────────────────────────────────────────────────────────
  // ANSWER LOGIC
  // ────────────────────────────────────────────────────────────────────────

  void _pick(int i) {
    if (_answered) return;
    final q = _sessionQuestions[_idx];
    setState(() { _selected = i; _answered = true; });
    _fbCtrl.forward(from: 0);

    if (q.isCorrect(i)) {
      _correctCount++;
      Future.delayed(const Duration(milliseconds: 850), _advance);
    } else {
      _wrongCount++;
      _wrongAnswers.add({'question': q, 'userAnswer': i});
      Future.delayed(const Duration(milliseconds: 750), _showUndoDialog);
    }
  }

  void _showUndoDialog() {
    if (!mounted) return;
    final c = context;
    showDialog(
      context: c,
      barrierDismissible: false,
      builder: (ctx) {
        final dark = ctx.isDark;
        return AlertDialog(
          backgroundColor: dark ? kDarkCard : kLightCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(Icons.info_outline_rounded, color: kWrong, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Incorrect',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                      color: dark ? kDarkTextPrimary : kLightTextPrimary)),
            ),
          ]),
          content: Text(
            AdManager().isRewardedReady
                ? 'Watch a short ad to undo your answer and try again.'
                : 'No ad available right now.',
            style: TextStyle(
                fontSize: 15,
                color: dark ? kDarkTextSecondary : kLightTextSecondary,
                height: 1.45),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(ctx); _advance(); },
              child: Text('Skip',
                  style: TextStyle(
                      color: dark ? kDarkTextSecondary : kLightTextSecondary)),
            ),
            if (AdManager().isRewardedReady)
              FilledButton.icon(
                icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                label: const Text('Watch & Undo'),
                style: FilledButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  AdManager().showRewardedAd(
                    onUserEarnedReward: (_) {
                      if (mounted) {
                        setState(() {
                          _wrongAnswers.removeLast();
                          _wrongCount--;
                          _correctCount++;
                          _selected = null;
                          _answered = false;
                        });
                        _fbCtrl.reset();
                      }
                    },
                    onAdDismissed: () {
                      if (_answered && mounted) _advance();
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _advance() {
    if (!mounted) return;
    if (_idx >= _sessionQuestions.length - 1) {
      _onComplete();
    } else {
      setState(() { _idx++; _selected = null; _answered = false; });
      _fbCtrl.reset();
    }
  }

  void _onComplete() {
    AdManager().showInterstitialAd(
      onAdDismissed: () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              totalQuestions: _sessionQuestions.length,
              correctAnswers: _correctCount,
              wrongAnswers: _wrongAnswers,
              category: widget.category ?? 'Security+',
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _exitDialog(),
      child: Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _isLoading
                ? _loadingView()
                : _sessionQuestions.isEmpty
                    ? _emptyView()
                    : _quizView(),
          ),
        ),
      ),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────────────
  Widget _loadingView() => Center(
        key: const ValueKey('loading'),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
                color: kAccent, strokeWidth: 3, strokeCap: StrokeCap.round),
          ),
          const SizedBox(height: 20),
          Text('Loading questions…',
              style: TextStyle(
                  fontSize: 15, color: context.textSecondary)),
        ]),
      );

  // ── Empty ───────────────────────────────────────────────────────────────
  Widget _emptyView() => Center(
        key: const ValueKey('empty'),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.quiz_outlined, size: 56, color: context.textSecondary),
          const SizedBox(height: 16),
          Text('No questions found.',
              style: TextStyle(fontSize: 15, color: context.textSecondary)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loadQuestions,
            style: FilledButton.styleFrom(backgroundColor: kAccent),
            child: const Text('Retry'),
          ),
        ]),
      );

  // ── Quiz View ───────────────────────────────────────────────────────────
  Widget _quizView() {
    final q = _sessionQuestions[_idx];
    final progress = (_idx + 1) / _sessionQuestions.length;

    return Column(key: const ValueKey('quiz'), children: [
      _topBar(progress),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(children: [
            _scorePills(),
            if (_totalBank > _questionsPerSession) ...[
              const SizedBox(height: 6),
              Text(
                'Session: $_questionsPerSession of $_totalBank questions',
                style: TextStyle(
                    fontSize: 11, color: context.textSecondary),
              ),
            ],
            const SizedBox(height: 14),
            _questionCard(q),
            const SizedBox(height: 14),
            ...List.generate(
              q.options.length,
              (i) => _optionTile(
                letter: String.fromCharCode(65 + i),
                optionText: q.options[i],
                index: i,
                question: q,
              ),
            ),
          ]),
        ),
      ),
    ]);
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────
  Widget _topBar(double progress) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.close_outlined, color: context.textSecondary),
            onPressed: _exitDialog,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: context.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progress > 0.75 ? kCorrect : kAccent),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${_idx + 1}/${_sessionQuestions.length}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary)),
          const SizedBox(width: 4),

          // ── Dark/Light toggle ──────────────────────────────────────────
          IconButton(
            icon: Icon(
              themeNotifier.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: context.textSecondary,
              size: 20,
            ),
            onPressed: () => themeNotifier.toggle(),
            tooltip: 'Toggle theme',
          ),
        ]),
      );

  // ── Score Pills ─────────────────────────────────────────────────────────
  Widget _scorePills() => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _pill(Icons.check_circle_outline_rounded, kCorrect,
              '$_correctCount Correct'),
          const SizedBox(width: 10),
          _pill(Icons.highlight_off_rounded, kWrong,
              '$_wrongCount Wrong'),
        ]),
      );

  Widget _pill(IconData icon, Color color, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      );

  // ── Question Card ───────────────────────────────────────────────────────
  Widget _questionCard(Question q) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(context.isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: [
          if (q.difficulty != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: _diffBadge(q.difficulty!),
            ),
            const SizedBox(height: 10),
          ],
          Text(q.questionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 19,
                  color: context.textPrimary,
                  height: 1.45)),
          if (q.category != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(q.category!,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kAccent)),
            ),
          ],
        ]),
      );

  Widget _diffBadge(String d) {
    final color = d == 'easy'
        ? kCorrect
        : d == 'hard'
            ? kWrong
            : kWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(d.toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 9,
              color: color,
              letterSpacing: 1.2)),
    );
  }

  // ── Option Tile ─────────────────────────────────────────────────────────
  Widget _optionTile({
    required String letter,
    required String optionText,
    required int index,
    required Question question,
  }) {
    Color bg = context.card;
    Color border = context.border;
    Color fg = context.textPrimary;
    IconData? trail;
    Color? trailColor;

    if (_answered) {
      if (index == question.correctAnswerIndex) {
        bg = kCorrect.withOpacity(0.1);
        border = kCorrect;
        fg = kCorrect;
        trail = Icons.check_circle_outline_rounded;
        trailColor = kCorrect;
      } else if (index == _selected) {
        bg = kWrong.withOpacity(0.1);
        border = kWrong;
        fg = kWrong;
        trail = Icons.highlight_off_rounded;
        trailColor = kWrong;
      }
    }

    return ScaleTransition(
      scale: (index == _selected && _answered)
          ? _fbScale
          : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: _answered ? null : () => _pick(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 1.4),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            // Letter circle
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _answered && index == question.correctAnswerIndex
                    ? kCorrect.withOpacity(0.15)
                    : kAccent.withOpacity(0.08),
              ),
              child: Center(
                child: Text('$letter.',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _answered &&
                                index == question.correctAnswerIndex
                            ? kCorrect
                            : kAccent)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(optionText,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: fg,
                      height: 1.35)),
            ),
            if (trail != null) ...[
              const SizedBox(width: 6),
              Icon(trail, color: trailColor, size: 20),
            ],
          ]),
        ),
      ),
    );
  }

  // ── Exit dialog ─────────────────────────────────────────────────────────
  void _exitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.isDark ? kDarkCard : kLightCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Quit Quiz?',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: ctx.textPrimary)),
        content: Text('Your progress will be lost.',
            style: TextStyle(color: ctx.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue', style: TextStyle(color: kAccent)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); finish(context); },
            child: const Text('Quit', style: TextStyle(color: kWrong)),
          ),
        ],
      ),
    );
  }
}
