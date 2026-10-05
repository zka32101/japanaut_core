/// プレミアム（RevenueCat）の設定。アプリごとに値を変える。
class PremiumConfig {
  const PremiumConfig({
    required this.entitlementId,
    required this.offeringId,
    required this.monthlyProductId,
    required this.annualProductId,
  });

  /// RevenueCat のエンタイトルメント ID。
  final String entitlementId;

  /// RevenueCat のオファリング ID（current にせず、アプリが明示的に取得する）。
  final String offeringId;

  /// Google Play / App Store の商品 ID。
  final String monthlyProductId;
  final String annualProductId;
}
