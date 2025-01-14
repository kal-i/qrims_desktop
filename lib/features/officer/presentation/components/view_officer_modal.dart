import 'package:flutter/material.dart';

import '../../../../core/common/components/base_modal.dart';
import '../../domain/entities/officer.dart';

class ViewOfficerModal extends StatelessWidget {
  const ViewOfficerModal({
    super.key,
    required this.officerEntity,
  });

  final OfficerEntity officerEntity;

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
        Text(
          officerEntity.name,
        ),
        Text(
          officerEntity.positionName,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: officerEntity.positionHistory.length,
            itemBuilder: (context, index) {
              final position = officerEntity.positionHistory[index];

              return Text(
                  '${position.positionName} . ${position.officeName} . ${position.createdAt}');
            },
          ),
        ),
      ],
    );
  }
}
