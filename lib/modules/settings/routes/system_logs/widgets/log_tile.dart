import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/database/models/log.dart';
import 'package:lunasea/extensions/datetime.dart';

class SettingsSystemLogTile extends StatelessWidget {
  final LunaLog log;

  const SettingsSystemLogTile({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dateTime =
        DateTime.fromMillisecondsSinceEpoch(log.timestamp).asDateTime();
    return LunaExpandableListTile(
      title: log.message,
      collapsedSubtitles: [
        TextSpan(text: dateTime),
        TextSpan(
          text: log.type.title.toUpperCase(),
          style: TextStyle(
            color: log.type.color,
            fontWeight: LunaUI.FONT_WEIGHT_BOLD,
          ),
        ),
      ],
      expandedHighlightedNodes: [
        LunaHighlightedNode(
          text: log.type.title.toUpperCase(),
          backgroundColor: log.type.color,
        ),
        LunaHighlightedNode(
          text: dateTime,
          backgroundColor: LunaColours.blueGrey,
        ),
      ],
      expandedTableContent: [
        if (log.className != null && log.className!.isNotEmpty)
          LunaTableContent(title: 'Class', body: log.className),
        if (log.methodName != null && log.methodName!.isNotEmpty)
          LunaTableContent(title: 'Method', body: log.methodName),
        if (log.error != null && log.error!.isNotEmpty)
          LunaTableContent(title: 'Exception', body: log.error),
      ],
    );
  }
}
