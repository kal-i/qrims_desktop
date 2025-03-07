import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/base_container.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../../../../core/common/components/custom_form_text_field.dart';

import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/common/components/reusable_linear_progress_indicator.dart';
import '../../../../core/utils/document_date_formatter.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../domain/entities/inventory_custodian_slip.dart';
import '../../domain/entities/issuance.dart';
import '../../domain/entities/property_acknowledgement_receipt.dart';
import '../../domain/entities/requisition_and_issue_slip.dart';
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
  late IssuanceEntity _issuanceEntity;

  final _issuanceIdController = TextEditingController();
  final _concreteIssuanceIdController = TextEditingController();
  final _issuedDateController = TextEditingController();

  final _prIdController = TextEditingController();
  final _prDateController = TextEditingController();
  final _prStatusController = TextEditingController();
  final _requestingOfficerController = TextEditingController();
  final _approvingOfficerController = TextEditingController();

  final _entityNameController = TextEditingController();
  final _fundClusterController = TextEditingController();

  final _divisionController = TextEditingController();
  final _responsibilityCenterCodeController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _purposeController = TextEditingController();

  final _receivingOfficerOfficeNameController = TextEditingController();
  final _receivingOfficerPositionNameController = TextEditingController();
  final _receivingOfficerNameController = TextEditingController();

  final _issuingOfficerOfficeNameController = TextEditingController();
  final _issuingOfficerPositionNameController = TextEditingController();
  final _issuingOfficerNameController = TextEditingController();

  final _approvingOfficerOfficeNameController = TextEditingController();
  final _approvingOfficerPositionNameController = TextEditingController();
  final _approvingOfficerNameController = TextEditingController();

  final _requestingOfficerOfficeNameController = TextEditingController();
  final _requestingOfficerPositionNameController = TextEditingController();
  final _requestingOfficerNameController = TextEditingController();

  late TableConfig _prTableConfig;
  late TableConfig _issuedTableConfig;

  final List<String> _prTableHeaders = [
    'Item Name',
    'Description',
    'Unit',
    'Requested Quantity',
    'Unit Cost',
    'Remaining Quantity',
    'Status',
  ];
  final List<String> _issuedTableHeaders = [
    'Item Id',
    'Issued Quantity',
  ];

  late List<TableData> _prTableRows;
  late List<TableData> _issuedTableRows;

  @override
  void initState() {
    super.initState();
    _issuancesBloc = context.read<IssuancesBloc>();

    _issuancesBloc.add(
      GetIssuanceByIdEvent(
        id: widget.issuanceId,
      ),
    );

    _prTableRows = [];
    _issuedTableRows = [];
    _initializeTableConfig();
  }

  void _initializeTableConfig() {
    _prTableConfig = TableConfig(
      headers: _prTableHeaders,
      rows: _prTableRows,
      columnFlex: [
        2,
        2,
        1,
        2,
        1,
        2,
        1,
      ],
    );

    _issuedTableConfig = TableConfig(
      headers: _issuedTableHeaders,
      rows: _issuedTableRows,
      columnFlex: [
        2,
        1,
        1,
      ],
    );
  }

  @override
  void dispose() {
    _issuanceIdController.dispose();
    _concreteIssuanceIdController.dispose();
    _issuedDateController.dispose();

    _prIdController.dispose();
    _prDateController.dispose();
    _prStatusController.dispose();
    _requestingOfficerController.dispose();
    _approvingOfficerController.dispose();

    _entityNameController.dispose();
    _fundClusterController.dispose();

    _divisionController.dispose();
    _responsibilityCenterCodeController.dispose();
    _officeNameController.dispose();
    _purposeController.dispose();

    _receivingOfficerOfficeNameController.dispose();
    _receivingOfficerPositionNameController.dispose();
    _receivingOfficerNameController.dispose();

    _approvingOfficerOfficeNameController.dispose();
    _approvingOfficerPositionNameController.dispose();
    _approvingOfficerNameController.dispose();

    _issuingOfficerOfficeNameController.dispose();
    _issuingOfficerPositionNameController.dispose();
    _issuingOfficerNameController.dispose();

    _requestingOfficerOfficeNameController.dispose();
    _requestingOfficerPositionNameController.dispose();
    _requestingOfficerNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<IssuancesBloc, IssuancesState>(
        listener: (context, state) {
          if (state is IssuanceLoaded) {
            final issuanceEntity = state.issuance;

            _issuanceEntity = issuanceEntity;

            final issuanceItemEntities = issuanceEntity.items;

            _issuedTableRows.clear();
            _issuedTableRows.addAll(
              issuanceItemEntities
                  .map(
                    (issuanceItem) => TableData(
                      id: issuanceItem.issuanceId,
                      columns: [
                        Text(
                          issuanceItem
                              .itemEntity.shareableItemInformationEntity.id,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          issuanceItem.quantity.toString(),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            );

            _issuedDateController.text =
                documentDateFormatter(issuanceEntity.issuedDate);

            final purchaseRequestEntity = issuanceEntity.purchaseRequestEntity;

            if (purchaseRequestEntity != null) {
              _prIdController.text = purchaseRequestEntity.id;
              _prDateController.text =
                  documentDateFormatter(purchaseRequestEntity.date);
              _prStatusController.text = readableEnumConverter(
                  purchaseRequestEntity.purchaseRequestStatus);

              final requestingOfficerEntity =
                  purchaseRequestEntity.requestingOfficerEntity;
              final approvingOfficerEntity =
                  purchaseRequestEntity.approvingOfficerEntity;

              _requestingOfficerController.text = requestingOfficerEntity.name;
              _approvingOfficerController.text = approvingOfficerEntity.name;

              final requestedItemEntities =
                  purchaseRequestEntity.requestedItemEntities;

              _prTableRows.clear();
              _prTableRows.addAll(
                requestedItemEntities
                    .map(
                      (requestedItem) => TableData(
                        id: requestedItem.id.toString(),
                        columns: [
                          Text(
                            requestedItem.productNameEntity.name,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            requestedItem
                                    .productDescriptionEntity.description ??
                                'No description specified.',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            requestedItem.quantity.toString(),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            requestedItem.unitCost.toString(),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            requestedItem.remainingQuantity.toString(),
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            'Not complete',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
            }

            final receivingOfficerEntity =
                issuanceEntity.receivingOfficerEntity;
            final issuingOfficerEntity = issuanceEntity.issuingOfficerEntity;

            _issuanceIdController.text = issuanceEntity.id;

            _receivingOfficerOfficeNameController.text =
                receivingOfficerEntity?.officeName ?? 'N/A';
            _receivingOfficerPositionNameController.text =
                receivingOfficerEntity?.positionName ?? 'N/A';
            _receivingOfficerNameController.text =
                receivingOfficerEntity?.name ?? 'N/A';

            _issuingOfficerOfficeNameController.text =
                issuingOfficerEntity?.officeName ?? 'N/A';
            _issuingOfficerPositionNameController.text =
                issuingOfficerEntity?.positionName ?? 'N/A';
            _issuingOfficerNameController.text =
                issuingOfficerEntity?.name ?? 'N/A ';

            if (issuanceEntity is InventoryCustodianSlipEntity) {
              _concreteIssuanceIdController.text = issuanceEntity.icsId;
            }

            if (issuanceEntity is PropertyAcknowledgementReceiptEntity) {
              _concreteIssuanceIdController.text = issuanceEntity.parId;
            }

            if (issuanceEntity is RequisitionAndIssueSlipEntity) {
              final officeEntity = issuanceEntity.office;
              final approvingOfficerEntity =
                  issuanceEntity.approvingOfficerEntity;
              final requestingOfficerEntity =
                  issuanceEntity.requestingOfficerEntity;

              _divisionController.text = issuanceEntity.division ?? 'N/A';
              _responsibilityCenterCodeController.text =
                  issuanceEntity.responsibilityCenterCode ?? 'N/A';
              _officeNameController.text = officeEntity?.officeName ?? 'N/A';
              _purposeController.text = issuanceEntity.purpose ?? 'N/A';

              _approvingOfficerOfficeNameController.text =
                  approvingOfficerEntity?.officeName ?? 'N/A';
              _approvingOfficerPositionNameController.text =
                  approvingOfficerEntity?.positionName ?? 'N/A';
              _approvingOfficerNameController.text =
                  approvingOfficerEntity?.name ?? 'N/A';

              _requestingOfficerOfficeNameController.text =
                  requestingOfficerEntity?.officeName ?? 'N/A';
              _requestingOfficerPositionNameController.text =
                  requestingOfficerEntity?.positionName ?? 'N/A';
              _requestingOfficerNameController.text =
                  requestingOfficerEntity?.name ?? 'N/A';
            }
          }
        },
        child: BlocBuilder<IssuancesBloc, IssuancesState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is IssuancesLoading)
                  const ReusableLinearProgressIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInitialIssuanceInformation(),
        const SizedBox(
          height: 50.0,
        ),
        _buildPreviewPurchaseRequestSummary(),
        const SizedBox(
          height: 50.0,
        ),
        _buildItemIssuanceSection(),
        const SizedBox(
          height: 50.0,
        ),
        _buildRelatedOfficersSection(),
        const SizedBox(
          height: 80.0,
        ),
        _buildActionsRow(),
      ],
    );
  }

  Widget _buildInitialIssuanceInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issuance QR Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            _buildQrContainer(),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                children: [
                  CustomFormTextField(
                    label: 'Issuance Id',
                    controller: _issuanceIdController,
                    enabled: false,
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomFormTextField(
                    label: 'Concrete Issuance Id',
                    controller: _concreteIssuanceIdController,
                    enabled: false,
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                children: [
                  CustomFormTextField(
                    label: 'Issued Date',
                    controller: _issuanceIdController,
                    enabled: false,
                    fillColor:
                        (context.watch<ThemeBloc>().state == AppTheme.light
                            ? AppColor.lightCustomTextBox
                            : AppColor.darkCustomTextBox),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget _buildQrContainer() {
    return BaseContainer(
      width: 160.0,
      height: 160.0,
      padding: 5.0,
      child: QrImageView(
        data: _issuanceIdController.text,
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

  Widget _buildPreviewPurchaseRequestSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Purchase Request',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Summarize information of the Purchase Request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomFormTextField(
                controller: _prIdController,
                enabled: false,
                label: 'PR No.',
                placeholderText: 'Ex.',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _prDateController,
                enabled: false,
                label: 'Date',
                placeholderText: '0000/00/00',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _prStatusController,
                enabled: false,
                label: 'Status',
                placeholderText: 'Unknown',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: CustomFormTextField(
                controller: _requestingOfficerController,
                enabled: false,
                label: 'Requesting Officer',
                placeholderText: 'Name (Office - Position)',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: CustomFormTextField(
                controller: _approvingOfficerController,
                enabled: false,
                label: 'Approving Officer',
                placeholderText: 'Name (Office - Position)',
                fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightCustomTextBox
                    : AppColor.darkCustomTextBox),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        SizedBox(
          height: 250.0,
          child: CustomDataTable(
            config: _prTableConfig.copyWith(
              rows: _prTableRows,
            ),
            onActionSelected: (id, action) {},
          ),
        ),
      ],
    );
  }

  Widget _buildItemIssuanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item(s) Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              'Item(s) issued.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        SizedBox(
          height: 250.0,
          child: CustomDataTable(
              config: _issuedTableConfig.copyWith(
                rows: _issuedTableRows,
              ),
              onActionSelected: (index, action) {}),
        ),
      ],
    );
  }

  Widget _buildRelatedOfficersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Associated Officers',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Officers involved to this request.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Expanded(
              child: _buildRequestingOfficerOfficeField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerPositionSuggestionField(),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: _buildRequestingOfficerNameSuggestionField(),
            ),
          ],
        ),
        const SizedBox(
          height: 30.0,
        ),
        if (_issuanceEntity is! RequisitionAndIssueSlipEntity)
          Row(
            children: [
              Expanded(
                child: _buildSendingOfficerOfficeSuggestionField(),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: _buildSendingOfficerPositionSuggestionField(),
              ),
              const SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: _buildSendingOfficerNameSuggestionField(),
              ),
            ],
          ),
        if (_issuanceEntity is RequisitionAndIssueSlipEntity)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildApprovingOfficerOfficeSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildApprovingOfficerPositionSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildApprovingOfficerNameSuggestionField(),
                  ),
                ],
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildIssuingOfficerOfficeSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildIssuingOfficerPositionSuggestionField(),
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: _buildIssuingOfficerNameSuggestionField(),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRequestingOfficerOfficeField() {
    return CustomFormTextField(
      controller: _receivingOfficerOfficeNameController,
      enabled: false,
      label: 'Receiving Officer Office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildSendingOfficerOfficeSuggestionField() {
    return CustomFormTextField(
      //controller: _sendingOfficerOfficeNameController,
      enabled: false,
      label: 'Sending Officer Office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildApprovingOfficerOfficeSuggestionField() {
    return CustomFormTextField(
      controller: _approvingOfficerOfficeNameController,
      enabled: false,
      label: 'Approving Officer Office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildIssuingOfficerOfficeSuggestionField() {
    return CustomFormTextField(
      controller: _issuingOfficerOfficeNameController,
      enabled: false,
      label: 'Issuing Officer Office',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerPositionSuggestionField() {
    return CustomFormTextField(
      controller: _receivingOfficerPositionNameController,
      enabled: false,
      label: 'Receiving Officer Position',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildSendingOfficerPositionSuggestionField() {
    return CustomFormTextField(
      //controller: _sendingOfficerPositionNameController,
      enabled: false,
      label: 'Sending Officer Position',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildApprovingOfficerPositionSuggestionField() {
    return CustomFormTextField(
      controller: _approvingOfficerPositionNameController,
      enabled: false,
      label: 'Approving Officer Position',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildIssuingOfficerPositionSuggestionField() {
    return CustomFormTextField(
      controller: _issuingOfficerPositionNameController,
      enabled: false,
      label: 'Issuing Officer Position',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildRequestingOfficerNameSuggestionField() {
    return CustomFormTextField(
      controller: _receivingOfficerNameController,
      enabled: false,
      label: 'Receiving Officer Name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildSendingOfficerNameSuggestionField() {
    return CustomFormTextField(
      //controller: _sendingOfficerNameController,
      enabled: false,
      label: 'Sending Officer Name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildApprovingOfficerNameSuggestionField() {
    return CustomFormTextField(
      controller: _approvingOfficerNameController,
      enabled: false,
      label: 'Approving Officer Name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildIssuingOfficerNameSuggestionField() {
    return CustomFormTextField(
      controller: _issuingOfficerNameController,
      enabled: false,
      label: 'Issuing Officer Name',
      fillColor: (context.watch<ThemeBloc>().state == AppTheme.light
          ? AppColor.lightCustomTextBox
          : AppColor.darkCustomTextBox),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Back',
          width: 180.0,
        ),
      ],
    );
  }
}
