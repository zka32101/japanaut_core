import '../brand/app_brand.dart';

/// 利用規約・プライバシーポリシーの共通テンプレート。
///
/// アプリ名と連絡先は [AppBrand] から差し込む。アプリ固有の説明
/// （何を集めるか・どんなサービスか）は引数で渡す。
class LegalText {
  const LegalText._();

  static const defaultLastUpdated = 'June 2026';

  /// プライバシーポリシー。
  /// [collectedUsage] は「利用状況として何を集めるか」（例: spots you view, plans you create）。
  static String privacy(
    AppBrand brand, {
    required String collectedUsage,
    String lastUpdated = defaultLastUpdated,
  }) {
    final name = brand.displayName;
    return '''
Privacy Policy

Last updated: $lastUpdated

1. Information We Collect
$name collects information you provide directly, such as your email address, display name, and profile photo when you create an account. We also collect usage data including $collectedUsage.

2. How We Use Your Information
We use your information to provide and improve our services, personalize your experience, send you notifications you have requested, and ensure the security of your account.

3. Information Sharing
We do not sell your personal information. We may share your information with Firebase/Google (our backend provider) and RevenueCat (subscription management). These partners process data solely to provide services on our behalf.

4. Data Storage
Your data is stored securely using Google Firebase. We retain your data as long as your account is active or as needed to provide services.

5. Your Rights
You may access, correct, or delete your personal information at any time via the Profile or Settings screen. To permanently delete your account and all associated data, use the "Delete Account" option in Settings.

6. Contact
For privacy-related questions, contact us at ${brand.supportEmail}
''';
  }

  /// 利用規約。[serviceSummary] は「どんなサービスか」
  /// （例: cultural information, travel planning tools, and AI-powered features for visitors to Japan）。
  static String terms(
    AppBrand brand, {
    required String serviceSummary,
    String contentNotice =
        'AI-generated content is provided for informational purposes only and may contain errors. Always verify important information with official sources.',
    String lastUpdated = defaultLastUpdated,
  }) {
    final name = brand.displayName;
    return '''
Terms of Service

Last updated: $lastUpdated

1. Acceptance of Terms
By using $name, you agree to these Terms of Service. If you do not agree, please do not use the app.

2. Use of the Service
$name provides $serviceSummary. You may use the app for personal, non-commercial purposes only.

3. User Accounts
You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate information when creating your account.

4. Content
$contentNotice

5. Subscriptions
Premium features are available via subscription. Subscriptions auto-renew unless cancelled at least 24 hours before the renewal date. Refunds are handled per the Google Play Store or Apple App Store policies.

6. Limitation of Liability
$name is provided "as is." We are not liable for any damages arising from your use of the app or reliance on its content.

7. Changes to Terms
We may update these Terms at any time. Continued use of the app after changes constitutes acceptance of the new Terms.

8. Contact
For questions about these Terms, contact us at ${brand.supportEmail}
''';
  }
}