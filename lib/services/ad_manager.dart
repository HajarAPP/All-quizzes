import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

/// Singleton service that manages the lifecycle of interstitial and rewarded ads.
///
/// Preloads ads on startup and automatically reloads after each show.
/// Includes retry logic with 30-second backoff on load failures.
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialReady = false;
  bool _isRewardedReady = false;

  // ────────────────────────────────────────────────────────────
  //  Interstitial Ad
  // ────────────────────────────────────────────────────────────

  /// Loads an interstitial ad. Retries after 30 seconds on failure.
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
          debugPrint('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
          _isInterstitialReady = false;
          _interstitialAd = null;
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), loadInterstitialAd);
        },
      ),
    );
  }

  /// Shows the interstitial ad if ready.
  /// [onAdDismissed] is called after the ad is closed OR if no ad is available.
  /// This ensures the UX flow is never blocked by ad availability.
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('✅ Interstitial ad dismissed');
          ad.dispose();
          _isInterstitialReady = false;
          _interstitialAd = null;
          loadInterstitialAd(); // Preload next ad
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent:
            (InterstitialAd ad, AdError error) {
          debugPrint('❌ Interstitial ad failed to show: $error');
          ad.dispose();
          _isInterstitialReady = false;
          _interstitialAd = null;
          loadInterstitialAd();
          onAdDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('⚠️ Interstitial ad not ready, skipping');
      onAdDismissed?.call(); // Don't block UX
    }
  }

  // ────────────────────────────────────────────────────────────
  //  Rewarded Ad
  // ────────────────────────────────────────────────────────────

  /// Loads a rewarded ad. Retries after 30 seconds on failure.
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          debugPrint('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isRewardedReady = false;
          _rewardedAd = null;
          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }

  /// Whether a rewarded ad is ready to show.
  bool get isRewardedReady => _isRewardedReady;

  /// Shows the rewarded ad if ready.
  /// [onUserEarnedReward] is called when the user completes the video.
  /// [onAdDismissed] is called when the ad is closed.
  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) {
    if (_isRewardedReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          debugPrint('✅ Rewarded ad dismissed');
          ad.dispose();
          _isRewardedReady = false;
          _rewardedAd = null;
          loadRewardedAd(); // Preload next
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          debugPrint('❌ Rewarded ad failed to show: $error');
          ad.dispose();
          _isRewardedReady = false;
          _rewardedAd = null;
          loadRewardedAd();
          onAdDismissed?.call();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint(
              '🎁 User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
    } else {
      debugPrint('⚠️ Rewarded ad not ready');
    }
  }

  /// Disposes all loaded ads. Call when the app is shutting down.
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialReady = false;
    _isRewardedReady = false;
  }
}
