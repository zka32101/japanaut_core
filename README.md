# japanaut_core

Japanaut シリーズ（Trip / Food ほか）の共通基盤。

- `brand/` アプリ名・色・識別子（`AppBrand`）
- `i18n/` 13 言語・共通訳文ローダー
- `legal/` 法的文書テンプレート
- `config/` プレミアム設定（`PremiumConfig`）
- `premium/` `PurchaseService`（RevenueCat）・ペイウォール・`UsageLimit`（無料枠）
- `notifications/` `NotificationService`（FCM／ローカル通知）・通知種類ごとの ON/OFF
- `settings/` テーマ設定（`themeModeProvider`）

アプリ側は起動時に `appBrandProvider` と `purchaseServiceProvider` を `ProviderScope` の overrides で渡す。
