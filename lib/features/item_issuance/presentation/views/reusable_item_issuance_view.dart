import 'package:flutter/material.dart';

import '../../../../core/enums/issuance_purpose.dart';

class ReusableItemIssuanceView extends StatefulWidget {
  const ReusableItemIssuanceView({
    super.key,
    required this.issuancePurpose,
    required this.prId,
  });

  final IssuancePurpose issuancePurpose;
  final String prId;

  @override
  State<ReusableItemIssuanceView> createState() =>
      _ReusableItemIssuanceViewState();
}

class _ReusableItemIssuanceViewState extends State<ReusableItemIssuanceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(),
        child: Text(
          widget.prId,
        ),
      ),
    );
  }
}
