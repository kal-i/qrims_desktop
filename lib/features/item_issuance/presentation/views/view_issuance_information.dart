import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/routes/app_router.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_message_box.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../officer/domain/entities/officer.dart';
import '../../data/models/inventory_custodian_slip.dart';
import '../../data/models/property_acknowledgement_receipt.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/issuance_item.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
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

    _issuancesBloc.add(
      GetIssuanceByIdEvent(
        id: widget.issuanceId,
      ),
    );

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
      body: BlocBuilder<IssuancesBloc, IssuancesState>(
        builder: (context, state) {
          return Column(
            children: [
              if (state is IssuancesLoading) _buildLoadingStateView(),
              if (state is IssuancesError)
                CustomMessageBox.error(
                  message: state.message,
                ),
              if (state is IssuanceLoaded)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: Column(
                        children: [
                          _buildIssuanceInformationContent(
                            issuanceId: state.issuance.id,
                            prId: state.issuance.purchaseRequestEntity.id,
                            entity: state.issuance.purchaseRequestEntity.entity.name,
                            fundCluster: state.issuance.purchaseRequestEntity.fundCluster,
                            items: state.issuance.items,
                            issuedDate: state.issuance.issuedDate,
                            receivingOfficer: state.issuance.receivingOfficerEntity,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingStateView() {
    return Center(
      child: Column(
        children: [
          const ReusableLinearProgressIndicator(),
          Text(
            'Fetching issuance information...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuanceInformationContent({
    required String issuanceId,
    // String? icsId,
    // String? parId,
    required String prId,
    // String? propertyNumber,
    required String entity,
    required FundCluster fundCluster,
    required DateTime issuedDate,
    DateTime? returnDate,
    List<IssuanceItemEntity>? items,
    required OfficerEntity receivingOfficer,
    //required OfficerEntity sendingOfficer,
    //required bool isReceived,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderSection(
          issuanceId: issuanceId,
          // icsId: icsId,
          // parId: parId,
          prId: prId,
          // propertyNumber: propertyNumber,
          entity: entity,
          fundCluster: fundCluster,
          issuedDate: issuedDate,
          returnDate: returnDate,
        ),
        const SizedBox(
          height: 50.0,
        ),
        SizedBox(
          height: 300.0,
          child: _buildIssuanceItemInformationSection(
            items: items,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomOutlineButton(
              onTap: () => context.pop(),
              text: 'Back',
              height: 40.0,
              width: 160.0,
            ),
          ],
        ),
        //_buildAssociatedOfficersSection(),
      ],
    );
  }

  Widget _buildHeaderSection({
    required String issuanceId,
    String? icsId,
    String? parId,
    required String prId,
    String? propertyNumber,
    required String entity,
    required FundCluster fundCluster,
    required DateTime issuedDate,
    DateTime? returnDate,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildInitialInformation(
          issuanceId: issuanceId,
          icsId: icsId,
          parId: parId,
          prId: prId,
          propertyNumber: propertyNumber,
          entity: entity,
          fundCluster: fundCluster,
          issuedDate: issuedDate,
          returnDate: returnDate,
        ),
        _buildQrContainer(
          issuanceId: issuanceId,
        ),
      ],
    );
  }

  Widget _buildQrContainer({
    required String issuanceId,
  }) {
    return BaseContainer(
      width: 160.0,
      height: 160.0,
      padding: 5.0,
      child: QrImageView(
        data: issuanceId,
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

  Widget _buildInitialInformation({
    required String issuanceId,
    String? icsId,
    String? parId,
    required String prId,
    String? propertyNumber,
    required String entity,
    required FundCluster fundCluster,
    required DateTime issuedDate,
    DateTime? returnDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _reusableRichText(
          title: 'Issuance No: ',
          value: issuanceId,
        ),
        if (icsId != null && icsId.isNotEmpty)
          _reusableRichText(
            title: 'ICS No:',
            value: icsId,
          ),
        if (parId != null && parId.isNotEmpty)
          _reusableRichText(
            title: 'PAR No:',
            value: parId,
          ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'PR No: ',
          value: prId,
        ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'Entity Name: ',
          value: entity,
        ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'Fund Cluster: ',
          value: readableEnumConverter(fundCluster),
        ),
        const SizedBox(
          height: 15.0,
        ),
        _reusableRichText(
          title: 'Issued Date: ',
          value: dateFormatter(issuedDate),
        ),
        const SizedBox(
          height: 15.0,
        ),
        if (returnDate != null)
          _reusableRichText(
            title: 'Return Date: ',
            value: dateFormatter(returnDate),
          ),
      ],
    );
  }

  Widget _buildIssuanceItemInformationSection({
    required List<IssuanceItemEntity>? items,
  }) {
    return CustomDataTable(
      config: _tableConfig.copyWith(
        rows: items
            ?.map(
              (issuedItem) => TableData(
                id: issuedItem.itemEntity.itemEntity.id,
                columns: [
                  Text(
                    issuedItem.itemEntity.itemEntity.id,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    issuedItem.quantity.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    issuedItem.itemEntity.itemEntity.unitCost.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            )
            .toList(),
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
