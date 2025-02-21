import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/utils/document_date_formatter.dart';
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
      width: 500.0,
      height: 600.0,
      headerTitle: 'Officer Information',
      content: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        const Icon(
          HugeIcons.strokeRoundedUserCircle,
          size: 60.0,
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(
          widget.officerEntity.name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16.0,
              ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          '${widget.officerEntity.officeName} . ${widget.officerEntity.positionName}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14.0,
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
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
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
                    height: 250.0,
                    child: ListView.builder(
                      itemCount: widget.officerEntity.positionHistory.length,
                      itemBuilder: (context, index) {
                        final position =
                            widget.officerEntity.positionHistory[index];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              documentDateFormatter(position.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 12.0,
                                  ),
                            ),
                            Text(
                              '${position.officeName} . ${position.positionName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 12.0,
                                  ),
                            ),
                          ],
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
    );
  }
}
