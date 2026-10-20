import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/premium_config.dart';

/// RevenueCat のラッパー。アプリごとの値は [PremiumConfig] と API キーで渡す。
///
/// RevenueCat のプロジェクトは他アプリと共有するため、プロジェクト全体の
/// 「current」オファリングには頼らず、[PremiumConfig.offeringId] を明示的に取る。
class PurchaseService {
  PurchaseService({
    required this.config,
    required this.apiKey,
    this.debugLogs = false,
  });

  final PremiumConfig config;

  /// このプラットフォーム用の RevenueCat 公開 SDK キー。
  final String apiKey;
  final bool debugLogs;

  bool _configured = false;
  final _controller = StreamController<CustomerInfo>.broadcast();

  /// 購入・復元・期限切れでエンタイトルメントが変わるたびに流れる。
  Stream<CustomerInfo> get customerInfoStream => _controller.stream;

  /// アプリ起動時に 1 回呼ぶ（サインイン前。匿名 ID で始まる）。
  Future<void> configure() async {
    if (_configured) return;
    _configured = true;
    if (debugLogs) await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(apiKey));
    Purchases.addCustomerInfoUpdateListener(_controller.add);
  }

  /// サインインしたユーザーを識別し、端末をまたいで権利を引き継ぐ。
  Future<void> loginUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (_) {}
  }

  /// サインアウト時に匿名ユーザーへ戻す。
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (_) {}
  }

  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();

  bool isPremium(CustomerInfo info) =>
      info.entitlements.active.containsKey(config.entitlementId);

  /// このアプリのオファリングのパッケージ。未設定・オフラインなら空。
  Future<List<Package>> getPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.getOffering(config.offeringId)?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  /// 成功なら更新後の [CustomerInfo]、ユーザーが取り消したら null。
  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo;
    } on PurchasesError catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError) return null;
      rethrow;
    }
  }

  /// 購入の復元（ストア審査で必須）。
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  Future<void> dispose() => _controller.close();
}

/// アプリ起動時に `ProviderScope(overrides: [purchaseServiceProvider.overrideWithValue(...)])`
/// でそのアプリの [PurchaseService] を渡す。
final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => throw UnimplementedError(
    'purchaseServiceProvider を ProviderScope の overrides で上書きしてください',
  ),
);
