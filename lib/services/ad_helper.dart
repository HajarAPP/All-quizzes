import 'dart:io';

/// Production AdMob Ad Unit IDs.
///
/// App ID:        ca-app-pub-5531227541272550~8170105416
/// ⚠️  Never commit test IDs to production or production IDs to public repos.
class AdHelper {
  // ── Banner ─────────────────────────────────────────────────────────────────
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5531227541272550/8039289658';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5531227541272550/8039289658';
    }
    throw UnsupportedError('Unsupported platform for Banner ad');
  }

  // ── Interstitial ────────────────────────────────────────────────────────────
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5531227541272550/7535680593';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5531227541272550/7535680593';
    }
    throw UnsupportedError('Unsupported platform for Interstitial ad');
  }

  // ── Rewarded ────────────────────────────────────────────────────────────────
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5531227541272550/1862035758';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5531227541272550/1862035758';
    }
    throw UnsupportedError('Unsupported platform for Rewarded ad');
  }
}
