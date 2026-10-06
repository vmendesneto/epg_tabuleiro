import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _productionBannerAdUnitId = 'ca-app-pub-7960665567498956/4285783765';
const _productionInterstitialAdUnitId =
    'ca-app-pub-7960665567498956/6720375412';

// IDs oficiais de teste do Google. Builds de debug nunca usam os blocos reais.
const _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

class GoogleAdsController extends ChangeNotifier {
  BannerAd? _banner;
  InterstitialAd? _interstitial;
  bool _initialized = false;
  bool _disposed = false;
  bool _bannerAllowed = true;

  BannerAd? get banner => _banner;
  bool get hasBanner => _banner != null;

  String get _bannerAdUnitId =>
      kReleaseMode ? _productionBannerAdUnitId : _testBannerAdUnitId;
  String get _interstitialAdUnitId => kReleaseMode
      ? _productionInterstitialAdUnitId
      : _testInterstitialAdUnitId;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // O jogo é direcionado a crianças. Esta configuração restringe a
    // solicitação a conteúdo adequado e evita personalização incompatível.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        ageRestrictedTreatment: AgeRestrictedTreatment.child,
        maxAdContentRating: MaxAdContentRating.g,
      ),
    );
    await MobileAds.instance.initialize();
    loadBanner();
    _loadInterstitial();
  }

  void loadBanner() {
    if (_disposed || !_bannerAllowed || _banner != null) return;
    BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed || !_bannerAllowed) {
            unawaited(ad.dispose());
            return;
          }
          _banner = ad as BannerAd;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, _) {
          unawaited(ad.dispose());
          if (_banner == ad) _banner = null;
        },
      ),
    ).load();
  }

  void hideBanner() {
    _bannerAllowed = false;
    final banner = _banner;
    final interstitial = _interstitial;
    _banner = null;
    _interstitial = null;
    if (banner != null) unawaited(banner.dispose());
    if (interstitial != null) unawaited(interstitial.dispose());
    if (!_disposed) notifyListeners();
  }

  void _loadInterstitial() {
    if (_disposed || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_disposed) {
            unawaited(ad.dispose());
            return;
          }
          _interstitial = ad;
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  void showInterstitial({required VoidCallback onComplete}) {
    final ad = _interstitial;
    if (_disposed || ad == null) {
      onComplete();
      return;
    }

    _interstitial = null;
    var completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      onComplete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        finish();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        finish();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  @override
  void dispose() {
    _disposed = true;
    final banner = _banner;
    final interstitial = _interstitial;
    _banner = null;
    _interstitial = null;
    if (banner != null) unawaited(banner.dispose());
    if (interstitial != null) unawaited(interstitial.dispose());
    super.dispose();
  }
}
