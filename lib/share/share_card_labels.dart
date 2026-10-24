import 'package:easy_localization/easy_localization.dart';

/// 共有カードに出る文言。ウィジェットは tr() に直接依存せず、これを受け取る。
/// 既定値は英語で、アプリは [ShareCardLabels.localized] を渡すと 13 言語になる。
///
/// `{}` は [fill] で順に置き換える（easy_localization の引数と同じ書き方）。
class ShareCardLabels {
  const ShareCardLabels({
    this.share = 'Share',
    this.dayN = 'Day {}',
    this.spotsN = '{} spots',
    this.moreN = '+{} more',
    this.stampBook = 'Stamp Book',
    this.progress = '{} / {}',
    this.yearTitle = '{} in review',
    this.visitedSpots = 'Spots',
    this.visitedRegions = 'Regions',
    this.busiestMonth = 'Busiest month',
    this.monthN = 'Month {}',
  });

  /// 共通訳文（`common.*` と `share_card.*`）から作る。
  factory ShareCardLabels.localized() => ShareCardLabels(
        share: tr('common.share'),
        dayN: tr('share_card.day_n'),
        spotsN: tr('share_card.spots_n'),
        moreN: tr('share_card.more_n'),
        stampBook: tr('share_card.stamp_book'),
        progress: tr('share_card.progress'),
        yearTitle: tr('share_card.year_title'),
        visitedSpots: tr('share_card.visited_spots'),
        visitedRegions: tr('share_card.visited_regions'),
        busiestMonth: tr('share_card.busiest_month'),
        monthN: tr('share_card.month_n'),
      );

  final String share;
  final String dayN;
  final String spotsN;
  final String moreN;
  final String stampBook;
  final String progress;
  final String yearTitle;
  final String visitedSpots;
  final String visitedRegions;
  final String busiestMonth;
  final String monthN;

  /// [template] の `{}` を [args] で先頭から順に置き換える。
  static String fill(String template, List<Object> args) {
    var i = 0;
    return template.replaceAllMapped(
      '{}',
      (_) => i < args.length ? '${args[i++]}' : '',
    );
  }
}
