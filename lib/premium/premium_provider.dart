import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'purchase_service.dart';

/// 権利の変化を流し続ける CustomerInfo。
final customerInfoStreamProvider = StreamProvider<CustomerInfo?>((ref) {
  return ref.watch(purchaseServiceProvider).customerInfoStream.handleError(
        (_) => null,
      );
});

/// プレミアムかどうか。購読状態が変わると即座に再構築される。
final isPremiumProvider = Provider<bool>((ref) {
  final info = ref.watch(customerInfoStreamProvider).valueOrNull;
  if (info == null) return false;
  return ref.watch(purchaseServiceProvider).isPremium(info);
});

/// ストリームが最初に流れる前の 1 回確認用。
final premiumCheckProvider = FutureProvider<bool>((ref) async {
  ref.keepAlive();
  final service = ref.watch(purchaseServiceProvider);
  try {
    return service.isPremium(await service.getCustomerInfo());
  } catch (_) {
    return false;
  }
});

/// 購入できるパッケージ（月額・年額など）。
final packagesProvider = FutureProvider<List<Package>>((ref) async {
  ref.keepAlive();
  return ref.watch(purchaseServiceProvider).getPackages();
});

enum PaywallStatus { idle, loading, success, error }

class PaywallState {
  const PaywallState({
    this.packages = const [],
    this.selectedId,
    this.status = PaywallStatus.idle,
    this.error,
  });

  final List<Package> packages;
  final String? selectedId;
  final PaywallStatus status;
  final String? error;

  bool get isLoading => status == PaywallStatus.loading;
  bool get isSuccess => status == PaywallStatus.success;

  Package? get selectedPackage =>
      packages.where((p) => p.identifier == selectedId).firstOrNull;

  PaywallState copyWith({
    List<Package>? packages,
    String? selectedId,
    PaywallStatus? status,
    String? error,
  }) =>
      PaywallState(
        packages: packages ?? this.packages,
        selectedId: selectedId ?? this.selectedId,
        status: status ?? this.status,
        error: error, // null を渡すとエラーを消す
      );
}

class PaywallNotifier extends StateNotifier<PaywallState> {
  PaywallNotifier(this._service) : super(const PaywallState()) {
    _load();
  }

  final PurchaseService _service;

  Future<void> _load() async {
    final pkgs = await _service.getPackages();
    if (!mounted) return;
    // 年額を初期選択にする（転換率が高い）。
    final annualId = pkgs
        .where((p) => p.packageType == PackageType.annual)
        .firstOrNull
        ?.identifier;
    state = state.copyWith(
      packages: pkgs,
      selectedId: annualId ?? pkgs.firstOrNull?.identifier,
    );
  }

  void selectPackage(String id) => state = state.copyWith(selectedId: id);

  /// 購入に成功してプレミアムになったら true。
  Future<bool> purchase() async {
    final pkg = state.selectedPackage;
    if (pkg == null) return false;
    state = state.copyWith(status: PaywallStatus.loading);
    try {
      final info = await _service.purchase(pkg);
      if (info == null) {
        state = state.copyWith(status: PaywallStatus.idle); // 取り消し
        return false;
      }
      final premium = _service.isPremium(info);
      state = state.copyWith(
        status: premium ? PaywallStatus.success : PaywallStatus.idle,
      );
      return premium;
    } on PurchasesError catch (e) {
      state = state.copyWith(status: PaywallStatus.error, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: PaywallStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(status: PaywallStatus.loading);
    try {
      final premium = _service.isPremium(await _service.restorePurchases());
      state = state.copyWith(
        status: premium ? PaywallStatus.success : PaywallStatus.idle,
        error: premium ? null : 'No previous purchases found',
      );
      return premium;
    } catch (e) {
      state = state.copyWith(status: PaywallStatus.error, error: e.toString());
      return false;
    }
  }
}

final paywallProvider =
    StateNotifierProvider.autoDispose<PaywallNotifier, PaywallState>(
  (ref) => PaywallNotifier(ref.watch(purchaseServiceProvider)),
);
