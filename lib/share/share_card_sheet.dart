import 'package:flutter/material.dart';

import 'share_card_frame.dart';
import 'share_card_labels.dart';
import 'share_card_service.dart';

/// 共有カードのプレビューを出すボトムシート。季節フレームを選べて（初期値は今の季節）、
/// カードを画像として共有する。
///
/// [cardBuilder] は選ばれた [CardFrameStyle] でカード全体（通常は [ShareCardFrame]）を作る。
Future<void> showShareCardSheet(
  BuildContext context, {
  required Widget Function(BuildContext context, CardFrameStyle style)
      cardBuilder,
  ShareCardLabels labels = const ShareCardLabels(),
  String? shareText,
  String? subject,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ShareCardSheet(
      cardBuilder: cardBuilder,
      labels: labels,
      shareText: shareText,
      subject: subject,
    ),
  );
}

class _ShareCardSheet extends StatefulWidget {
  const _ShareCardSheet({
    required this.cardBuilder,
    required this.labels,
    this.shareText,
    this.subject,
  });

  final Widget Function(BuildContext context, CardFrameStyle style) cardBuilder;
  final ShareCardLabels labels;
  final String? shareText;
  final String? subject;

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final _boundaryKey = GlobalKey();
  CardFrameStyle _style = CardFrameStyleX.forDate(DateTime.now());
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      await shareBoundaryAsImage(
        _boundaryKey,
        text: widget.shareText,
        subject: widget.subject,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final s in CardFrameStyle.values)
                  ChoiceChip(
                    label: Text(s.emoji),
                    selected: _style == s,
                    onSelected: (_) => setState(() => _style = s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: ShareCardFrame.width / ShareCardFrame.height,
                child: FittedBox(
                  // 境界はカード本来の 360×450 のまま。書き出しはプレビューの拡大率に依らない。
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: widget.cardBuilder(context, _style),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: const Icon(Icons.ios_share),
                label: Text(widget.labels.share),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
