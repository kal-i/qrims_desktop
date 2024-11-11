import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../bloc/issuances_bloc.dart';

class ViewIssuanceInformation extends StatefulWidget {
  const ViewIssuanceInformation({
    super.key,
    required this.issuanceId,
  });

  final String issuanceId;

  @override
  State<ViewIssuanceInformation> createState() =>
      _ViewIssuanceInformationState();
}

class _ViewIssuanceInformationState extends State<ViewIssuanceInformation> {
  late IssuancesBloc _issuancesBloc;
  late String _issuanceId;

  late TableConfig _tableConfig;
  final List<String> _tableHeaders = [
    'Item Id',
    'Quantity',
    'Unit Cost',
  ];
  late List<TableData> _tableRows;

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();

    _tableRows = [];
    _initializeTableConfig();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeTableConfig() {
    _tableConfig = TableConfig(
      headers: _tableHeaders,
      rows: _tableRows,
      columnFlex: [
        2,
        1,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // if (state is IssuancesLoading)
          //   const ReusableLinearProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30.0,
                ),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildIssuanceInformationContent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuanceInformationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderSection(),
        const SizedBox(
          height: 50.0,
        ),
        SizedBox(height: 300.0,child: _buildIssuanceItemInformationSection()),
         _buildAssociatedOfficersSection(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildInitialInformation(),
        _buildQrContainer(),
      ],
    );
  }

  Widget _buildQrContainer() {
    return BaseContainer(
      width: 160.0,
      height: 160.0,
      padding: 5.0,
      child: QrImageView(
        data: 'ISS-2024-11-001', // _issuanceId,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: AppColor.darkPrimary,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: AppColor.darkPrimary,
        ),
      ),
    );
  }

  Widget _buildInitialInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reusableRichText(
          title: 'ICS No:',
          value: 'SPHV-2024-11-001',
        ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'Entity Name:',
          value: 'SDO LEGAZPI CITY - OAsDS',
        ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'Fund Cluster:',
          value: 'DIVISION MOOE',
        ),
      ],
    );
  }

  Widget _buildIssuanceItemInformationSection() {
    return CustomDataTable(
      config: _tableConfig.copyWith(
        rows: [
          // will delete soon
          TableData(
            id: 'Laptop-2024-11-001(1)',
            columns: [
              Text(
                'Laptop-2024-11-001(1)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '1',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '60000.00',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ], // _tableRows,
      ),
    );
  }

  Widget _buildAssociatedOfficersSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildSendingOfficerSection()),
        Expanded(child: _buildReceivingOfficerSection()),
      ],
    );
  }

  Widget _buildSendingOfficerSection() {
    return Column(
      children: [
        Text(
          'Received From:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.0,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            children: [
              Text(
                'JOHN PAUL MALACA MACERES',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.0,
                    ),
              ),
              Text(
                'HR MNGR - HR',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.0,
                    ),
              ),
              Text(
                '14/03/2024',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReceivingOfficerSection() {
    return Column(
      children: [
        Text(
          'Received By:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16.0,
              ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            children: [
              Text(
                'JOHN PAUL MALACA MACERES',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.0,
                    ),
              ),
              Text(
                'HR MNGR - HR',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.0,
                    ),
              ),
              Text(
                '14/03/2024',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14.0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reusableRichText({
    required String title,
    required String value,
  }) {
    return RichText(
      text: TextSpan(
        text: title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.0,
            ),
        children: [
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
