import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz/main.dart';
import 'package:quiz/model/question.dart';
import 'package:quiz/services/ad_helper.dart';
import 'package:quiz/utils/theme_provider.dart';

/// Professional result screen — fully theme-aware with outline icons,
/// animated score ring, Pass/Fail badge, Review Mistakes, and Banner Ad.
class ResultScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final List<Map<String, dynamic>> wrongAnswers;
  final String? category;

  const ResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    this.category,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _ringAnim = Tween<double>(
      begin: 0,
      end: widget.correctAnswers / widget.totalQuestions,
    ).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic));
    _ringCtrl.forward();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerReady = true),
        onAdFailedToLoad: (ad, err) { debugPrint('Banner: $err'); ad.dispose(); },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  // ── Derived values ──────────────────────────────────────────────────────
  double get _pct => (widget.correctAnswers / widget.totalQuestions) * 100;
  bool get _passed => _pct >= 75;

  Color get _ringColor {
    if (_pct >= 80) return kCorrect;
    if (_pct >= 60) return const Color(0xFF8BC34A);
    if (_pct >= 40) return kWarning;
    return kWrong;
  }

  String get _emoji {
    if (_pct >= 80) return '🏆';
    if (_pct >= 60) return '👏';
    if (_pct >= 40) return '💪';
    return '📚';
  }

  String get _headline {
    if (_pct >= 80) return 'Excellent!';
    if (_pct >= 60) return 'Great Job!';
    if (_pct >= 40) return 'Keep Going!';
    return 'Study More';
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.bg,
        body: SafeArea(
          child: Column(children: [
            // ── Top bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                IconButton(
                  icon: Icon(Icons.close_outlined,
                      color: context.textSecondary),
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                Expanded(
                  child: Text('Quiz Results',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: context.textPrimary)),
                ),
                // Theme toggle
                IconButton(
                  icon: Icon(
                    themeNotifier.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: context.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => themeNotifier.toggle(),
                ),
              ]),
            ),

            // ── Scrollable content ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(children: [
                  // ── Score ring ────────────────────────────────────────
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: _ringAnim,
                    builder: (_, __) => _buildRing(),
                  ),
                  const SizedBox(height: 16),

                  // ── Emoji + headline ──────────────────────────────────
                  Text(_emoji, style: const TextStyle(fontSize: 42)),
                  const SizedBox(height: 6),
                  Text(_headline,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: context.textPrimary)),
                  if (widget.category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(widget.category!,
                          style: TextStyle(
                              fontSize: 15,
                              color: context.textSecondary)),
                    ),

                  const SizedBox(height: 10),

                  // ── Pass / Fail chip ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_passed ? kCorrect : kWrong).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: (_passed ? kCorrect : kWrong)
                              .withOpacity(0.25)),
                    ),
                    child: Text(
                      _passed ? '✅  PASS (≥75%)' : '❌  FAIL (<75%)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _passed ? kCorrect : kWrong),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ── Stat cards ────────────────────────────────────────
                  Row(children: [
                    Expanded(
                        child: _stat('Correct', '${widget.correctAnswers}',
                            Icons.check_circle_outline_rounded, kCorrect)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _stat('Wrong', '${widget.wrongAnswers.length}',
                            Icons.highlight_off_rounded, kWrong)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _stat('Total', '${widget.totalQuestions}',
                            Icons.quiz_outlined, kAccent)),
                  ]),

                  const SizedBox(height: 24),

                  // ── Review Mistakes ───────────────────────────────────
                  if (widget.wrongAnswers.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Icon(Icons.rate_review_outlined,
                            size: 18, color: context.textPrimary),
                        const SizedBox(width: 8),
                        Text('Review Mistakes',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: context.textPrimary)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    ...widget.wrongAnswers.asMap().entries.map((e) {
                      final q = e.value['question'] as Question;
                      final ua = e.value['userAnswer'] as int;
                      return _reviewCard(e.key + 1, q, ua);
                    }),
                  ],

                  const SizedBox(height: 20),

                  // ── Retry button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.replay_outlined, size: 20),
                      label: const Text('Retry Quiz',
                          style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context, 'retry'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Home button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.home_outlined,
                          size: 20, color: kAccent),
                      label: Text('Back to Home',
                          style: TextStyle(fontSize: 16, color: kAccent)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kAccent.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(context)
                          .popUntil((r) => r.isFirst),
                    ),
                  ),

                  const SizedBox(height: 72), // clear banner
                ]),
              ),
            ),

            // ── Banner Ad ───────────────────────────────────────────────
            if (_bannerReady && _bannerAd != null)
              Container(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.surface,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.4 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2)),
                  ],
                ),
                child: AdWidget(ad: _bannerAd!),
              ),
          ]),
        ),
      ),
    );
  }

  // ── Score ring ──────────────────────────────────────────────────────────
  Widget _buildRing() => Center(
        child: SizedBox(
          width: 180, height: 180,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _ringColor.withOpacity(0.2),
                      blurRadius: 22,
                      spreadRadius: 3),
                ],
              ),
            ),
            SizedBox(
              width: 180, height: 180,
              child: CircularProgressIndicator(
                value: _ringAnim.value,
                strokeWidth: 12,
                backgroundColor: context.border,
                valueColor: AlwaysStoppedAnimation<Color>(_ringColor),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(_ringAnim.value * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      color: _ringColor)),
              Text('${widget.correctAnswers}/${widget.totalQuestions}',
                  style: TextStyle(
                      fontSize: 14, color: context.textSecondary)),
            ]),
          ]),
        ),
      );

  // ── Stat card ───────────────────────────────────────────────────────────
  Widget _stat(String label, String value, IconData icon, Color color) =>
      Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: context.textSecondary)),
        ]),
      );

  // ── Review card ─────────────────────────────────────────────────────────
  Widget _reviewCard(int n, Question q, int userAnswer) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Number badge + question
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.1)),
              child: Center(
                child: Text('$n',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: kAccent)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(q.questionText,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: context.textPrimary,
                      height: 1.4)),
            ),
          ]),
          const SizedBox(height: 12),
          // User answer (wrong)
          _answerRow(
              Icons.highlight_off_rounded, kWrong,
              'Your answer:', q.options[userAnswer]),
          const SizedBox(height: 6),
          // Correct answer
          _answerRow(
              Icons.check_circle_outline_rounded, kCorrect,
              'Correct:', q.correctAnswer),
        ]),
      );

  Widget _answerRow(IconData icon, Color color, String label, String val) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  height: 1.4),
              children: [
                TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(
                    text: val,
                    style:
                        TextStyle(fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ),
      ]);
}

/// Lightweight AnimatedWidget wrapper for the score ring animation.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, null);
}
