/// 行った場所の記録 1 件（国を問わない共通の形）。
///
/// アプリ側が自分のデータ（日記など）からこの形に変換して渡す。
class VisitRecord {
  const VisitRecord({
    required this.placeId,
    required this.title,
    required this.visitedAt,
    this.regionId,
    this.imageUrl,
  });

  /// 場所の ID。同じ場所を何度訪れても 1 か所として数える。
  final String placeId;
  final String title;
  final DateTime visitedAt;

  /// 地域の ID（日本なら都道府県）。[Region.id] と対応する。不明なら null。
  final String? regionId;
  final String? imageUrl;
}

/// タイルマップ上の地域 1 つ。国ごとにアプリが一覧を用意する。
class Region {
  const Region({
    required this.id,
    required this.label,
    required this.col,
    required this.row,
  });

  final String id;

  /// タイルに書く短い名前（例: 東京）。
  final String label;

  /// タイルを並べる格子の位置（左上が 0, 0）。
  final int col;
  final int row;
}
