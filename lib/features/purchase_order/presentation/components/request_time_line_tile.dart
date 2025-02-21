import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../config/themes/app_color.dart';
import '../../../../core/utils/user_friendly_date_formatter.dart';

typedef TimelineTileTapCallback = void Function();

class RequestTimeLineTile extends StatelessWidget {
  const RequestTimeLineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.title,
    required this.message,
    required this.date,
    this.onTrackingIdTapped,
  });

  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String title;
  final String message;
  final DateTime date;
  final ValueChanged<String>? onTrackingIdTapped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: 60.0,
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        alignment: TimelineAlign.manual,
        isFirst: isFirst,
        isLast: isLast,
        lineXY: 0.2,
        indicatorStyle: _indicatorStyle(context),
        beforeLineStyle: LineStyle(
          color: Theme.of(context).dividerColor.withOpacity(.5),
          thickness: 1.3,
        ),
        startChild: _eventDate(context),
        endChild: _eventCard(context),
      ),
    );
  }

  IndicatorStyle _indicatorStyle(BuildContext context) {
    return IndicatorStyle(
      width: isLast ? 20.0 : 10.0,
      height: isLast ? 20.0 : 10.0,
      color: isLast ? AppColor.accent : AppColor.accent.withOpacity(0.8),
      iconStyle: isLast
          ? IconStyle(
              iconData: Icons.done,
              color: AppColor.lightPrimary,
              fontSize: 16.0,
            )
          : null,
    );
  }

  Widget _eventCard(BuildContext context) {
    final RegExp regExp = RegExp(r'Tracking ID:\s(ISS-\d{4}-\d{2}-\d+)');
    final match = regExp.firstMatch(message);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10.0),
      //   color: Theme.of(context).cardColor,
      // ),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _titleText(context),
          const SizedBox(height: 4.0),
          match != null
              ? _buildWithTrackingId(
                  context,
                  match,
                )
              : _buildWithoutTrackingId(
                  context,
                ),
        ],
      ),
    );
  }

  Widget _titleText(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildWithTrackingId(BuildContext context, RegExpMatch match) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Text(
              message.substring(0, match.start),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
          GestureDetector(
            onTap: () => onTrackingIdTapped?.call(match.group(0)!),
            child: Text(
              match.group(
                  0)!, // group(0) returns the full match (ISS-####-##-###)
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.accent,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithoutTrackingId(BuildContext context) {
    return Flexible(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.0,
              fontWeight: FontWeight.w400,
            ),
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _eventDate(BuildContext context) {
    return Text(
      userFriendlyDateFormatter(date),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10.0,
            fontWeight: FontWeight.w400,
          ),
      textAlign: TextAlign.center,
    );
  }
}
