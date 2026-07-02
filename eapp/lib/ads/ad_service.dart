import 'package:get/get.dart';

class AdService extends GetxService {
  final RxBool adsEnabled = false.obs;

  Future<AdService> init() async {
    // Initialize ads sdk here in the future
    return this;
  }

  void showBannerAd() {
    Get.log('Banner ad shown');
  }

  void showInterstitialAd() {
    Get.log('Interstitial ad shown');
  }
}
