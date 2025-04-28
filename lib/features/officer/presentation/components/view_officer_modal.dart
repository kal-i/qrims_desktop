import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/standardize_position_name.dart';
import '../../domain/entities/officer.dart';

class ViewOfficerModal extends StatefulWidget {
  const ViewOfficerModal({
    super.key,
    required this.officerEntity,
  });

  final OfficerEntity officerEntity;

  @override
  State<ViewOfficerModal> createState() => _ViewOfficerModalState();
}

class _ViewOfficerModalState extends State<ViewOfficerModal> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier(false);

  @override
  void dispose() {
    _isExpanded.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModal(
      width: 600.0,
      height: 480.0,
      headerTitle: 'Officer Information',
      subtitle: 'View officer\'s profile and position history.',
      content: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final sortedPositions = [...widget.officerEntity.positionHistory]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 30.0,
      ),
      child: Column(
        children: [
          Text(
            capitalizeWord(widget.officerEntity.name),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            standardizePositionName(widget.officerEntity.positionName),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            capitalizeWord(widget.officerEntity.officeName),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _isExpanded,
              builder: (context, isExpanded, child) {
                return ExpansionTile(
                  onExpansionChanged: (bool expanded) =>
                      _isExpanded.value = expanded,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  title: Text(
                    'Position History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  trailing: Icon(
                    isExpanded
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                    size: 20.0,
                  ),
                  children: [
                    SizedBox(
                      height: 150.0,
                      child: ListView.builder(
                        itemCount: sortedPositions.length,
                        itemBuilder: (context, index) {
                          final position = sortedPositions[index];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  documentDateFormatter(position.createdAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  '${standardizePositionName(position.positionName)} - ${capitalizeWord(position.officeName)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
